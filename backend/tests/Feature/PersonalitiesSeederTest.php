<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use App\Models\ArticleSlugRedirect;
use Database\Seeders\CategorySeeder;
use Database\Seeders\PersonalitiesSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Biographies vérifiées — première tranche (politiques, écrivains,
 * sportifs, artistes). Chaque fiche doit être publiée, porter son
 * infobox `BIOGRAPHY`, son étiquette de groupe et sa bibliographie.
 */
uses(RefreshDatabase::class);

/** @return array<string, array<int, array<string, mixed>>> */
function personalitiesData(): array
{
    return require database_path('data/personalities.php');
}

it('publie les quatre groupes de biographies vérifiées', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    $groups = personalitiesData();
    $total = 0;

    foreach ($groups as $group => $entries) {
        $total += count($entries);

        $tagged = Article::query()
            ->whereHas('tags', fn ($query) => $query->where('slug', 'biographies-'.$group))
            ->count();

        expect($tagged)->toBe(count($entries));
    }

    expect(Article::query()->count())->toBe($total);
});

it('donne à chaque biographie son infobox, sa catégorie et sa bibliographie', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    Article::query()->each(function (Article $article) {
        expect($article->status)->toBe(ArticleStatus::PUBLISHED)
            ->and($article->type)->toBe(ArticleType::BIOGRAPHY)
            ->and($article->category?->slug)->toBe('personnalites')
            ->and($article->infobox)->toMatchArray([
                'nationalities' => ['Ivoirienne'],
            ])
            ->and($article->infobox['fullName'] ?? '')->not->toBe('')
            ->and($article->references)->not->toBeEmpty()
            ->and(strlen($article->plainText()))->toBeGreaterThan(200)
            ->and($article->plainText())->toContain("\n");
    });
});

it('reste idempotent quand on le relance', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    $groups = personalitiesData();
    $total = 0;

    foreach ($groups as $entries) {
        $total += count($entries);
    }

    expect(Article::query()->count())->toBe($total)
        ->and(Article::query()->where('slug', 'yaya-toure')->firstOrFail()->references)->not->toBeEmpty();
});

it('sert une biographie et sa bibliographie sur l’API publique', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    $this->getJson('/api/v1/articles/yaya-toure')
        ->assertOk()
        ->assertJsonPath('data.type_label', 'Biographie')
        ->assertJsonPath('data.infobox.fullName', 'Yaya Touré')
        ->assertJsonPath('data.references.0.url', 'https://fr.wikipedia.org/wiki/Yaya_Tour%C3%A9');
});

it('renomme le slug legacy et conserve sa redirection permanente', function () {
    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    expect(Article::query()->where('slug', 'augustin-denise-djore')->exists())->toBeFalse()
        ->and(Article::query()->where('slug', 'auguste-denise')->exists())->toBeTrue();

    $redirect = ArticleSlugRedirect::query()->where('old_slug', 'augustin-denise-djore')->first();

    expect($redirect?->new_slug)->toBe('auguste-denise');
});
