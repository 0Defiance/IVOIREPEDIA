<?php

use App\Http\Controllers\Api\V1\ArticleController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\HistoryController;
use App\Http\Controllers\Api\V1\PlaceController;
use App\Http\Controllers\Api\V1\SearchController;
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

    Route::get('/articles', [ArticleController::class, 'index']);
    Route::get('/articles/{slug}', [ArticleController::class, 'show']);

    // Recherche publique : plafonnée pour éviter le balayage de table (429).
    Route::middleware('throttle:60,1')->get('/search', SearchController::class);
    Route::middleware('throttle:120,1')->get('/search/suggest', SuggestController::class);
});
