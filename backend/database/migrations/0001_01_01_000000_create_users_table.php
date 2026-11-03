<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Utilisateurs et jetons de vérification — schéma de référence CONTEXT §8.2.
 * Les UUID sont stockés en CHAR(36) ; le hash bcrypt vit dans password_hash
 * (jamais un mot de passe en clair).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('name', 100);
            $table->string('email', 255)->unique('uniq_users_email');
            $table->string('password_hash', 255);
            $table->string('role', 20)->default('READER'); // enum PHP Role (Sprint 1)
            $table->timestamp('email_verified_at')->nullable();
            $table->string('bio', 500)->nullable();
            $table->string('avatar_url', 500)->nullable();
            $table->timestamp('suspended_at')->nullable();
            $table->timestamps();
        });

        Schema::create('verification_tokens', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('user_id', 36);
            $table->string('type', 20); // EMAIL_VERIFY | PASSWORD_RESET
            // On persiste uniquement le hash (SHA-256) : un vol de base ne donne
            // aucun jeton utilisable.
            $table->char('token_hash', 64)->unique('uniq_tokens_hash');
            $table->timestamp('expires_at');
            $table->timestamp('used_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'type'], 'idx_tokens_user_type');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->char('user_id', 36)->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->text('payload');
            $table->integer('last_activity')->index();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('verification_tokens');
        Schema::dropIfExists('users');
    }
};
