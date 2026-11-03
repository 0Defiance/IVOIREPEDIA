<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Actions éditoriales — CONTEXT §8.2.
 * Table **append-only** : jamais d'UPDATE ni de DELETE (traçabilité, §9).
 * Pas de updated_at : une action historique est immuable.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('editorial_actions', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('article_id', 36);
            $table->char('actor_id', 36);
            $table->string('type', 20); // enum PHP EditorialActionType
            $table->string('from_status', 20)->nullable();
            $table->string('to_status', 20)->nullable();
            $table->text('comment')->nullable();
            $table->timestamp('created_at')->nullable();

            $table->index(['article_id', 'created_at'], 'idx_actions_article');
            $table->foreign('article_id')->references('id')->on('articles')->onDelete('cascade');
            $table->foreign('actor_id')->references('id')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('editorial_actions');
    }
};
