<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
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

    expect(substr_count($text, "\n"))->toBeGreaterThanOrEqual(10)
        ->and($text)->toContain('Daloa')
        ->and($daloa->content['ops'])->toHaveCount(14);
});

it('ajoute le relief, le climat, les quartiers et les équipements', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $cities = cityData();
    $details = require database_path('data/cities-details.php');

    expect($details)->toHaveCount(count($cities));

    foreach (array_keys($cities) as $slug) {
        $text = Article::query()->where('slug', $slug)->firstOrFail()->plainText();

        expect($text)->toContain('Relief et climat')
            ->and($text)->toContain('Quartiers et équipements');
    }
});

it('rafraîchit une fiche de la série sans toucher à sa date de publication', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article = Article::query()->where('slug', 'katiola')->firstOrFail();
    $publishedAt = $article->published_at;
    $article->update(['summary' => 'Résumé périmé.', 'series' => 'villes']);

    $this->seed(CityArticleSeeder::class);

    $article->refresh();

    expect($article->summary)->toBe("Chef-lieu du Hambol, Katiola est la ville des potières tagbanas, au cœur d'une région de savane et de coton.")
        ->and($article->published_at->equalTo($publishedAt))->toBeTrue()
        ->and($article->plainText())->toContain('Quartiers et équipements');
});

it('reste idempotent quand on le relance', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);
    $this->seed(CityArticleSeeder::class);

    expect(Article::query()->count())->toBe(count(cityData()))
        ->and(Article::query()->where('slug', 'katiola')->firstOrFail()->references)->toHaveCount(1);
});

it('adopte une fiche antérieure à la colonne series quand on le demande', function () {
    $this->seed(CategorySeeder::class);

    $legacy = Article::factory()->create([
        'slug' => 'katiola',
        'title' => 'Katiola',
        'summary' => 'Une fiche écrite avant la colonne series.',
    ]);

    putenv('CITY_SEEDER_ADOPT=1');
    $this->seed(CityArticleSeeder::class);
    putenv('CITY_SEEDER_ADOPT');

    $legacy->refresh();

    expect($legacy->series)->toBe('villes')
        ->and($legacy->plainText())->toContain('Quartiers et équipements');
});

it('ne réécrit jamais un article déjà publié sur la même ville', function () {
    $this->seed(CategorySeeder::class);

    $category = Category::query()->where('slug', 'geographie')->firstOrFail();
    $author = User::query()->create([
        'name' => 'Rédaction existante',
        'email' => 'existante@ivoirepedia.test',
        'password_hash' => 'hash',
        'role' => 'EDITOR',
        'email_verified_at' => now(),
    ]);
    $existing = Article::query()->create([
        'title' => 'Daloa',
        'slug' => 'daloa',
        'summary' => 'Fiche écrite à la main, plus détaillée que la série.',
        'content' => ['ops' => [['insert' => "Texte éditorial existant.\n"]]],
        'type' => ArticleType::REGION,
        'status' => ArticleStatus::PUBLISHED,
        'author_id' => $author->id,
        'category_id' => $category->id,
        'published_at' => now()->subWeek(),
    ]);

    $this->seed(CityArticleSeeder::class);

    $daloa = Article::query()->where('slug', 'daloa')->firstOrFail();

    expect($daloa->id)->toBe($existing->id)
        ->and($daloa->summary)->toBe('Fiche écrite à la main, plus détaillée que la série.')
        ->and($daloa->plainText())->toBe('Texte éditorial existant.')
        ->and(Article::query()->count())->toBe(count(cityData()));
});

it('sert chaque fiche sur l’API publique', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $this->getJson('/api/v1/articles/katiola')
        ->assertOk()
        ->assertJsonPath('data.slug', 'katiola')
        ->assertJsonPath('data.title', 'Katiola')
        ->assertJsonPath('data.infobox.population', 90641)
        ->assertJsonPath('data.type_label', 'Territoire');

    $list = $this->getJson('/api/v1/articles?limit=20')->assertOk();

    expect($list->json('meta.total'))->toBe(count(cityData()));
});
