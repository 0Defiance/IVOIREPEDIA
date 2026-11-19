<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Messages envoyés depuis la page « Contact » du site.
 *
 * Le formulaire public est ouvert à tous : il est donc stocké en base plutôt
 * qu'envoyé par courriel, pour rester lisible dans le panneau même quand
 * l'expédition SMTP n'est pas configurée (mode `log` en développement).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('contact_messages', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('name', 80)->nullable();
            $table->string('email', 255)->nullable();
            $table->text('message');
            $table->string('status', 20)->default('NEW');
            $table->timestamp('handled_at')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('contact_messages');
    }
};
