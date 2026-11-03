<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;

/**
 * Lecture publique — CONTEXT §11.1/§11.3.
 * Priorité de test du projet : permissions, workflow, validation d'entrées.
 * Ici : ce que le public peut voir, et ce qu'il ne peut pas voir.
 */
uses(RefreshDatabase::class);

function makeAuthor(): User
{
    return User::query()->create([
        'name' => 'Rédaction test',
        'email' => 'redaction-'.Str::random(6).'@ivoirepedia.test',
        'password_hash' => 'hash',
        'role' => 'EDITOR',
        'email_verified_at' => now(),
    ]);
}

/** @param  array<string, mixed>  $overrides */
function makeArticle(array $overrides = []): Article
{
    // Recréée à chaque test : RefreshDatabase vide la base entre deux cas.
    $category = Category::query()->firstOrCreate(
        ['slug' => 'histoire'],
        ['name' => 'Histoire', 'position' => 0],
    );

    return Article::query()->create([
        'title' => 'Un article',
        'slug' => 'un-article-'.Str::random(8),
        'summary' => 'Résumé de test.',
        'content' => ['ops' => [['insert' => "Premier paragraphe.\n"]]],
        'infobox' => null,
        'type' => ArticleType::TOPIC,
        'status' => ArticleStatus::PUBLISHED,
        'author_id' => makeAuthor()->id,
        'category_id' => $category->id,
        'published_at' => now()->subDay(),
        ...$overrides,
    ]);
}

it('renvoie l’arbre des catégories avec le nombre d’articles publiés', function () {
    $category = Category::query()->create(['name' => 'Culture', 'slug' => 'culture', 'position' => 1]);
    makeArticle(['category_id' => $category->id]);
    makeArticle(['category_id' => $category->id, 'status' => ArticleStatus::DRAFT]);

    $response = $this->getJson('/api/v1/categories')->assertOk();

    $culture = collect($response->json('data'))->firstWhere('slug', 'culture');

    expect($culture)->not->toBeNull()
        ->and($culture['name'])->toBe('Culture')
        ->and($culture['article_count'])->toBe(1);
});

it('ne liste que les articles publiés, du plus récent au plus ancien', function () {
    $old = makeArticle(['slug' => 'ancien', 'title' => 'Ancien', 'published_at' => now()->subDays(10)]);
    $new = makeArticle(['slug' => 'recent', 'title' => 'Récent', 'published_at' => now()->subDay()]);
    makeArticle(['slug' => 'brouillon', 'status' => ArticleStatus::DRAFT]);
    makeArticle(['slug' => 'programme', 'published_at' => now()->addDay()]);

    $response = $this->getJson('/api/v1/articles')->assertOk();

    expect($response->json('data.*.slug'))->toBe([$new->slug, $old->slug])
        ->and($response->json('meta.total'))->toBe(2)
        ->and($response->json('meta.page'))->toBe(1);
});

it('refuse une limite supérieure à 20 (ENF-PERF-05)', function () {
    $this->getJson('/api/v1/articles?limit=50')
        ->assertStatus(422)
        ->assertJsonValidationErrors('limit');
});

it('filtre la liste par catégorie', function () {
    $culture = Category::query()->create(['name' => 'Culture', 'slug' => 'culture', 'position' => 2]);
    makeArticle(['slug' => 'dans-culture', 'category_id' => $culture->id]);
    makeArticle(['slug' => 'ailleurs']);

    $response = $this->getJson('/api/v1/articles?category=culture')->assertOk();

    expect($response->json('data.*.slug'))->toBe(['dans-culture']);
});

it('renvoie un article publié avec son contenu, ses tags et ses références', function () {
    $article = makeArticle(['slug' => 'abidjan', 'title' => 'Abidjan']);
    $tag = Tag::query()->create(['name' => 'Capitale', 'slug' => 'capitale']);
    $article->tags()->attach($tag->id);
    $article->references()->create([
        'position' => 1,
        'kind' => 'OTHER',
        'title' => 'RGPH 2021',
        'year' => 2022,
    ]);

    $response = $this->getJson('/api/v1/articles/abidjan')->assertOk();

    expect($response->json('data.title'))->toBe('Abidjan')
        ->and($response->json('data.content.ops.0.insert'))->toBe("Premier paragraphe.\n")
        ->and($response->json('data.tags.0.slug'))->toBe('capitale')
        ->and($response->json('data.references.0.title'))->toBe('RGPH 2021')
        ->and($response->json('data.reading_minutes'))->toBeInt();
});

it('renvoie 404 pour un article non publié ou inconnu', function () {
    makeArticle(['slug' => 'cache', 'status' => ArticleStatus::SUBMITTED]);

    $this->getJson('/api/v1/articles/cache')
        ->assertNotFound()
        ->assertJsonPath('error.code', 'NOT_FOUND');

    $this->getJson('/api/v1/articles/inexistant')->assertNotFound();
});

it('cherche dans les titres et résumés des articles publiés', function () {
    makeArticle(['slug' => 'cacao', 'title' => "Le cacao en Côte d'Ivoire"]);
    makeArticle(['slug' => 'banco', 'title' => 'Parc national du Banco']);

    $response = $this->getJson('/api/v1/search?q=cacao')->assertOk();

    expect($response->json('data.*.slug'))->toBe(['cacao'])
        ->and($response->json('meta.query'))->toBe('cacao');
});

it('renvoie une liste vide quand la recherche est vide', function () {
    makeArticle();

    $this->getJson('/api/v1/search?q=')
        ->assertOk()
        ->assertJsonPath('meta.total', 0)
        ->assertJsonCount(0, 'data');
});
