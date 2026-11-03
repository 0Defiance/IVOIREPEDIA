<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Références bibliographiques — CONTEXT §8.2.
 * Nom `article_references` et colonne `position` : `references` et `order`
 * sont des mots réservés MySQL.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('article_references', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('article_id', 36);
            $table->integer('position');
            $table->string('kind', 10)->default('OTHER'); // enum PHP ReferenceKind
            $table->string('authors', 255)->nullable();
            $table->string('title', 255);
            $table->string('publisher', 255)->nullable();
            $table->unsignedSmallInteger('year')->nullable();
            $table->string('url', 500)->nullable();
            $table->date('accessed_at')->nullable();
            $table->text('note')->nullable();

            $table->index(['article_id', 'position'], 'idx_references_article');
            $table->foreign('article_id')->references('id')->on('articles')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_references');
    }
};
