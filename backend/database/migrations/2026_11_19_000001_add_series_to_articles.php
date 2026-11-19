<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Série éditoriale d'un article (CONTEXT §8.2).
 *
 * Une série — par exemple « villes » pour les fiches de villes du RGPH 2021 —
 * est produite par un seeder qui doit pouvoir la remettre à jour sans jamais
 * réécrire un article écrit à la main. La colonne porte ce marquage : seuls les
 * articles qui la portent sont rafraîchis par leur seeder.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->string('series', 40)->nullable()->after('type');
            $table->index('series', 'idx_articles_series');
        });
    }

    public function down(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->dropIndex('idx_articles_series');
            $table->dropColumn('series');
        });
    }
};
