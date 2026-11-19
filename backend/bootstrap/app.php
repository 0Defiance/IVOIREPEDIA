<?php

use App\Http\Middleware\AuthenticateApiToken;
use App\Http\Middleware\EnsureEditorialAccess;
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
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
