<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Une illustration n'est publiable que si sa provenance l'est aussi : la
 * licence, l'auteur et la page de description accompagnent désormais chaque
 * image de couverture (ENF-UX-04).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->string('cover_image_credit', 255)->nullable()->after('cover_image_alt');
            $table->string('cover_image_license', 60)->nullable()->after('cover_image_credit');
            $table->string('cover_image_source_url', 500)->nullable()->after('cover_image_license');
        });
    }

    public function down(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->dropColumn([
                'cover_image_credit',
                'cover_image_license',
                'cover_image_source_url',
            ]);
        });
    }
};
