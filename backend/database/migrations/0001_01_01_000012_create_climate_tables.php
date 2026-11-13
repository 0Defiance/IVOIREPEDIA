<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Climatologie des villes — normales 1991-2020.
 *
 * Les valeurs viennent de la réanalyse ERA5 (service Copernicus, diffusée par
 * Open-Meteo, licence CC BY 4.0) et sont figées dans
 * `database/data/climate-normals.json` : l'import ne dépend pas du réseau.
 *
 * Trois tables parce que trois lectures différentes : une ville (identité et
 * moyenne annuelle), ses douze normales mensuelles (le régime des pluies) et
 * ses trente années (la variabilité d'une année sur l'autre).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('climate_cities', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('slug', 140)->unique();
            $table->string('name', 120);
            $table->decimal('latitude', 8, 4);
            $table->decimal('longitude', 8, 4);
            $table->decimal('annual_rain_mm', 7, 1);
            $table->unsignedSmallInteger('period_start');
            $table->unsignedSmallInteger('period_end');
            $table->string('source_name', 160);
            $table->string('source_url', 300)->nullable();
            $table->string('source_licence', 80)->nullable();
            $table->unsignedSmallInteger('position')->default(0);
            $table->timestamps();
        });

        Schema::create('climate_months', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('climate_city_id', 36);
            $table->unsignedTinyInteger('month');
            $table->decimal('rain_mm', 6, 1);
            $table->decimal('rain_days', 4, 1)->nullable();
            $table->decimal('temperature_c', 4, 1)->nullable();
            $table->timestamps();

            $table->unique(['climate_city_id', 'month'], 'uniq_climate_month');
            $table->foreign('climate_city_id')
                ->references('id')->on('climate_cities')->cascadeOnDelete();
        });

        Schema::create('climate_years', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('climate_city_id', 36);
            $table->unsignedSmallInteger('year');
            $table->decimal('rain_mm', 7, 1);
            $table->timestamps();

            $table->unique(['climate_city_id', 'year'], 'uniq_climate_year');
            $table->foreign('climate_city_id')
                ->references('id')->on('climate_cities')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('climate_years');
        Schema::dropIfExists('climate_months');
        Schema::dropIfExists('climate_cities');
    }
};
