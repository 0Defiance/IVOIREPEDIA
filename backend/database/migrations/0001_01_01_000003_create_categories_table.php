<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Catégories — arborescence (parent_id auto-référent) — CONTEXT §8.2.
 * La colonne s'appelle `position` et non `order` : mot réservé MySQL.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('name', 100)->unique('uniq_categories_name');
            $table->string('slug', 120)->unique('uniq_categories_slug');
            $table->text('description')->nullable();
            $table->integer('position')->default(0);
            $table->char('parent_id', 36)->nullable();
            $table->timestamps();

            $table->index('parent_id', 'idx_categories_parent');
            $table->foreign('parent_id')->references('id')->on('categories');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};
