<?php

use App\Enums\ArticleStatus;
use App\Enums\EditorialActionType;
use App\Models\Article;
use App\Models\ArticleVersion;
use App\Models\Category;
use App\Models\EditorialAction;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Panneau éditorial : référentiels, formulaire complet et journal.
 *
 * Ces tests suivent le parcours réel d'un membre de la rédaction : session du
 * panneau, formulaires HTML, puis lecture de ce que la base a retenu.
 */
uses(RefreshDatabase::class);

it('crée une catégorie avec son adresse', function () {
    $editor = User::factory()->editor()->create();

    $this->actingAs($editor)
        ->post('/admin/categories', [
            'name' => 'Régions du Nord',
            'description' => 'Les savanes et les villes carrefours.',
            'position' => 2,
        ])
        ->assertRedirect();

    $category = Category::query()->where('name', 'Régions du Nord')->firstOrFail();

    expect($category->slug)->toBe('regions-du-nord')
        ->and($category->position)->toBe(2);
});

it('garde l’adresse d’une catégorie déjà utilisée', function () {
    $editor = User::factory()->editor()->create();
    $category = Category::factory()->create(['name' => 'Histoire', 'slug' => 'histoire']);
    Article::factory()->create(['category_id' => $category->getKey()]);

    $this->actingAs($editor)
        ->put(route('admin.categories.update', $category), [
            'name' => 'Histoire et mémoire',
            'position' => 1,
        ])
        ->assertRedirect();

    expect($category->refresh()->name)->toBe('Histoire et mémoire')
        ->and($category->slug)->toBe('histoire');
});

it('refuse de supprimer une catégorie qui porte des articles', function () {
    $editor = User::factory()->editor()->create();
    $category = Category::factory()->create(['name' => 'Économie']);
    Article::factory()->create(['category_id' => $category->getKey()]);

    $this->actingAs($editor)
        ->from('/admin/categories')
        ->delete(route('admin.categories.destroy', $category))
        ->assertRedirect('/admin/categories')
        ->assertSessionHas('error');

    expect(Category::query()->whereKey($category->getKey())->exists())->toBeTrue();
});

it('ferme les référentiels à un contributeur', function () {
    $contributor = User::factory()->contributor()->create();
    $category = Category::factory()->create(['name' => 'Culture']);

    $this->actingAs($contributor)->get('/admin/categories')->assertForbidden();
    $this->actingAs($contributor)->get('/admin/etiquettes')->assertForbidden();

    $this->actingAs($contributor)
        ->post('/admin/categories', ['name' => 'Catégorie pirate'])
        ->assertForbidden();

    expect($category->refresh()->name)->toBe('Culture')
        ->and(Category::query()->count())->toBe(1);
});

it('crée une étiquette, la renomme et la supprime sans toucher aux articles', function () {
    $editor = User::factory()->editor()->create();
    $article = Article::factory()->create();

    $this->actingAs($editor)->post('/admin/etiquettes', ['name' => 'Agriculture'])->assertRedirect();

    $tag = Tag::query()->where('name', 'Agriculture')->firstOrFail();
    $article->tags()->attach($tag);

    $this->actingAs($editor)
        ->put(route('admin.tags.update', $tag), ['name' => 'Cultures vivrières'])
        ->assertRedirect();

    expect($tag->refresh()->name)->toBe('Cultures vivrières')
        ->and($tag->slug)->toBe('cultures-vivrieres');

    $this->actingAs($editor)
        ->delete(route('admin.tags.destroy', $tag))
        ->assertRedirect();

    expect(Tag::query()->count())->toBe(0)
        ->and($article->fresh())->not->toBeNull();
});

