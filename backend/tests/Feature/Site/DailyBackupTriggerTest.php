<?php

use App\Http\Middleware\TriggerDailyBackup;
use App\Support\DailyBackup;
use Illuminate\Foundation\Http\Kernel;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * Le déclencheur ne fait rien pendant la requête et une seule chose après.
 */
it('ne s’accroche qu’aux pages publiques, jamais aux appels d’API', function () {
    $groups = app(Kernel::class)->getMiddlewareGroups();

    expect($groups['web'])->toContain(TriggerDailyBackup::class)
        ->and($groups['api'])->not->toContain(TriggerDailyBackup::class);
});
it('sauvegarde après la réponse, jamais pendant', function () {
    $dir = sys_get_temp_dir().DIRECTORY_SEPARATOR.'ivp-trigger-'.bin2hex(random_bytes(4));
    mkdir($dir, 0750, true);
    $calls = 0;

    $backup = new DailyBackup($dir, function () use (&$calls): int {
        $calls++;

        return 0;
    });
    $middleware = new TriggerDailyBackup($backup);

    $response = $middleware->handle(
        Request::create('/api/v1/health', 'GET'),
        fn (): Response => new Response('ok', 200),
    );

    expect($response->getStatusCode())->toBe(200)
        ->and($calls)->toBe(0);

    $this->app->terminate();

    expect($calls)->toBe(1);

    // Une deuxième visite le même jour ne resauvegarde pas.
    $middleware->handle(Request::create('/api/v1/health', 'GET'), fn (): Response => new Response('ok'));
    $this->app->terminate();

    expect($calls)->toBe(1);

    foreach (glob($dir.DIRECTORY_SEPARATOR.'*') ?: [] as $file) {
        @unlink($file);
    }
    foreach (glob($dir.DIRECTORY_SEPARATOR.'.*') ?: [] as $file) {
        if (! in_array(basename($file), ['.', '..'], true)) {
            @unlink($file);
        }
    }
    @rmdir($dir);
});
