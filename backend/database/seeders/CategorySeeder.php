<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Catégories de départ — la racine de l'arborescence éditoriale (CONTEXT §14,
 * Sprint 0). On part des grands domaines du cahier des charges ; la hiérarchie
 * fine sera enrichie par l'équipe éditoriale ensuite.
 */
class CategorySeeder extends Seeder
{
    /** @var array<int, string> */
    private const CATEGORIES = [
        'Histoire',
        'Géographie',
        'Personnalités',
        'Institutions',
        'Langues',
        'Culture',
        'Économie',
        'Patrimoine',
    ];

    public function run(): void
    {
        $now = now()->toDateTimeString();

        foreach (self::CATEGORIES as $position => $name) {
            DB::table('categories')->updateOrInsert(
                ['slug' => Str::slug($name)],
                [
                    'id' => (string) Str::uuid(),
                    'name' => $name,
                    'description' => null,
                    'position' => $position,
                    'parent_id' => null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
            );
        }
    }
}