it('enregistre plusieurs sources, une infobox et des étiquettes', function () {
    $contributor = User::factory()->contributor()->create();
    $category = Category::factory()->create();
    $tag = Tag::query()->create(['name' => 'Pêche', 'slug' => 'peche']);

    $this->actingAs($contributor)
        ->post('/admin/articles', [
            'title' => 'Les lagunes ivoiriennes',
            'summary' => 'Des plans d’eau qui structurent la vie de plusieurs régions.',
            'body' => "## Un milieu fragile\n\nLes lagunes abritent une pêche artisanale.\n\nElles bordent plusieurs communes.",
            'type' => 'REGION',
            'category_id' => $category->getKey(),
            'references' => [
                ['title' => 'Atlas de la Côte d’Ivoire', 'publisher' => 'IGN', 'year' => 2001],
                ['title' => 'Rapport sur les lagunes', 'url' => 'https://example.test/lagunes'],
            ],
            'infobox' => [
                ['label' => 'Superficie', 'value' => '566 km²'],
                ['label' => '', 'value' => 'ligne incomplète ignorée'],
            ],
            'tags' => [$tag->getKey()],
        ])
        ->assertRedirect();

    $article = Article::query()->where('title', 'Les lagunes ivoiriennes')->firstOrFail();
    $references = $article->references()->orderBy('position')->get();

    expect($references)->toHaveCount(2)
        ->and($references[0]->title)->toBe('Atlas de la Côte d’Ivoire')
        ->and($references[0]->publisher)->toBe('IGN')
        ->and($references[1]->url)->toBe('https://example.test/lagunes')
        ->and($article->infobox)->toBe(['Superficie' => '566 km²'])
        ->and($article->tags->pluck('name')->all())->toBe(['Pêche']);
});

it('refuse une source qui pointe vers une page d’accueil', function () {
    $contributor = User::factory()->contributor()->create();
    $category = Category::factory()->create();

    $this->actingAs($contributor)
        ->from('/admin/articles/create')
        ->post('/admin/articles', [
            'title' => 'Une source en page d’accueil',
            'summary' => 'Un article dont la source ne mène pas à une page précise.',
            'body' => 'Un corps suffisamment long pour passer la validation.',
            'type' => 'TOPIC',
            'category_id' => $category->getKey(),
            'references' => [
                ['title' => 'Site officiel', 'url' => 'https://example.test'],
            ],
        ])
        ->assertRedirect('/admin/articles/create')
        ->assertSessionHasErrors([
            'references.0.url' => 'L’adresse de la source doit pointer vers une page précise, pas vers l’accueil d’un site.',
        ]);

    expect(Article::query()->where('title', 'Une source en page d’accueil')->exists())->toBeFalse();

    // Une page précise reste acceptée.
    $this->actingAs($contributor)
        ->post('/admin/articles', [
            'title' => 'Une source précise',
            'summary' => 'Un article dont la source mène à une page précise.',
            'body' => 'Un corps suffisamment long pour passer la validation.',
            'type' => 'TOPIC',
            'category_id' => $category->getKey(),
            'references' => [
                ['title' => 'Site officiel', 'url' => 'https://example.test/page'],
            ],
        ])
        ->assertRedirect();

    $article = Article::query()->where('title', 'Une source précise')->firstOrFail();

    expect($article->references()->value('url'))->toBe('https://example.test/page');
});

it('remplace les sources à l’enregistrement, dans l’ordre saisi', function () {
    $editor = User::factory()->editor()->create();
    $article = Article::factory()->create();
    $article->references()->create([
        'position' => 1, 'kind' => 'WEBSITE', 'title' => 'Ancienne source',
    ]);

    $this->actingAs($editor)
        ->put(route('admin.articles.update', $article), [
            'title' => $article->title,
            'summary' => $article->summary,
            'body' => 'Un corps suffisamment long pour passer la validation.',
            'type' => $article->type->value,
            'category_id' => $article->category_id,
            'references' => [
                ['title' => 'Première source'],
                ['title' => 'Deuxième source'],
            ],
        ])
        ->assertRedirect();

    $titles = $article->refresh()->references()->pluck('title')->all();

    expect($titles)->toBe(['Première source', 'Deuxième source']);
});

it('enregistre le credit, la licence et la page source de la couverture', function () {
    $editor = User::factory()->editor()->create();
    $article = Article::factory()->create();

    $this->actingAs($editor)
        ->put(route('admin.articles.update', $article), [
            'title' => $article->title,
            'summary' => $article->summary,
            'body' => 'Un corps suffisamment long pour passer la validation.',
            'type' => $article->type->value,
            'category_id' => $article->category_id,
            'cover_image_url' => 'https://example.test/couverture.jpg',
            'cover_image_alt' => 'Une vue de la ville.',
            'cover_image_credit' => 'Aman ADO',
            'cover_image_license' => 'CC BY-SA 4.0',
            'cover_image_source_url' => 'https://commons.wikimedia.org/wiki/File:Exemple.jpg',
        ])
        ->assertRedirect();

    $article->refresh();

    expect($article->cover_image_credit)->toBe('Aman ADO')
        ->and($article->cover_image_license)->toBe('CC BY-SA 4.0')
        ->and($article->cover_image_source_url)->toBe('https://commons.wikimedia.org/wiki/File:Exemple.jpg');
});

