<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use Database\Seeders\CategorySeeder;
use Database\Seeders\CityArticleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Série « Villes de Côte d'Ivoire » : ce que le seeder doit garantir, et ce que
 * le public doit pouvoir lire. Priorité du projet : le contenu publié et les
 * règles éditoriales (une source, une infobox, un statut publié).
 */
uses(RefreshDatabase::class);

/** @return array<string, array<string, mixed>> */
function cityData(): array
{
    return require database_path('data/cities.php');
}

it('publie une fiche pour chaque ville du répertoire public', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $cities = cityData();

    expect(Article::query()->count())->toBe(count($cities));

    foreach (array_keys($cities) as $slug) {
        $article = Article::query()->where('slug', $slug)->first();

        expect($article)->not->toBeNull()
            ->and($article->status)->toBe(ArticleStatus::PUBLISHED)
            ->and($article->published_at)->not->toBeNull();
    }
});

it('donne à chaque ville son infobox, sa source et son étiquette', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $daloa = Article::query()->where('slug', 'daloa')->firstOrFail();

    expect($daloa->title)->toBe('Daloa')
        ->and($daloa->type)->toBe(ArticleType::REGION)
        ->and($daloa->category?->slug)->toBe('geographie')
        ->and($daloa->infobox)->toMatchArray([
            'level' => 'CITY',
            'population' => 421879,
            'populationYear' => 2021,
        ])
        ->and($daloa->tags->pluck('slug')->all())->toBe(['ville'])
        ->and($daloa->references)->toHaveCount(1)
        ->and($daloa->references->first()->url)
        ->toBe('https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf');

    // Une fiche détaillée : un chapeau, des sections, plusieurs paragraphes.
    $text = $daloa->plainText();

    expect(substr_count($text, "\n"))->toBeGreaterThanOrEqual(5)
        ->and($text)->toContain('Daloa')
        ->and($daloa->content['ops'])->toHaveCount(8);
});

it('reste idempotent quand on le relance', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);
    $this->seed(CityArticleSeeder::class);

    expect(Article::query()->count())->toBe(count(cityData()))
        ->and(Article::query()->where('slug', 'katiola')->firstOrFail()->references)->toHaveCount(1);
});

it('sert chaque fiche sur l’API publique', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $this->getJson('/api/v1/articles/grand-bassam')
        ->assertOk()
        ->assertJsonPath('data.slug', 'grand-bassam')
        ->assertJsonPath('data.title', 'Grand-Bassam')
        ->assertJsonPath('data.infobox.population', 124567)
        ->assertJsonPath('data.type_label', 'Territoire');

    $list = $this->getJson('/api/v1/articles?limit=20')->assertOk();

    expect($list->json('meta.total'))->toBe(count(cityData()));
});
