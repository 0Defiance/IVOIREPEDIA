<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Médias (images, audio) — CONTEXT §8.2.
 * `path` est la clé de stockage sur disque local (Phase 1) : pas de dépendance
 * à un service externe. `alt` est obligatoire (accessibilité, ENF-UX-04).
 * Pas de updated_at : un fichier déposé ne se "modifie" pas.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('article_id', 36);
            $table->string('type', 10); // enum PHP MediaType (IMAGE | AUDIO)
            $table->string('path', 500);
            $table->string('alt', 255);
            $table->string('credit', 255)->nullable();
            $table->string('license', 100)->nullable();
            $table->unsignedInteger('size_bytes')->nullable();
            $table->timestamp('created_at')->nullable();

            $table->foreign('article_id')->references('id')->on('articles')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media');
    }
};
