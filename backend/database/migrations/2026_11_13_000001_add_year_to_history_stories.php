<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Année de référence d'un récit — la frise chronologique.
 *
 * `period` reste le libellé affiché (« 1843-1898 », « XVIIIe siècle »), trop
 * imprécis pour trier. `year` porte l'année de l'événement raconté : elle sert
 * uniquement au classement et n'est jamais présentée comme une date exacte
 * quand la période est large.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('history_stories', function (Blueprint $table) {
            $table->unsignedSmallInteger('year')->nullable()->after('period');
            $table->index('year', 'idx_history_year');
        });
    }

    public function down(): void
    {
        Schema::table('history_stories', function (Blueprint $table) {
            $table->dropIndex('idx_history_year');
            $table->dropColumn('year');
        });
    }
};
