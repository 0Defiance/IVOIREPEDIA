<?php

use App\Support\BackupRetention;

/**
 * Rétention des sauvegardes : chaque base garde les siennes.
 *
 * C'est la règle qui empêche un lot de sauvegardes de `ivoirepedia_dev` — un
 * essai de restauration, par exemple — d'évincer le dernier dump de production.
 */

/** Dossier temporaire propre à un test. */
function backupTestDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-backup-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

/** @param  list<string>  $files */
function dropBackupTestDir(string $dir, array $files = []): void
{
    foreach ($files as $file) {
        @unlink($file);
    }
    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $leftover) {
        @unlink($leftover);
    }
    @rmdir($dir);
}

it('nomme un dump avec sa base et son horodatage', function () {
    expect(BackupRetention::path('/tmp/backups', 'db', 'ivoirepedia_prod', '20261128-033000'))
        ->toBe('/tmp/backups/db-ivoirepedia_prod-20261128-033000.sql.gz')
        ->and(BackupRetention::path('/tmp/backups/', 'media', 'ivoirepedia_dev', '20261128-033000'))
        ->toBe('/tmp/backups/media-ivoirepedia_dev-20261128-033000.tar.gz');
});

it('nettoie un nom de base qui ne peut pas figurer dans un fichier', function () {
    expect(BackupRetention::label(':memory:'))->toBe('memory')
        ->and(BackupRetention::label('../etc'))->toBe('etc')
        ->and(BackupRetention::label(''))->toBe('base');
});

it('ne retient que les sauvegardes de la base demandée', function () {
    $dir = backupTestDir();
    $files = [];
    foreach (['ivoirepedia_prod', 'ivoirepedia_dev'] as $database) {
        foreach (['20261126', '20261127', '20261128'] as $day) {
            $path = BackupRetention::path($dir, 'db', $database, $day.'-033000');
            touch($path);
            $files[] = $path;
        }
    }

    $dev = BackupRetention::candidates($dir, 'ivoirepedia_dev');
    $prod = BackupRetention::candidates($dir, 'ivoirepedia_prod');

    expect($dev)->toHaveCount(3)
        ->and($dev[0])->toEndWith('db-ivoirepedia_dev-20261128-033000.sql.gz')
        ->and(implode(' ', $dev))->not->toContain('ivoirepedia_prod')
        ->and($prod)->toHaveCount(3)
        ->and(implode(' ', $prod))->not->toContain('ivoirepedia_dev');

    dropBackupTestDir($dir, $files);
});

it('purge une base sans jamais toucher aux dumps des autres', function () {
    $dir = backupTestDir();
    $prod = BackupRetention::path($dir, 'db', 'ivoirepedia_prod', '20261125-033000');
    $devOld = BackupRetention::path($dir, 'db', 'ivoirepedia_dev', '20261127-033000');
    $devNew = BackupRetention::path($dir, 'db', 'ivoirepedia_dev', '20261128-033000');
    foreach ([$prod, $devOld, $devNew] as $file) {
        touch($file);
    }

    // La base de dev ne garde qu'une paire : c'est la plus ancienne qui part.
    $expired = BackupRetention::expired(BackupRetention::candidates($dir, 'ivoirepedia_dev'), 1);

    expect($expired)->toBe([$devOld])
        ->and(file_exists($prod))->toBeTrue()
        ->and(BackupRetention::candidates($dir, 'ivoirepedia_prod'))->toBe([$prod]);

    dropBackupTestDir($dir, [$prod, $devOld, $devNew]);
});

it('garde tout tant que le quota n’est pas dépassé', function () {
    $dir = backupTestDir();
    $files = [];
    foreach (['20261126', '20261127', '20261128'] as $day) {
        $files[] = BackupRetention::path($dir, 'media', 'ivoirepedia_prod', $day.'-033000');
        touch(end($files));
    }

    expect(BackupRetention::expired(BackupRetention::candidates($dir, 'ivoirepedia_prod', 'media'), 7))
        ->toBe([])
        // Les médias d'une base ne sont pas comptés avec ses dumps.
        ->and(BackupRetention::candidates($dir, 'ivoirepedia_prod', 'db'))->toBe([]);

    dropBackupTestDir($dir, $files);
});
