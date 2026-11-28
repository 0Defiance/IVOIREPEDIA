<?php

use App\Console\Commands\BackupRun;
use App\Support\DailyBackup;
use Illuminate\Filesystem\FilesystemAdapter;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Output\BufferedOutput;

/**
 * Une copie hors-site qui échoue ne doit pas passer pour une sauvegarde réussie :
 * le repère du jour reste en échec, donc la tentative revient dans l'heure — et
 * le dump local, lui, n'est jamais supprimé.
 */
function backupRunDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-run-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

function dropBackupRunDir(string $dir): void
{
    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $file) {
        @unlink($file);
    }
    foreach (glob($dir.DIRECTORY_SEPARATOR.'.[a-z]*') ?: [] as $file) {
        @unlink($file);
    }
    @rmdir($dir);
}

it('laisse le repère en échec quand la copie hors-site échoue, et retente dans l’heure', function () {
    Storage::fake('offsite');

    // Disque qui accepte la connexion mais n'enregistre rien : l'envoi échoue.
    $real = Storage::disk('offsite');
    $failing = new class($real->getDriver(), $real->getAdapter()) extends FilesystemAdapter
    {
        public function __construct($driver, $adapter)
        {
            parent::__construct($driver, $adapter);
        }

        public function writeStream($path, $resource, array $options = [])
        {
            return false;
        }

        public function exists($path)
        {
            return false;
        }
    };
    Storage::set('offsite-fail', $failing);

    $dir = backupRunDir();
    config([
        'backup.directory' => $dir,
        'backup.offsite.disk' => 'offsite-fail',
        'backup.offsite.prefix' => 'ivoirepedia',
        'backup.offsite.keep' => 30,
    ]);

    // Dump simulé : le vrai `mysqldump` n'existe pas sur le poste de test.
    $command = new class extends BackupRun
    {
        protected function dumpDatabase(string $credentials, string $database, string $dump): bool
        {
            file_put_contents($dump, 'dump-simule');

            return true;
        }
    };
    $command->setLaravel(app());

    $output = new BufferedOutput;
    $status = $command->run(new ArrayInput([
        '--dir' => $dir,
        '--keep' => '1',
        '--skip-media' => true,
        '--database' => 'ivoirepedia_prod',
    ]), $output);

    expect($status)->toBe(BackupRun::FAILURE)
        ->and($output->fetch())->toContain('Copie hors-site impossible');

    // Repère antidaté de « un intervalle moins une heure » : la retentative tombe dans l'heure.
    $marker = $dir.'/'.DailyBackup::MARKER;
    expect(file_exists($marker))->toBeTrue()
        ->and(file_exists($dir.'/'.DailyBackup::PENDING))->toBeFalse();

    $markerAt = (int) filemtime($marker);
    $age = time() - $markerAt;
    expect($age)->toBeGreaterThan(86400 - 3600 - 5)
        ->and($age)->toBeLessThan(86400);

    $backup = new DailyBackup($dir, fn (): int => 0);
    // Le repère antidaté de 23 h fait tomber la retentative une heure après l'échec.
    expect($backup->due($markerAt + 86399))->toBeFalse()   // 59 min 59 s : rien
        ->and($backup->due($markerAt + 86400))->toBeTrue(); // 1 h : on retente

    // L'échec de l'envoi ne supprime jamais le dump local.
    expect(glob($dir.'/db-ivoirepedia_prod-*.sql.gz'))->toHaveCount(1);

    expect(Storage::disk('offsite')->allFiles())->toBeEmpty();

    dropBackupRunDir($dir);
});
