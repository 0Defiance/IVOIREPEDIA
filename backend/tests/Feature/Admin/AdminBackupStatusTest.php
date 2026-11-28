<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * L'état des sauvegardes doit se lire dans le panneau, pas dans un SSH.
 *
 * Ces tests s'appuient sur de vrais fichiers (`~/backups` simulé) : la carte ne
 * fait que deux `stat`, et c'est précisément ce qu'on veut vérifier — y compris
 * quand aucun dump n'existe.
 */
uses(RefreshDatabase::class);

function backupStatusDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-panel-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

function dropBackupStatusDir(string $dir): void
{
    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $file) {
        @unlink($file);
    }
    foreach (glob($dir.DIRECTORY_SEPARATOR.'.[a-z]*') ?: [] as $file) {
        @unlink($file);
    }
    @rmdir($dir);
}

it('affiche la date du dernier dump et celle de la dernière copie hors-site', function () {
    $dir = backupStatusDir();
    $at = time() - 7200;
    $name = 'db-ivoirepedia_prod-'.gmdate('Ymd-His', $at).'.sql.gz';

    file_put_contents($dir.'/'.$name, 'dump');
    @touch($dir.'/.last-offsite', time() - 3600);

    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => 'offsite',
        'database.connections.mysql.database' => 'ivoirepedia_prod',
    ]);

    $this->actingAs(User::factory()->editor()->create())
        ->get('/admin')
        ->assertOk()
        ->assertSee('Sauvegardes')
        ->assertSee('Dernier dump')
        ->assertSee(gmdate('d/m/Y H:i', $at).' UTC')
        ->assertSee('Copie hors-site')
        ->assertSee(gmdate('d/m/Y H:i', time() - 3600).' UTC')
        ->assertDontSee('Aucune sauvegarde depuis');

    dropBackupStatusDir($dir);
});

it('signale visiblement l’absence de dump depuis le seuil', function () {
    $dir = backupStatusDir();

    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => null,
        'database.connections.mysql.database' => 'ivoirepedia_prod',
    ]);

    $this->actingAs(User::factory()->editor()->create())
        ->get('/admin')
        ->assertOk()
        ->assertSee('Aucun dump de la base')
        ->assertSee('Copie hors-site')
        ->assertSee('désactivée');

    // Un dump plus vieux que 36 h : l'alerte nomme l'âge et le seuil.
    $old = time() - 40 * 3600;
    file_put_contents($dir.'/db-ivoirepedia_prod-'.gmdate('Ymd-His', $old).'.sql.gz', 'dump');

    $this->actingAs(User::factory()->editor()->create())
        ->get('/admin')
        ->assertOk()
        ->assertSee('Aucune sauvegarde depuis 40 h (seuil 36 h)');

    dropBackupStatusDir($dir);
});

it('n’affiche pas d’alerte pour un dump récent', function () {
    $dir = backupStatusDir();
    file_put_contents($dir.'/db-ivoirepedia_prod-'.gmdate('Ymd-His', time() - 600).'.sql.gz', 'dump');

    config([
        'backup.directory' => $dir,
        'database.connections.mysql.database' => 'ivoirepedia_prod',
    ]);

    $this->actingAs(User::factory()->contributor()->create())
        ->get('/admin')
        ->assertOk()
        ->assertDontSee('Aucune sauvegarde depuis')
        ->assertDontSee('Aucun dump de la base');

    dropBackupStatusDir($dir);
});
