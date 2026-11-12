<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Divisions administratives du recensement — RGPH 2021.
 *
 * Une ligne par district et par région, avec les effectifs publiés : hommes,
 * femmes, total, ménages et taille moyenne des ménages. Les villes chef-lieu
 * sont conservées au même endroit (`level = city`) parce qu'elles se lisent
 * dans le même tableau officiel et servent d'infobox aux articles de villes.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('census_divisions', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('level', 12); // district | region | city
            $table->string('name', 120);
            $table->string('slug', 140);
            $table->string('parent', 120)->nullable();
            $table->unsignedInteger('population');
            $table->unsignedInteger('men')->nullable();
            $table->unsignedInteger('women')->nullable();
            $table->unsignedInteger('households')->nullable();
            $table->decimal('average_size', 4, 1)->nullable();
            $table->unsignedSmallInteger('position')->default(0);
            $table->timestamps();

            $table->unique(['level', 'slug'], 'uniq_divisions_level_slug');
            $table->index('level', 'idx_divisions_level');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('census_divisions');
    }
};
