<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;

/**
 * Frise chronologique, fiches géographiques et suggestions de recherche.
 *
 * Les trois endpoints sont en lecture seule et adossés aux données du dépôt :
 * les tests importent le vrai jeu de données (aucun réseau) puis vérifient ce
 * que le public reçoit.
 */
uses(RefreshDatabase::class);

function discoveryAuthor(): User
{
    return User::query()->create([
        'name' => 'Rédaction test',
        'email' => 'discovery-'.Str::random(6).'@ivoirepedia.test',
        'password_hash' => 'hash',
        'role' => 'EDITOR',
        'email_verified_at' => now(),
    ]);
}

/** @param  array<string, mixed>  $overrides */
function discoveryArticle(array $overrides = []): Article
{
    $category = Category::query()->firstOrCreate(
        ['slug' => 'villes'],
        ['name' => 'Villes', 'position' => 0],
    );

    return Article::query()->create([
        'title' => 'Un article',
        'slug' => 'article-'.Str::random(8),
        'summary' => 'Résumé de test.',
        'content' => ['ops' => [['insert' => "Premier paragraphe.\n"]]],
        'infobox' => null,
        'type' => ArticleType::TOPIC,
        'status' => ArticleStatus::PUBLISHED,
        'author_id' => discoveryAuthor()->id,
        'category_id' => $category->id,
        'published_at' => now()->subDay(),
        ...$overrides,
    ]);
}

it('construit la frise à partir des récits datés, du plus ancien au plus récent', function () {
    $this->artisan('history:sync-stories')->assertSuccessful();

    $response = $this->getJson('/api/v1/timeline')->assertOk();
    $events = $response->json('data');

    expect($events)->toHaveCount(11)
        ->and($events[0]['slug'])->toBe('indenie-abengourou')
        ->and($events[0]['year'])->toBe(1701)
        ->and($events[0]['era'])->toBe('Avant 1800')
        ->and($events[1]['year'])->toBeGreaterThanOrEqual($events[0]['year'])
        ->and(collect($events)->pluck('year')->all())->toBe(
            collect($events)->pluck('year')->sort()->values()->all()
        )
        ->and($response->json('meta.first_year'))->toBe(1701)
        ->and($response->json('meta.last_year'))->toBe(2024);

    $samory = collect($events)->firstWhere('slug', 'samory-guelemou-1898');

    expect($samory['year'])->toBe(1898)
        ->and($samory['era'])->toBe('XIXe siècle')
        ->and($samory['source']['url'])->toBe('https://journals.openedition.org/rha/7701');
});

it('liste les districts, régions et villes du recensement', function () {
    $this->artisan('country:sync-statistics', ['--offline' => true])->assertSuccessful();

    $response = $this->getJson('/api/v1/places')->assertOk();

    expect($response->json('data.districts'))->toHaveCount(14)
        ->and($response->json('data.regions'))->toHaveCount(31)
        ->and($response->json('meta.census_year'))->toBe(2021)
        ->and(collect($response->json('data.districts'))->firstWhere('slug', 'abidjan')['population'])
        ->toBe(6321017);
});

it('rassemble en une fiche les niveaux qui partagent un même lieu', function () {
    $this->artisan('country:sync-statistics', ['--offline' => true])->assertSuccessful();
    discoveryArticle(['title' => 'Abidjan, la ville et sa lagune', 'slug' => 'abidjan-lagune']);

    $response = $this->getJson('/api/v1/places/abidjan')->assertOk();

    $levels = collect($response->json('data.entries'))->pluck('level')->all();
    $climate = $response->json('data.climate');

    expect($response->json('data.name'))->toBe('Abidjan')
        ->and($response->json('data.parent'))->toBeNull()
        ->and($levels)->toBe(['district'])
        ->and($climate['annual_rain_mm'])->toBeGreaterThan(1500.0)
        ->and($climate['wettest_month']['month'])->toBe(6)
        ->and($climate['source']['licence'])->toBe('CC BY 4.0')
        ->and(collect($response->json('data.articles'))->pluck('slug'))->toContain('abidjan-lagune');

    // Une ville chef-lieu (Bouaké) porte le niveau « city » et son climat.
    $city = $this->getJson('/api/v1/places/bouake')->assertOk();

    expect(collect($city->json('data.entries'))->pluck('level')->all())->toBe(['city'])
        ->and($city->json('data.parent'))->not->toBeNull()
        ->and($city->json('data.climate.annual_rain_mm'))->toBeGreaterThan(500.0);
});

it('renvoie 404 pour un lieu absent du recensement', function () {
    $this->getJson('/api/v1/places/atlantide')
        ->assertNotFound()
        ->assertJsonPath('error.code', 'NOT_FOUND');
});

it('suggère des articles dès deux caractères, sans les brouillons', function () {
    discoveryArticle(['title' => 'Le cacao ivoirien', 'slug' => 'cacao-ivoirien']);
    discoveryArticle([
        'title' => 'Cacao : brouillon',
        'slug' => 'cacao-brouillon',
        'status' => ArticleStatus::DRAFT,
    ]);

    $response = $this->getJson('/api/v1/search/suggest?q=cacao')->assertOk();

    expect($response->json('data.*.slug'))->toBe(['cacao-ivoirien'])
        ->and($response->json('data.0.title'))->toBe('Le cacao ivoirien')
        ->and($response->json('data.0.category'))->toBe('Villes');

    $this->getJson('/api/v1/search/suggest?q=c')
        ->assertOk()
        ->assertJsonCount(0, 'data');
});
