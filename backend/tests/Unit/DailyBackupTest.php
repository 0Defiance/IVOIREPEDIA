<?php

use App\Support\DailyBackup;
use Tests\TestCase;

/*
 * Ces cas ont besoin de l'application : le service journalise un échec (Log) et
 * l'exécuteur par défaut passe par Artisan.
 */
uses(TestCase::class);

/**
 * Sauvegarde déclenchée par une visite : une par jour, pas une par requête.
 */
function dailyBackupDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-daily-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

function dropDailyBackupDir(string $dir): void
{
    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $file) {
        @unlink($file);
    }
    foreach (glob($dir.DIRECTORY_SEPARATOR.'.*') ?: [] as $file) {
        if (! in_array(basename($file), ['.', '..'], true)) {
            @unlink($file);
        }
    }
    @rmdir($dir);
}

it('sauvegarde dès qu’aucun repère n’existe', function () {
    $dir = dailyBackupDir();
    $calls = 0;
    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 0;
    });

    expect($backup->due())->toBeTrue()
        ->and($backup->runIfDue())->toBeTrue()
        ->and($calls)->toBe(1)
        // Le déclencheur ne s'attribue pas le succès : seule la fin réelle du
        // dump écrit le repère, lui ne pose qu'une réservation.
        ->and(file_exists($dir.'/'.DailyBackup::PENDING))->toBeTrue()
        ->and(file_exists($dir.'/'.DailyBackup::MARKER))->toBeFalse();

    dropDailyBackupDir($dir);
});

it('ne se relance pas dans la journée quand le dump a abouti', function () {
    $dir = dailyBackupDir();
    $now = 1_790_000_000;
    $calls = 0;
    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 0;
    });

    $backup->runIfDue($now);
    // `backup:run` détaché a terminé : il écrit le repère et lève la réservation.
    touch($dir.'/'.DailyBackup::MARKER, $now);
    unlink($dir.'/'.DailyBackup::PENDING);

    expect($backup->due($now + 3600))->toBeFalse()
        ->and($backup->runIfDue($now + 3600))->toBeFalse()
        ->and($calls)->toBe(1)
        ->and($backup->due($now + 86400))->toBeTrue();

    dropDailyBackupDir($dir);
});

it('retente une heure plus tard quand aucun dump n’est apparu', function () {
    $dir = dailyBackupDir();
    $now = 1_790_000_000;
    $calls = 0;
    // Le processus détaché meurt sans rien écrire : seule la réservation existe.
    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 0;
    });

    expect($backup->runIfDue($now))->toBeTrue()
        ->and($backup->due($now + 60))->toBeFalse()
        ->and($backup->due($now + 3599))->toBeFalse()
        ->and($backup->due($now + 3600))->toBeTrue()
        ->and($backup->runIfDue($now + 3700))->toBeTrue()
        ->and($calls)->toBe(2);

    dropDailyBackupDir($dir);
});

it('réessaie une heure après un échec sans marteler les visites suivantes', function () {
    $dir = dailyBackupDir();
    $now = 1_790_000_000;
    $calls = 0;
    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 1;
    });

    expect($backup->runIfDue($now))->toBeTrue()
        ->and($backup->due($now + 60))->toBeFalse()
        ->and($backup->due($now + 3601))->toBeTrue();

    dropDailyBackupDir($dir);
});

it('réserve le lancement avant de démarrer, pour ne pas le lancer deux fois', function () {
    $dir = dailyBackupDir();
    $reservedAtLaunch = false;

    $backup = new DailyBackup($dir, function () use ($dir, &$reservedAtLaunch): int {
        // La réservation doit déjà être posée quand le dump démarre : c'est ce
        // qui empêche une deuxième requête de le lancer en parallèle.
        $reservedAtLaunch = file_exists($dir.'/'.DailyBackup::PENDING);

        return 0;
    });

    expect($backup->runIfDue())->toBeTrue()
        ->and($reservedAtLaunch)->toBeTrue()
        ->and($backup->runIfDue())->toBeFalse();

    dropDailyBackupDir($dir);
});

it('laisse la main quand le verrou est déjà pris', function () {
    $dir = dailyBackupDir();
    $lock = fopen($dir.'/.backup.lock', 'c');
    flock($lock, LOCK_EX | LOCK_NB);

    $calls = 0;
    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 0;
    });

    expect($backup->runIfDue())->toBeFalse()
        ->and($calls)->toBe(0);

    flock($lock, LOCK_UN);
    fclose($lock);
    dropDailyBackupDir($dir);
});
