<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;

/**
 * Enrichissement : les articles existants reçoivent les effectifs du RGPH et
 * des références vérifiées, sans doublon et sans perdre leurs sources propres.
 */
uses(RefreshDatabase::class);

function makeEnrichedArticle(string $slug, array $infobox = [], array $reference = []): Article
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

    $article = Article::query()->create([
        'title' => ucfirst($slug),
        'slug' => $slug,
        'summary' => 'Résumé de test.',
        'content' => ['ops' => [['insert' => "Un paragraphe.\n"]]],
        'infobox' => $infobox,
        'type' => ArticleType::REGION,
        'status' => ArticleStatus::PUBLISHED,
        'author_id' => $author->id,
        'category_id' => $category->id,
        'published_at' => now()->subDay(),
    ]);

    if ($reference !== []) {
        $article->references()->create($reference);
    }

    return $article;
}

it('complète la population et ajoute les références vérifiées', function () {
    $bouake = makeEnrichedArticle('bouake', ['level' => 'VILLE', 'languages' => ['Français']]);

    $this->artisan('articles:enrich-sources')->assertSuccessful();

    $bouake->refresh();

    expect(data_get($bouake->infobox, 'population'))->toBe(832371)
        ->and(data_get($bouake->infobox, 'populationYear'))->toBe(2021)
        // Les clés existantes ne sont pas écrasées.
        ->and(data_get($bouake->infobox, 'level'))->toBe('VILLE')
        ->and($bouake->references()->count())->toBe(1)
        ->and($bouake->references()->first()->url)
        ->toBe('https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf');
});

it('remplace l’ancienne référence ins.ci et reste idempotente', function () {
    $abidjan = makeEnrichedArticle('abidjan', ['population' => 6321017], [
        'position' => 1,
        'kind' => 'OTHER',
        'title' => "Recensement général de la population et de l'habitat (RGPH) 2021",
        'publisher' => 'INS',
        'year' => 2022,
        'url' => 'https://www.ins.ci',
    ]);

    $this->artisan('articles:enrich-sources')->assertSuccessful();
    $this->artisan('articles:enrich-sources')->assertSuccessful();

    $urls = $abidjan->references()->pluck('url')->all();

    expect($urls)->toBe([
        'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
    ]);
});

it('conserve une référence éditoriale déjà présente', function () {
    $cacao = makeEnrichedArticle('le-cacao-en-cote-d-ivoire', [], [
        'position' => 1,
        'kind' => 'REPORT',
        'title' => 'Rapport annuel du Conseil café-cacao',
        'publisher' => 'Conseil café-cacao',
        'year' => 2024,
        'url' => 'https://example.test/rapport',
    ]);

    $this->artisan('articles:enrich-sources')->assertSuccessful();

    expect($cacao->references()->count())->toBe(2)
        ->and($cacao->references()->pluck('title')->all())
        ->toContain('Rapport annuel du Conseil café-cacao');
});
