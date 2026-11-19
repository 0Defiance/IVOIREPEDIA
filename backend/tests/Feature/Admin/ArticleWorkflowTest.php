<?php

use App\Enums\ArticleStatus;
use App\Enums\EditorialActionType;
use App\Models\Article;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Workflow éditorial exécuté par le panneau.
 *
 * Chaque test passe par la route HTTP réelle : c'est elle que l'équipe
 * utilise, et c'est donc elle qui doit refuser. Les règles de la machine à
 * états sont testées séparément dans `tests/Unit/WorkflowTest.php`.
 */
uses(RefreshDatabase::class);

function articleFor(User $author, array $attributes = []): Article
{
    return Article::factory()->by($author)->create($attributes);
}

function withSource(Article $article): Article
{
    $article->references()->create([
        'position' => 1,
        'kind' => 'WEBSITE',
        'title' => 'RGPH 2021, résultats globaux',
        'publisher' => 'INS',
        'year' => 2022,
    ]);

    return $article;
}

function transition(Article $article, string $action, ?string $comment = null)
{
    return test()->post(route('admin.articles.transition', $article), array_filter([
        'action' => $action,
        'comment' => $comment,
    ]));
}

it('laisse un contributeur soumettre son brouillon', function () {
    $author = User::factory()->contributor()->create();
    $article = articleFor($author);

    $this->actingAs($author)
        ->post(route('admin.articles.transition', $article), ['action' => 'submit'])
        ->assertRedirect(route('admin.articles.show', $article));

    $article->refresh();

    expect($article->status)->toBe(ArticleStatus::SUBMITTED)
        ->and($article->lock_version)->toBe(1)
        ->and($article->current_version)->toBe(1)
        ->and($article->versions()->count())->toBe(1);

    $action = $article->actions()->first();

    expect($action->type)->toBe(EditorialActionType::SUBMIT)
        ->and($action->actor_id)->toBe($author->getKey())
        ->and($action->from_status)->toBe(ArticleStatus::DRAFT)
        ->and($action->to_status)->toBe(ArticleStatus::SUBMITTED);
});

it('refuse la soumission de l’article d’un autre contributeur', function () {
    $author = User::factory()->contributor()->create();
    $other = User::factory()->contributor()->create();
    $article = articleFor($author);

    $this->actingAs($other)
        ->post(route('admin.articles.transition', $article), ['action' => 'submit'])
        ->assertForbidden();

    expect($article->refresh()->status)->toBe(ArticleStatus::DRAFT);
});

it('refuse une action impossible depuis le statut courant', function () {
    $author = User::factory()->contributor()->create();
    $article = articleFor($author, ['status' => ArticleStatus::SUBMITTED]);

    $this->actingAs($author)
        ->post(route('admin.articles.transition', $article), ['action' => 'submit'])
        ->assertForbidden();

    expect($article->refresh()->status)->toBe(ArticleStatus::SUBMITTED);
});

it('ouvre la relecture à un éditeur, pas à l’auteur éditeur', function () {
    $author = User::factory()->contributor()->create();
    $editor = User::factory()->editor()->create();
    $article = articleFor($author, ['status' => ArticleStatus::SUBMITTED]);

    $this->actingAs($editor)
        ->post(route('admin.articles.transition', $article), ['action' => 'start_review'])
        ->assertRedirect(route('admin.articles.show', $article));

    expect($article->refresh()->status)->toBe(ArticleStatus::IN_REVIEW);

    // Sans ALLOW_SELF_REVIEW, un éditeur ne révise pas son propre article.
    config(['ivoirepedia.allow_self_review' => false]);
    $own = articleFor($editor, ['status' => ArticleStatus::SUBMITTED]);

    $this->actingAs($editor)
        ->post(route('admin.articles.transition', $own), ['action' => 'start_review'])
        ->assertForbidden();
});

it('exige un commentaire pour demander une révision', function () {
    $editor = User::factory()->editor()->create();
    $article = articleFor(User::factory()->contributor()->create(), ['status' => ArticleStatus::IN_REVIEW]);

    $this->actingAs($editor)
        ->post(route('admin.articles.transition', $article), ['action' => 'request_revision'])
        ->assertSessionHas('error');

    expect($article->refresh()->status)->toBe(ArticleStatus::IN_REVIEW);

    transition($article, 'request_revision', 'Ajoutez la source du recensement.')
        ->assertRedirect(route('admin.articles.show', $article));

    $article->refresh();

    expect($article->status)->toBe(ArticleStatus::REVISION_REQUESTED)
        ->and($article->actions()->first()->comment)->toBe('Ajoutez la source du recensement.');
});

it('publie un article approuvé et daté', function () {
    $editor = User::factory()->editor()->create();
    $article = withSource(articleFor(User::factory()->contributor()->create(), [
        'status' => ArticleStatus::APPROVED,
        'published_at' => null,
    ]));

    $this->actingAs($editor);

    transition($article, 'publish')->assertRedirect(route('admin.articles.show', $article));

    $article->refresh();

    expect($article->status)->toBe(ArticleStatus::PUBLISHED)
        ->and($article->published_at)->not->toBeNull()
        ->and($article->current_version)->toBe(1)
        ->and($article->actions()->first()->type)->toBe(EditorialActionType::PUBLISH);
});

it('refuse de publier un article sans source', function () {
    $editor = User::factory()->editor()->create();
    $article = articleFor(User::factory()->contributor()->create(), ['status' => ArticleStatus::APPROVED]);

    $this->actingAs($editor);

    transition($article, 'publish')->assertSessionHas('error');

    expect($article->refresh()->status)->toBe(ArticleStatus::APPROVED)
        ->and($article->published_at)->toBeNull()
        ->and($article->versions()->count())->toBe(0);
});

it('archive puis restaure un article publié', function () {
    $editor = User::factory()->editor()->create();
    // Restaurer remet l'article en ligne : la garde de publication le
    // revérifie, il lui faut donc une source comme au premier jour.
    $article = withSource(articleFor(User::factory()->contributor()->create(), [
        'status' => ArticleStatus::PUBLISHED,
    ]));

    $this->actingAs($editor);

    transition($article, 'archive');
    expect($article->refresh()->status)->toBe(ArticleStatus::ARCHIVED);

    transition($article, 'restore');
    expect($article->refresh()->status)->toBe(ArticleStatus::PUBLISHED);
});

it('réserve la suppression à l’administrateur', function () {
    $article = articleFor(User::factory()->contributor()->create(), ['status' => ArticleStatus::PUBLISHED]);
    $editor = User::factory()->editor()->create();

    $this->actingAs($editor)
        ->post(route('admin.articles.transition', $article), ['action' => 'delete'])
        ->assertForbidden();

    $admin = User::factory()->admin()->create();

    $this->actingAs($admin)
        ->post(route('admin.articles.transition', $article), ['action' => 'delete'])
        ->assertRedirect(route('admin.articles.show', $article));

    $deleted = Article::withTrashed()->findOrFail($article->getKey());

    expect($deleted->status)->toBe(ArticleStatus::DELETED)
        ->and($deleted->deleted_at)->not->toBeNull();
});
