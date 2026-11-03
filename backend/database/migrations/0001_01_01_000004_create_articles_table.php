<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Articles — CONTEXT §8.2.
 * `content`/`infobox` sont du JSON (Delta Quill côté Flutter, ADR-003) :
 * aucun HTML n'est stocké. `lock_version` sert au verrou optimiste (§9.4).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('title', 255);
            $table->string('slug', 255)->unique('uniq_articles_slug');
            $table->string('summary', 500);
            $table->json('content');
            $table->json('infobox')->nullable();
            $table->string('type', 20); // enum PHP ArticleType
            $table->string('status', 20)->default('DRAFT'); // enum PHP ArticleStatus
            $table->string('cover_image_url', 500)->nullable();
            // Texte alternatif obligatoire dès qu'une image est présente (ENF-UX-04).
            $table->string('cover_image_alt', 255)->nullable();
            $table->integer('lock_version')->default(0);
            $table->integer('current_version')->default(0);
            $table->char('author_id', 36);
            $table->char('category_id', 36);
            $table->timestamps();
            $table->timestamp('published_at')->nullable();
            $table->softDeletes();

            $table->index(['status', 'published_at'], 'idx_articles_status_published');
            $table->index('category_id', 'idx_articles_category');
            $table->index('author_id', 'idx_articles_author');
            $table->foreign('author_id')->references('id')->on('users');
            $table->foreign('category_id')->references('id')->on('categories');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
