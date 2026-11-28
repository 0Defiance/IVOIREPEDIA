<?php

use App\Support\OffsiteBackups;
use Illuminate\Support\Facades\Storage;

/**
 * La copie hors-site : les archives quittent l'hébergeur, la rétention suit.
 */
function offsiteDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-offsite-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

function offsiteArchive(string $dir, string $name): void
{
    file_put_contents($dir.DIRECTORY_SEPARATOR.$name, str_repeat('x', 64));
}

function dropOffsiteDir(string $dir): void
{
    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $file) {
        @unlink($file);
    }
    @rmdir($dir);
}

it('envoie toutes les archives absentes et applique la rétention distante', function () {
    Storage::fake('offsite');
    $dir = offsiteDir();
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261126-033000.sql.gz');
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261127-033000.sql.gz');
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261128-033000.sql.gz');
    offsiteArchive($dir, 'media-ivoirepedia_prod-20261128-033000.tar.gz');

    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => 'offsite',
        'backup.offsite.prefix' => 'ivoirepedia',
        'backup.offsite.keep' => 2,
    ]);

    $this->artisan('backup:offsite')->assertExitCode(0);

    // Les deux plus récents restent, l'avant-veille est purgée.
    Storage::disk('offsite')->assertExists('ivoirepedia/db-ivoirepedia_prod-20261128-033000.sql.gz');
    Storage::disk('offsite')->assertExists('ivoirepedia/db-ivoirepedia_prod-20261127-033000.sql.gz');
    Storage::disk('offsite')->assertMissing('ivoirepedia/db-ivoirepedia_prod-20261126-033000.sql.gz');

    // Une base de développement ne doit pas pouvoir évincer la production.
    Storage::disk('offsite')->assertExists('ivoirepedia/media-ivoirepedia_prod-20261128-033000.tar.gz');

    dropOffsiteDir($dir);
});

it('ne réenvoie pas une archive déjà présente à la même taille', function () {
    Storage::fake('offsite');
    $dir = offsiteDir();
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261128-033000.sql.gz');

    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => 'offsite',
        'backup.offsite.prefix' => 'ivoirepedia',
        'backup.offsite.keep' => 30,
    ]);

    $offsite = OffsiteBackups::fromConfig();
    expect($offsite)->not->toBeNull();

    $first = $offsite->sync();
    $second = $offsite->sync();

    expect($first['uploaded'])->toHaveCount(1)
        ->and($second['uploaded'])->toBeEmpty();

    dropOffsiteDir($dir);
});

it('renvoie une archive dont la taille locale a changé', function () {
    Storage::fake('offsite');
    $dir = offsiteDir();
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261128-033000.sql.gz');

    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => 'offsite',
        'backup.offsite.prefix' => 'ivoirepedia',
        'backup.offsite.keep' => 30,
    ]);

    OffsiteBackups::fromConfig()?->sync();
    file_put_contents($dir.'/db-ivoirepedia_prod-20261128-033000.sql.gz', str_repeat('y', 128));

    expect(OffsiteBackups::fromConfig()?->pending())->toHaveCount(1);

    dropOffsiteDir($dir);
});

it('dit clairement qu’aucun disque n’est configuré', function () {
    Storage::fake('offsite');
    config(['backup.offsite.disk' => null]);

    expect(OffsiteBackups::enabled())->toBeFalse()
        ->and(OffsiteBackups::fromConfig())->toBeNull();

    $this->artisan('backup:offsite')->assertExitCode(1);
});
