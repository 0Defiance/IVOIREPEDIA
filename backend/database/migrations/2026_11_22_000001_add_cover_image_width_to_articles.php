<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Largeur d'origine de la photo de couverture.
 *
 * Elle permet à l'API de servir la variante Wikimedia qui ne dépasse pas le
 * fichier source : le zaouli ne fait que 681 px de large, la variante
 * 960 px l'agrandissait et pesait presque 2,5 fois l'original (312 Ko
 * contre 127 Ko). Les quatre photos de couverture sont renseignées ici ;
 * les autres suivent via `articles:attach-images`.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->unsignedInteger('cover_image_width')->nullable()
                ->after('cover_image_url');
        });

        $widths = [
            'le-zaouli' => 681,
            'grand-bassam' => 3840,
            'man' => 4424,
            'korhogo' => 4624,
        ];

        foreach ($widths as $slug => $width) {
            DB::table('articles')
                ->where('slug', $slug)
                ->update(['cover_image_width' => $width]);
        }
    }

    public function down(): void
    {
        Schema::table('articles', function (Blueprint $table) {
            $table->dropColumn('cover_image_width');
        });
    }
};
