<?php

use App\Support\OffsiteBackups;
use Illuminate\Filesystem\FilesystemAdapter;
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
    foreach (glob($dir.DIRECTORY_SEPARATOR.'.[a-z]*') ?: [] as $file) {
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

it('n’écrit le repère de dernière copie que si un envoi a réellement réussi', function () {
    Storage::fake('offsite');
    $dir = offsiteDir();
    offsiteArchive($dir, 'db-ivoirepedia_prod-20261128-063424.sql.gz');

    config([
        'backup.directory' => $dir,
        'backup.offsite.prefix' => 'ivoirepedia',
        'backup.offsite.keep' => 30,
    ]);

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

    config(['backup.offsite.disk' => 'offsite-fail']);

    $failed = OffsiteBackups::fromConfig();
    expect($failed)->not->toBeNull()
        ->and($failed?->sync()['uploaded'])->toBeEmpty()
        // Aucun repère : une copie manquée ne doit pas se dater.
        ->and(file_exists($dir.'/.last-offsite'))->toBeFalse()
        ->and(OffsiteBackups::copiedAt($dir))->toBeNull();

    // Même archive, disque qui fonctionne : l'envoi est confirmé, le repère apparaît.
    config(['backup.offsite.disk' => 'offsite']);

    $sent = OffsiteBackups::fromConfig();
    expect($sent?->sync()['uploaded'])->toHaveCount(1)
        ->and(Storage::disk('offsite')->exists('ivoirepedia/db-ivoirepedia_prod-20261128-063424.sql.gz'))->toBeTrue()
        ->and(OffsiteBackups::copiedAt($dir))->not->toBeNull();

    // Rien de neuf à envoyer : le repère dit « dernière copie », pas « dernier passage ».
    $at = (int) OffsiteBackups::copiedAt($dir);
    @touch($dir.'/.last-offsite', $at - 3600);

    expect(OffsiteBackups::fromConfig()?->sync()['uploaded'])->toBeEmpty()
        ->and(OffsiteBackups::copiedAt($dir))->toBe($at - 3600);

    dropOffsiteDir($dir);
});

it('dit clairement qu’aucun disque n’est configuré', function () {
    Storage::fake('offsite');
    config(['backup.offsite.disk' => null]);

    expect(OffsiteBackups::enabled())->toBeFalse()
        ->and(OffsiteBackups::fromConfig())->toBeNull();

    $this->artisan('backup:offsite')->assertExitCode(1);
});
