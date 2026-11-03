<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Versions d'article — journal append-only des jalons (ADR-005) — CONTEXT §8.2.
 * Pas de updated_at : une version est immuable.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('article_versions', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('article_id', 36);
            $table->integer('number');
            $table->string('title', 255);
            $table->string('summary', 500);
            $table->json('content');
            // SHA-256 du JSON canonique : détecte une altération de version.
            $table->char('content_hash', 64);
            $table->char('author_id', 36);
            $table->string('reason', 255)->nullable();
            $table->timestamp('created_at')->nullable();

            $table->unique(['article_id', 'number'], 'uniq_version');
            $table->foreign('article_id')->references('id')->on('articles')->onDelete('cascade');
            $table->foreign('author_id')->references('id')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_versions');
    }
};
