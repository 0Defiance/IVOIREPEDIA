<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Jetons d'API personnels (Sprint 1 — authentification).
 *
 * Le porteur reçoit un jeton en clair une seule fois ; la base n'en garde que
 * l'empreinte SHA-256. Un vol de la table ne donne donc aucun accès.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('api_tokens', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('user_id', 36);
            $table->string('name', 60)->default('web');
            $table->char('token_hash', 64)->unique('uniq_api_tokens_hash');
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index('user_id', 'idx_api_tokens_user');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('api_tokens');
    }
};
