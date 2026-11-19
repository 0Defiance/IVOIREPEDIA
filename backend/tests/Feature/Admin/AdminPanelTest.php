<?php

use App\Enums\ArticleStatus;
use App\Enums\UserRole;
use App\Models\ApiToken;
use App\Models\Article;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;

/**
 * Panneau éditorial : accès, listes filtrées par rôle, rédaction, comptes.
 *
 * Le panneau est protégé par une session (cookies + CSRF), pas par les jetons
 * porteurs de l'API : ces tests suivent le parcours réel d'un membre de la
 * rédaction qui ouvre /admin dans un navigateur.
 */
uses(RefreshDatabase::class);

it('renvoie un visiteur vers la connexion', function () {
    $this->get('/admin')->assertRedirect('/admin/connexion');
});

it('ferme le panneau à un lecteur', function () {
    $reader = User::factory()->create();

    $this->actingAs($reader)->get('/admin')->assertForbidden();
});

it('accueille un contributeur sans lui montrer la file de relecture', function () {
    $contributor = User::factory()->contributor()->create();
    $theirs = Article::factory()->submitted()->create(['title' => 'L’article d’une autre personne']);

    $this->actingAs($contributor)
        ->get('/admin')
        ->assertOk()
        ->assertSee('Tableau de bord')
        ->assertDontSee('File de relecture')
        ->assertDontSee($theirs->title);
});

it('montre la file de relecture à un éditeur', function () {
    $editor = User::factory()->editor()->create();
    $article = Article::factory()->submitted()->create(['title' => 'Un article qui attend une décision']);

    $this->actingAs($editor)
        ->get('/admin')
        ->assertOk()
        ->assertSee('File de relecture')
        ->assertSee($article->title);
});

it('ne montre à un contributeur que ses propres articles', function () {
    $contributor = User::factory()->contributor()->create();
    $mine = Article::factory()->by($contributor)->create(['title' => 'Mon brouillon à moi']);
    $theirs = Article::factory()->create(['title' => 'Le brouillon d’un autre']);

    $this->actingAs($contributor)
        ->get('/admin/articles')
        ->assertOk()
        ->assertSee($mine->title)
        ->assertDontSee($theirs->title);

    $editor = User::factory()->editor()->create();

    $this->actingAs($editor)
        ->get('/admin/articles')
        ->assertOk()
        ->assertSee($theirs->title);
});

it('crée un brouillon depuis le panneau', function () {
    $contributor = User::factory()->contributor()->create();
    $category = Category::factory()->create();

    $this->actingAs($contributor)
        ->post('/admin/articles', [
            'title' => 'La lagune Ébrié',
            'summary' => 'Une lagune qui structure la vie d’Abidjan et de ses villages.',
            'body' => "## Un plan d’eau habité\n\nLes villages lagunaires vivent de la pêche.\n\nLa lagune borde plusieurs communes.",
            'type' => 'REGION',
            'category_id' => $category->getKey(),
            'reference_title' => 'Atlas de la Côte d’Ivoire',
            'reference_publisher' => 'IGN',
        ])
        ->assertRedirect();

    $article = Article::query()->where('title', 'La lagune Ébrié')->firstOrFail();

    expect($article->status)->toBe(ArticleStatus::DRAFT)
        ->and($article->author_id)->toBe($contributor->getKey())
        ->and($article->slug)->toBe('la-lagune-ebrie')
        ->and($article->content['ops'])->toHaveCount(3)
        ->and($article->references()->count())->toBe(1)
        ->and($article->plainText())->toContain('villages lagunaires');
});

it('refuse un article sans corps ni catégorie', function () {
    $contributor = User::factory()->contributor()->create();

    $this->actingAs($contributor)
        ->post('/admin/articles', [
            'title' => 'Titre',
            'summary' => 'Résumé suffisamment long pour passer.',
            'body' => 'court',
            'type' => 'TOPIC',
        ])
        ->assertSessionHasErrors(['body', 'category_id']);

    expect(Article::query()->count())->toBe(0);
});

it('connecte un éditeur par la session du panneau', function () {
    $editor = User::factory()->editor()->create([
        'password_hash' => Hash::make('motdepasse-solide'),
    ]);

    $this->post('/admin/connexion', [
        'email' => $editor->email,
        'password' => 'motdepasse-solide',
    ])->assertRedirect('/admin');

    $this->assertAuthenticatedAs($editor);
});

it('refuse un mauvais mot de passe et un compte sans droit éditorial', function () {
    $editor = User::factory()->editor()->create([
        'password_hash' => Hash::make('motdepasse-solide'),
    ]);

    $this->post('/admin/connexion', [
        'email' => $editor->email,
        'password' => 'mauvais-mot-de-passe',
    ])->assertSessionHasErrors('email');

    $this->assertGuest();

    $reader = User::factory()->create([
        'password_hash' => Hash::make('motdepasse-solide'),
    ]);

    $this->post('/admin/connexion', [
        'email' => $reader->email,
        'password' => 'motdepasse-solide',
    ])->assertSessionHasErrors('email');

    $this->assertGuest();
});

it('refuse un compte suspendu', function () {
    $editor = User::factory()->editor()->suspended()->create([
        'password_hash' => Hash::make('motdepasse-solide'),
    ]);

    $this->post('/admin/connexion', [
        'email' => $editor->email,
        'password' => 'motdepasse-solide',
    ])->assertSessionHasErrors('email');

    $this->assertGuest();
});

it('laisse un administrateur changer un rôle', function () {
    $admin = User::factory()->admin()->create();
    $contributor = User::factory()->contributor()->create();

    $this->actingAs($admin)
        ->patch(route('admin.users.role', $contributor), ['role' => 'EDITOR'])
        ->assertRedirect();

    expect($contributor->refresh()->role)->toBe(UserRole::EDITOR);
});

it('ferme la gestion des comptes aux éditeurs', function () {
    $editor = User::factory()->editor()->create();
    $contributor = User::factory()->contributor()->create();

    $this->actingAs($editor)->get('/admin/utilisateurs')->assertForbidden();

    $this->actingAs($editor)
        ->patch(route('admin.users.role', $contributor), ['role' => 'EDITOR'])
        ->assertForbidden();

    expect($contributor->refresh()->role)->toBe(UserRole::CONTRIBUTOR);
});

it('empêche un administrateur de se retirer ses droits', function () {
    $admin = User::factory()->admin()->create();

    $this->actingAs($admin)
        ->patch(route('admin.users.role', $admin), ['role' => 'READER'])
        ->assertForbidden();

    expect($admin->refresh()->role)->toBe(UserRole::ADMIN);
});

it('suspend un compte et révoque ses jetons, puis le réactive', function () {
    $admin = User::factory()->admin()->create();
    $member = User::factory()->contributor()->create();

    $token = ApiToken::issue($member);

    // L'API s'authentifie par jeton, pas par la session du panneau.
    $this->withToken($token)->getJson('/api/v1/auth/me')->assertOk();
    $this->flushHeaders();

    $this->actingAs($admin)
        ->post(route('admin.users.suspend', $member))
        ->assertRedirect();

    expect($member->refresh()->isSuspended())->toBeTrue()
        ->and(ApiToken::query()->count())->toBe(0);

    $this->withToken($token)->getJson('/api/v1/auth/me')->assertStatus(401);

    $this->actingAs($admin)
        ->post(route('admin.users.reinstate', $member))
        ->assertRedirect();

    expect($member->refresh()->isSuspended())->toBeFalse();
});
