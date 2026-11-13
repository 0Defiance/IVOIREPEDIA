<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Récits d'histoire — section « Histoire incroyable ».
 *
 * Chaque récit est court, daté et adossé à un document : fiche du patrimoine
 * mondial, élément du patrimoine culturel immatériel, site institutionnel. Le
 * texte est stocké en paragraphes (JSON) pour rester lisible côté API et côté
 * application, sans passer par l'éditeur d'articles.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('history_stories', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('slug', 140)->unique();
            $table->string('title', 180);
            $table->string('period', 90)->nullable();
            $table->string('teaser', 400);
            $table->json('paragraphs');
            $table->json('figures')->nullable();
            $table->string('source_title', 220);
            $table->string('source_publisher', 160)->nullable();
            $table->unsignedSmallInteger('source_year')->nullable();
            $table->string('source_url', 300);
            $table->unsignedSmallInteger('position')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('history_stories');
    }
};