it('filtre les articles sans source ou sans image, et par catégorie', function () {
    $editor = User::factory()->editor()->create();
    $category = Category::factory()->create();

    $sourced = Article::factory()->create([
        'title' => 'Avec une source et une image',
        'category_id' => $category->getKey(),
        'cover_image_url' => 'https://example.test/couverture.jpg',
    ]);
    $sourced->references()->create([
        'position' => 1, 'kind' => 'WEBSITE', 'title' => 'Source vérifiée',
    ]);

    Article::factory()->create([
        'title' => 'Sans rien du tout',
        'category_id' => $category->getKey(),
    ]);

    $this->actingAs($editor)
        ->get('/admin/articles?sans_source=1&sans_image=1')
        ->assertOk()
        ->assertSee('Sans rien du tout')
        ->assertDontSee('Avec une source et une image');

    $this->actingAs($editor)
        ->get('/admin/articles?categorie='.$category->getKey())
        ->assertOk()
        ->assertSee('Sans rien du tout')
        ->assertSee('Avec une source et une image');
});

it('montre le journal éditorial et le filtre par action', function () {
    $editor = User::factory()->editor()->create();
    $contributor = User::factory()->contributor()->create();

    $mine = Article::factory()->by($contributor)->create(['title' => 'Article du contributeur']);
    $other = Article::factory()->create(['title' => 'Article du fondateur']);

    EditorialAction::create([
        'article_id' => $mine->getKey(),
        'actor_id' => $contributor->getKey(),
        'type' => EditorialActionType::SUBMIT,
        'from_status' => ArticleStatus::DRAFT,
        'to_status' => ArticleStatus::SUBMITTED,
        'comment' => 'Prêt pour la relecture',
    ]);

    EditorialAction::create([
        'article_id' => $other->getKey(),
        'actor_id' => $editor->getKey(),
        'type' => EditorialActionType::PUBLISH,
        'from_status' => ArticleStatus::APPROVED,
        'to_status' => ArticleStatus::PUBLISHED,
    ]);

    $this->actingAs($editor)
        ->get('/admin/journal')
        ->assertOk()
        ->assertSee('Article du contributeur')
        ->assertSee('Article du fondateur')
        ->assertSee('Prêt pour la relecture');

    $this->actingAs($editor)
        ->get('/admin/journal?type=SUBMIT')
        ->assertOk()
        ->assertSee('Article du contributeur')
        ->assertDontSee('Article du fondateur');

    // Un contributeur ne lit que les actions de ses propres articles.
    $this->actingAs($contributor)
        ->get('/admin/journal')
        ->assertOk()
        ->assertSee('Article du contributeur')
        ->assertDontSee('Article du fondateur');
});

it('signale ce qui a changé depuis le dernier jalon', function () {
    $editor = User::factory()->editor()->create();
    $article = Article::factory()->create([
        'title' => 'Ancien titre',
        'summary' => 'Un résumé déjà écrit pour le jalon.',
    ]);

    $article->versions()->create([
        'number' => 1,
        'title' => $article->title,
        'summary' => $article->summary,
        'content' => $article->content,
        'content_hash' => ArticleVersion::hashContent($article->content),
        'author_id' => $editor->getKey(),
        'reason' => 'Soumission',
    ]);

    $this->actingAs($editor)
        ->get(route('admin.articles.show', $article))
        ->assertOk()
        ->assertSee('identique');

    $this->actingAs($editor)
        ->put(route('admin.articles.update', $article), [
            'title' => 'Nouveau titre',
            'summary' => $article->summary,
            'body' => $article->plainText(),
            'type' => $article->type->value,
            'category_id' => $article->category_id,
        ])
        ->assertRedirect();

    $this->actingAs($editor)
        ->get(route('admin.articles.show', $article))
        ->assertOk()
        ->assertSee('Modifié depuis : titre');
});
