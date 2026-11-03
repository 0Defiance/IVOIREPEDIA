<?php

use Illuminate\Support\Facades\Route;

/**
 * API publique IVOIREPEDIA — préfixe /api/v1 posé par bootstrap/app.php.
 * Les routes concrètes arrivent au Sprint 1 (auth) et Sprint 2 (articles) ;
 * cf. CONTEXT §11 pour le contrat complet.
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
});
