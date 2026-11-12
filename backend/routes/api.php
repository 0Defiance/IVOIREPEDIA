<?php

use App\Http\Controllers\Api\V1\ArticleController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\SearchController;
use App\Http\Controllers\Api\V1\StatisticsController;
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

    // Statistiques publiques du pays : indicateurs annuels + recensement.
    Route::get('/statistics', StatisticsController::class);
    Route::get('/articles', [ArticleController::class, 'index']);
    Route::get('/articles/{slug}', [ArticleController::class, 'show']);

    // Recherche publique : plafonnée pour éviter le balayage de table (429).
    Route::middleware('throttle:60,1')->get('/search', SearchController::class);
});
