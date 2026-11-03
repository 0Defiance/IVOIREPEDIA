<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tags et leur pivot avec les articles — CONTEXT §8.2.
 * La table pivot s'appelle `article_tag` (convention Laravel belongsToMany).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tags', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('name', 100)->unique('uniq_tags_name');
            $table->string('slug', 120)->unique('uniq_tags_slug');
            $table->timestamps();
        });

        Schema::create('article_tag', function (Blueprint $table) {
            $table->char('article_id', 36);
            $table->char('tag_id', 36);
            $table->primary(['article_id', 'tag_id']);

            $table->foreign('article_id')->references('id')->on('articles')->onDelete('cascade');
            $table->foreign('tag_id')->references('id')->on('tags')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_tag');
        Schema::dropIfExists('tags');
    }
};
