<?php

use App\Http\Controllers\Api\V1\ArticleController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\ContactController;
use App\Http\Controllers\Api\V1\HistoryController;
use App\Http\Controllers\Api\V1\PlaceController;
use App\Http\Controllers\Api\V1\SearchController;
use App\Http\Controllers\Api\V1\SourcesController;
use App\Http\Controllers\Api\V1\StatisticsController;
use App\Http\Controllers\Api\V1\SuggestController;
use App\Http\Controllers\Api\V1\TimelineController;
use Illuminate\Support\Facades\Route;

/**
 * API publique IVOIREPEDIA — préfixe /api/v1 posé par bootstrap/app.php.
 * Sprint 0 : health. Sprint 4 (lecture publique) : catégories, articles,
 * recherche. L'authentification arrive au Sprint 1 et les écritures au
 * Sprint 2 ; cf. CONTEXT §11 pour le contrat complet.
 */
Route::prefix('v1')->group(function () {
    // « hello world » du Sprint 0 : prouve que l'API répond en JSON.
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'service' => 'ivoirepedia-api',
            'version' => 'v1',
        ]);
    });

    // Comptes de lecteurs (Sprint 1) : inscription, connexion, profil et
    // déconnexion. Les routes privées exigent un jeton porteur.
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

        // Réinitialisation : la demande est plafonnée pour éviter l'envoi en
        // masse de courriels, la consommation l'est pour freiner les essais.
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])
            ->middleware('throttle:5,1');
        Route::post('/reset-password', [AuthController::class, 'resetPassword'])
            ->middleware('throttle:10,1');

        Route::middleware('auth.token')->group(function () {
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    Route::get('/categories', CategoryController::class);

    // Statistiques publiques du pays : indicateurs annuels, recensement et
    // climatologie des villes.
    Route::get('/statistics', StatisticsController::class);

    // Récits sourcés de la section « Histoire incroyable » et frise
    // chronologique construite à partir de ces mêmes récits.
    Route::get('/history', HistoryController::class);
    Route::get('/timeline', TimelineController::class);

    // Fiches géographiques (districts, régions, villes du RGPH 2021).
    Route::get('/places', [PlaceController::class, 'index']);
    Route::get('/places/{slug}', [PlaceController::class, 'show']);

    // Bibliothèque des sources : toutes les références des articles publiés,
    // regroupées par institution.
    Route::get('/sources', SourcesController::class);

    Route::get('/articles', [ArticleController::class, 'index']);
    // Avant `{slug}` : sinon « random » serait lu comme un titre d'article.
    Route::get('/articles/random', [ArticleController::class, 'random']);
    Route::get('/articles/{slug}', [ArticleController::class, 'show']);

    // Recherche publique : plafonnée pour éviter le balayage de table (429).
    Route::middleware('throttle:60,1')->get('/search', SearchController::class);
    Route::middleware('throttle:120,1')->get('/search/suggest', SuggestController::class);

    // Formulaire de contact : le message est stocké pour le panneau éditorial.
    Route::middleware('throttle:5,1')->post('/contact', ContactController::class);
});
