<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\Tag;
use App\Models\User;
use Database\Seeders\CategorySeeder;
use Database\Seeders\CityArticleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;

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
        // Le recensement et la monographie régionale qui porte les projections.
        ->and($daloa->references)->toHaveCount(2)
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

it('enregistre les empreintes d’une fiche intacte sans toucher à sa date de publication', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article = Article::query()->where('slug', 'katiola')->firstOrFail();
    $publishedAt = $article->published_at;

    // Une fiche sortie d'une version antérieure du seeder : pas d'empreintes.
    $article->forceFill(['series_state' => null])->save();

    $this->seed(CityArticleSeeder::class);

    $article->refresh();

    expect($article->series_state)->toHaveCount(4)
        ->and($article->published_at->equalTo($publishedAt))->toBeTrue()
        ->and($article->plainText())->toContain('Quartiers et équipements');
});

it('reste idempotent quand on le relance', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);
    $this->seed(CityArticleSeeder::class);

    expect(Article::query()->count())->toBe(count(cityData()))
        ->and(Article::query()->where('slug', 'katiola')->firstOrFail()->references)->toHaveCount(2);
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

it('ne supprime pas les références ajoutées depuis le panneau', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $daloa = Article::query()->where('slug', 'daloa')->firstOrFail();
    $daloa->references()->create([
        'position' => 2,
        'kind' => 'WEBSITE',
        'title' => 'Monographie locale',
        'url' => 'https://example.test/monographie-daloa',
    ]);

    $this->seed(CityArticleSeeder::class);
    $this->seed(CityArticleSeeder::class);

    $references = $daloa->references()->get();

    expect($references)->toHaveCount(3)
        ->and($references->pluck('url')->all())->toContain('https://example.test/monographie-daloa')
        ->and($references->where('url', CityArticleSeeder::CENSUS_URL))->toHaveCount(1);
});

it('cite la monographie régionale qui porte ses projections', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    /** @var array{regions: array<string, array{title: string, url: string}>, cities: array<string, string>} $monographs */
    $monographs = require database_path('data/cities-monographs.php');

    foreach ($monographs['cities'] as $slug => $region) {
        $urls = Article::query()->where('slug', $slug)->firstOrFail()
            ->references()->pluck('url')->all();

        expect($urls)->toContain(CityArticleSeeder::CENSUS_URL);

        // La Cavally n'a pas de fichier publié : sa fiche le dit et reste
        // sourcée par le seul recensement.
        if ($region === 'Cavally') {
            expect($urls)->toHaveCount(1);

            continue;
        }

        expect($urls)->toContain($monographs['regions'][$region]['url']);
    }

    $daloa = Article::query()->where('slug', 'daloa')->firstOrFail();
    $monograph = $daloa->references()->where('url', $monographs['regions']['Haut-Sassandra']['url'])->firstOrFail();

    expect($monograph->kind)->toBe('REPORT')
        ->and($monograph->publisher)->toBe('ANStat')
        ->and($monograph->position)->toBe(2);
});

it('ne réécrit pas une fiche de la série modifiée depuis le panneau', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article = Article::query()->where('slug', 'katiola')->firstOrFail();
    $editor = User::factory()->editor()->create();

    $this->actingAs($editor)
        ->put(route('admin.articles.update', $article), [
            'title' => $article->title,
            'summary' => 'Un chapô réécrit par la rédaction, plus précis que celui du seeder.',
            'body' => "Premier paragraphe écrit à la main.\n\nDeuxième paragraphe, toujours à la main.",
            'type' => $article->type->value,
            'category_id' => $article->category_id,
        ])
        ->assertRedirect();

    $this->seed(CityArticleSeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article->refresh();

    expect($article->summary)->toStartWith('Un chapô réécrit')
        ->and($article->plainText())->toContain('Premier paragraphe écrit à la main')
        ->and($article->plainText())->not->toContain('Quartiers et équipements');
});

it('ajoute l’étiquette de la série sans retirer celles de la rédaction', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article = Article::query()->where('slug', 'soubre')->firstOrFail();
    $histoire = Tag::query()->create(['name' => 'Histoire', 'slug' => 'histoire']);
    $article->tags()->attach($histoire);

    $this->seed(CityArticleSeeder::class);

    expect($article->tags()->pluck('slug')->sort()->values()->all())->toBe(['histoire', 'ville']);
});

it('ne remplace pas une fiche antérieure au suivi dont le contenu diffère', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    // Une fiche sortie d'une version antérieure du seeder : pas d'empreintes.
    $article = Article::query()->where('slug', 'divo')->firstOrFail();
    $article->forceFill([
        'series_state' => null,
        'content' => ['ops' => [['insert' => "Ancienne fiche d'une version précédente.\n"]]],
    ])->save();

    // Le premier passage ne remplace rien et signale la fiche à relire.
    $exitCode = Artisan::call('db:seed', ['--class' => CityArticleSeeder::class]);
    $output = Artisan::output();

    expect($exitCode)->toBe(0)
        ->and($article->refresh()->plainText())->toBe("Ancienne fiche d'une version précédente.")
        ->and($article->series_state)->toHaveCount(4)
        ->and($output)->toContain('divo');

    // Et la protection tient au passage suivant.
    $this->seed(CityArticleSeeder::class);

    expect($article->refresh()->plainText())->toBe("Ancienne fiche d'une version précédente.");
});

it('ne touche pas à updated_at d’une fiche déjà à jour', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(CityArticleSeeder::class);

    $article = Article::query()->where('slug', 'bouafle')->firstOrFail();
    $updatedAt = $article->updated_at;

    $this->travel(2)->minutes();
    $this->seed(CityArticleSeeder::class);

    expect($article->refresh()->updated_at->equalTo($updatedAt))->toBeTrue();
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
