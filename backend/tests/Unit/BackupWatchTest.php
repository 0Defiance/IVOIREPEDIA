<?php

use App\Mail\BackupStale;
use App\Support\BackupWatch;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

/*
 * Ces cas ont besoin de l'application : courriel (Mail) et configuration.
 */
uses(TestCase::class);

function watchDir(): string
{
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-watch-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);

    return $dir;
}

function watchDump(string $dir, int $at, string $database = 'ivoirepedia_prod'): string
{
    $name = 'db-'.$database.'-'.gmdate('Ymd-His', $at).'.sql.gz';
    file_put_contents($dir.DIRECTORY_SEPARATOR.$name, 'dump');

    return $name;
}

function dropWatchDir(string $dir): void
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

it('alerte quand le dernier dump a plus de 36 h', function () {
    Mail::fake();
    $dir = watchDir();
    $now = 1_790_000_000;
    watchDump($dir, $now - 40 * 3600);

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', 'admin@example.test');

    expect($watch->stale($now))->toBeTrue()
        ->and($watch->age($now))->toBe(40 * 3600)
        ->and($watch->alertIfStale($now))->toBeTrue();

    Mail::assertSentCount(1);
    Mail::assertSent(BackupStale::class, fn (BackupStale $mail): bool => $mail->database === 'ivoirepedia_prod'
        && $mail->age === 40 * 3600
        && $mail->after === 129600
        && $mail->hasTo('admin@example.test'));

    dropWatchDir($dir);
});

it('n’alerte pas tant qu’un dump a moins de 36 h', function () {
    Mail::fake();
    $dir = watchDir();
    $now = 1_790_000_000;
    watchDump($dir, $now - 35 * 3600);

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', 'admin@example.test');

    expect($watch->stale($now))->toBeFalse()
        ->and($watch->alertIfStale($now))->toBeFalse();

    Mail::assertNothingSent();

    dropWatchDir($dir);
});

it('alerte quand aucun dump n’existe du tout', function () {
    Mail::fake();
    $dir = watchDir();

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', 'admin@example.test');

    expect($watch->age())->toBeNull()
        ->and($watch->stale())->toBeTrue()
        ->and($watch->alertIfStale())->toBeTrue();

    Mail::assertSentCount(1);

    dropWatchDir($dir);
});

it('n’envoie qu’une alerte par jour', function () {
    Mail::fake();
    $dir = watchDir();
    $now = 1_790_000_000;
    watchDump($dir, $now - 48 * 3600);

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', 'admin@example.test');

    expect($watch->alertIfStale($now))->toBeTrue()
        ->and($watch->alertIfStale($now + 3600))->toBeFalse()
        ->and($watch->alertIfStale($now + 86401))->toBeTrue();

    Mail::assertSentCount(2);

    dropWatchDir($dir);
});

it('journalise sans destinataire mais n’envoie rien', function () {
    Mail::fake();
    $dir = watchDir();
    $now = 1_790_000_000;
    watchDump($dir, $now - 40 * 3600);

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', null);

    expect($watch->alertIfStale($now))->toBeFalse();
    Mail::assertNothingSent();

    dropWatchDir($dir);
});

it('ignore le dump d’une autre base', function () {
    Mail::fake();
    $dir = watchDir();
    $now = 1_790_000_000;
    // Seul ivoirepedia_dev a été sauvegardé : la production n'a rien.
    watchDump($dir, $now - 3600, 'ivoirepedia_dev');

    $watch = new BackupWatch($dir, 'ivoirepedia_prod', 'admin@example.test');

    expect($watch->age($now))->toBeNull()
        ->and($watch->stale($now))->toBeTrue();

    dropWatchDir($dir);
});
