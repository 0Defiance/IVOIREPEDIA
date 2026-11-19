<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Empreintes des champs écrits par un seeder de série (CONTEXT §8.2).
 *
 * Le seeder de la série « villes » n'a le droit de rafraîchir un champ que si
 * la base contient encore ce qu'il y a écrit. `series_state` garde l'empreinte
 * de chaque champ machine : une modification faite depuis `/admin` ne
 * correspond plus à l'empreinte et survit au passage suivant.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->json('series_state')->nullable()->after('series');
        });
    }

    public function down(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->dropColumn('series_state');
        });
    }
};
