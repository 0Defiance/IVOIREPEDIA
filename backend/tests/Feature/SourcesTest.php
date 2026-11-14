<?php

use Database\Seeders\CategorySeeder;
use Database\Seeders\PublicContentSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Bibliothèque des sources : la page publique doit lister les références des
 * articles publiés, regroupées par institution, sans doublon.
 */
uses(RefreshDatabase::class);

it('liste les sources par institution', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PublicContentSeeder::class);

    $response = $this->getJson('/api/v1/sources');

    $response->assertOk()
        ->assertJsonPath('data.0.name', fn (string $name): bool => $name !== '')
        ->assertJsonStructure([
            'data' => [
                '*' => [
                    'name',
                    'count',
                    'references' => [
                        '*' => ['title', 'year', 'url', 'articles' => ['*' => ['slug', 'title']]],
                    ],
                ],
            ],
            'meta' => ['institutions', 'references', 'mentions', 'articles'],
        ]);

    $data = $response->json('data');

    expect($data)->not->toBeEmpty()
        ->and($response->json('meta.articles'))->toBeGreaterThan(40)
        ->and($response->json('meta.references'))->toBeGreaterThanOrEqual($response->json('meta.institutions'));

    // Les institutions sont classées de la plus citée à la moins citée.
    $counts = array_column($data, 'count');
    $sorted = $counts;
    rsort($sorted);
    expect($counts)->toBe($sorted);

    $names = array_column($data, 'name');
    expect($names)->toContain('ANStat (ex-INS)');

    // Chaque référence est rattachée à au moins un article publié.
    foreach ($data as $institution) {
        foreach ($institution['references'] as $reference) {
            expect($reference['title'])->not->toBe('')
                ->and($reference['articles'])->not->toBeEmpty();
        }
    }
});
