<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;

/**
 * Illustrations : chaque article reçoit une image réelle avec son auteur, sa
 * licence et sa page de description, et l'API les expose au lecteur.
 */
uses(RefreshDatabase::class);

function makeIllustratedArticle(string $slug, ArticleStatus $status = ArticleStatus::PUBLISHED): Article
{
    $author = User::query()->create([
        'name' => 'Rédaction test',
        'email' => 'redaction-'.Str::random(6).'@ivoirepedia.test',
        'password_hash' => 'hash',
        'role' => 'EDITOR',
        'email_verified_at' => now(),
    ]);

    $category = Category::query()->firstOrCreate(
        ['slug' => 'geographie'],
        ['name' => 'Géographie', 'position' => 0],
    );

    return Article::query()->create([
        'title' => ucfirst($slug),
        'slug' => $slug,
        'summary' => 'Résumé de test.',
        'content' => ['ops' => [['insert' => "Un paragraphe.\n"]]],
        'type' => ArticleType::REGION,
        'status' => $status,
        'author_id' => $author->id,
        'category_id' => $category->id,
        'published_at' => now()->subDay(),
    ]);
}

it('attache une image sourcée à chaque article connu', function () {
    $article = makeIllustratedArticle('abidjan');

    $this->artisan('articles:attach-images')->assertSuccessful();

    $article->refresh();

    expect($article->cover_image_url)->toMatch('#^https://(upload|thumb)\.wikimedia\.org/#')
        ->and($article->cover_image_alt)->toContain('Plateau')
        ->and($article->cover_image_credit)->not->toBeEmpty()
        ->and($article->cover_image_license)->toStartWith('CC')
        ->and($article->cover_image_source_url)->toStartWith('https://commons.wikimedia.org/');
});

it('ne réécrit pas un article dont l’illustration est déjà à jour', function () {
    $article = makeIllustratedArticle('abidjan');

    $this->artisan('articles:attach-images')->assertSuccessful();
    $article->refresh();
    $updatedAt = $article->updated_at;

    $this->travel(1)->minutes();
    $this->artisan('articles:attach-images')
        ->expectsOutputToContain('0 article(s) illustré(s)')
        ->assertSuccessful();

    expect($article->fresh()->updated_at->equalTo($updatedAt))->toBeTrue();
});

it('expose la licence et la source de l’image dans l’API', function () {
    makeIllustratedArticle('abidjan');
    $this->artisan('articles:attach-images')->assertSuccessful();

    $this->getJson('/api/v1/articles/abidjan')
        ->assertOk()
        ->assertJsonPath('data.cover_image_license', fn (string $value) => str_starts_with($value, 'CC'))
        ->assertJsonPath('data.cover_image_url', fn (string $value) => (bool) preg_match('#^https://(upload|thumb)\.wikimedia\.org/#', $value))
        ->assertJsonPath('data.cover_image_source_url', fn (string $value) => str_starts_with($value, 'https://commons.wikimedia.org/'));
});

it('tire au hasard un article publié, jamais un brouillon', function () {
    $draft = makeIllustratedArticle('abidjan', ArticleStatus::DRAFT);
    $published = makeIllustratedArticle('bouake');

    $response = $this->getJson('/api/v1/articles/random')->assertOk();

    expect($response->json('data.slug'))->toBe('bouake')
        ->and($response->json('data.slug'))->not->toBe($draft->slug)
        ->and($response->json('data.category.name'))->toBe('Géographie')
        ->and($published->slug)->toBe('bouake');
});

it('renvoie 404 quand la base ne contient aucun article publié', function () {
    makeIllustratedArticle('abidjan', ArticleStatus::DRAFT);

    $this->getJson('/api/v1/articles/random')
        ->assertNotFound()
        ->assertJsonPath('error.code', 'NOT_FOUND');
});
