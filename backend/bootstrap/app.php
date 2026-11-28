<?php

use App\Http\Middleware\AuthenticateApiToken;
use App\Http\Middleware\EnsureEditorialAccess;
use App\Http\Middleware\TriggerDailyBackup;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Un visiteur qui ouvre /admin arrive sur la page de connexion du
        // panneau, pas sur un `route('login')` qui n'existe pas ici.
        $middleware->redirectGuestsTo(fn () => route('admin.login'));

        // Jetons porteurs des comptes de lecteurs (Sprint 1).
        $middleware->alias([
            'auth.token' => AuthenticateApiToken::class,
            // Panneau éditorial : CONTRIBUTOR et au-dessus (CONTEXT §10).
            'editorial' => EnsureEditorialAccess::class,
        ]);

        // Sauvegarde quotidienne : la tâche planifiée du panneau n'existe pas
        // encore (crontab est refusé sur le compte), donc la première visite
        // du jour la déclenche après l'envoi de sa réponse.
        // Voir App\Support\DailyBackup et docs/DEPLOIEMENT.md §8.
        $middleware->append(TriggerDailyBackup::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
