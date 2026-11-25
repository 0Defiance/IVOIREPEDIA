<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Anciens slugs conservés en redirection permanente.
 *
 * Un slug public ne change qu'exceptionnellement (nom affiché corrigé, comme
 * `augustin-denise-djore` devenu `auguste-denise`). L'ancienne adresse reste
 * alors connue : elle est conservée ici pour être redirigée en 301 vers
 * l'adresse actuelle, au lieu de tomber en 404 pour les liens déjà partagés.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('article_slug_redirects', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('old_slug')->unique();
            $table->string('new_slug');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_slug_redirects');
    }
};
