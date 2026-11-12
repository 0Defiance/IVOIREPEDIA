<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Indicateurs statistiques du pays — page « La Côte d'Ivoire en chiffres ».
 *
 * `country_indicators` porte la dernière valeur connue et la provenance
 * (organisme + URL + licence) : c'est ce qui permet d'afficher un chiffre daté
 * et vérifiable. `country_indicator_points` porte la série annuelle, utilisée
 * pour la courbe de tendance.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('country_indicators', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('code', 60)->unique('uniq_indicators_code');
            $table->string('label', 160);
            $table->string('theme', 40);
            $table->string('unit', 60)->nullable();
            $table->unsignedTinyInteger('decimals')->default(0);
            $table->decimal('value', 22, 4)->nullable();
            $table->string('value_text', 60)->nullable();
            $table->unsignedSmallInteger('year')->nullable();
            $table->string('source_name', 160);
            $table->string('source_url', 500)->nullable();
            $table->string('source_licence', 80)->nullable();
            $table->text('note')->nullable();
            $table->unsignedSmallInteger('position')->default(0);
            $table->timestamps();

            $table->index(['theme', 'position'], 'idx_indicators_theme');
        });

        Schema::create('country_indicator_points', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('indicator_id', 36);
            $table->unsignedSmallInteger('year');
            $table->decimal('value', 22, 4);
            $table->timestamps();

            $table->unique(['indicator_id', 'year'], 'uniq_points_indicator_year');
            $table->foreign('indicator_id')->references('id')->on('country_indicators')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('country_indicator_points');
        Schema::dropIfExists('country_indicators');
    }
};
