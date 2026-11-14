<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Database\Seeders\PublicContentSeeder;
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
    $bouake = makeEnrichedArticle('bouake', ['level' => 'DEPARTMENT', 'languages' => ['Français']]);

    $this->artisan('articles:enrich-sources')->assertSuccessful();

    $bouake->refresh();

    expect(data_get($bouake->infobox, 'population'))->toBe(832371)
        ->and(data_get($bouake->infobox, 'populationYear'))->toBe(2021)
        // L'effectif communal impose l'étiquette « ville »…
        ->and(data_get($bouake->infobox, 'level'))->toBe('CITY')
        // …et les autres clés restent intactes.
        ->and(data_get($bouake->infobox, 'languages'))->toBe(['Français'])
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

it('publie des articles de fond, pas des notices', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PublicContentSeeder::class);

    $words = function (string $slug): int {
        $article = Article::query()->where('slug', $slug)->firstOrFail();
        $text = collect($article->content['ops'])->pluck('insert')->implode(' ');

        return count(preg_split('/\s+/u', trim($text)) ?: []);
    };

    $abidjan = Article::query()->where('slug', 'abidjan')->firstOrFail();
    $headings = collect($abidjan->content['ops'])
        ->filter(fn (array $op): bool => ($op['attributes']['header'] ?? null) === 2)
        ->count();

    expect($words('abidjan'))->toBeGreaterThan(650)
        ->and($headings)->toBeGreaterThanOrEqual(7)
        ->and($words('bouake'))->toBeGreaterThan(300)
        ->and($words('korhogo'))->toBeGreaterThan(300)
        ->and(data_get(
            Article::query()->where('slug', 'bouake')->firstOrFail()->infobox,
            'population',
        ))->toBe(832371);

    // Aucun article ne reste une notice : trois sections et 150 mots au moins.
    $thin = Article::query()->get()->filter(function (Article $article) {
        $ops = collect($article->content['ops']);
        $text = $ops->pluck('insert')->implode(' ');
        $sections = $ops->filter(
            fn (array $op): bool => ($op['attributes']['header'] ?? null) === 2,
        )->count();

        return count(preg_split('/\s+/u', trim($text)) ?: []) < 150 || $sections < 3;
    })->pluck('slug')->all();

    expect($thin)->toBe([]);

    // Chaque article s'appuie sur au moins une source, et chaque appel [n]
    // pointe vers une référence existante.
    $problems = Article::query()->with('references')->get()->flatMap(function (Article $article) {
        $ops = collect($article->content['ops']);
        $text = $ops->pluck('insert')->implode(' ');
        preg_match_all('/\[(\d{1,3})\]/', $text, $matches);
        $numbers = array_map('intval', $matches[1]);
        $count = $article->references->count();
        $issues = [];

        if ($count === 0) {
            $issues[] = 'sans référence';
        }

        if ($numbers !== [] && max($numbers) > $count) {
            $issues[] = sprintf('appel [%d] sans référence', max($numbers));
        }

        return $issues === [] ? [] : [$article->slug.' : '.implode(', ', $issues)];
    })->values()->all();

    expect($problems)->toBe([]);
});
