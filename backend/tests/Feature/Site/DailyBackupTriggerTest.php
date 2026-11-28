<?php

use App\Http\Middleware\TriggerDailyBackup;
use App\Support\DailyBackup;
use Illuminate\Foundation\Http\Kernel;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * Le déclencheur ne fait rien pendant la requête et une seule chose après.
 */
it('s’accroche à toutes les requêtes : une journée peut n’avoir que de l’API', function () {
    // Le 28 novembre 2026, le déclencheur restreint au groupe `web` laissait
    // passer une journée entière sans sauvegarde quand personne n'ouvrait
    // d'article. Le dump est maintenant détaché, donc l'appelant ne le paie pas.
    expect(app(Kernel::class)->getGlobalMiddleware())->toContain(TriggerDailyBackup::class);
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
