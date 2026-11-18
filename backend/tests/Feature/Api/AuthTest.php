<?php

use App\Models\ApiToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;

/**
 * Authentification des lecteurs (Sprint 1).
 *
 * Chaque test passe par la route HTTP réelle, avec les mêmes paramètres que
 * l'application Flutter, et vérifie le statut comme le contenu.
 */
uses(RefreshDatabase::class);

function registerPayload(array $overrides = []): array
{
    return array_merge([
        'name' => 'Awa Koné',
        'email' => 'awa@example.test',
        'password' => 'un-mot-de-passe-solide',
        'password_confirmation' => 'un-mot-de-passe-solide',
    ], $overrides);
}

it('crée un compte lecteur et ouvre une session', function () {
    $response = $this->postJson('/api/v1/auth/register', registerPayload());

    $response->assertCreated()
        ->assertJsonPath('data.user.name', 'Awa Koné')
        ->assertJsonPath('data.user.email', 'awa@example.test')
        ->assertJsonPath('data.user.role', 'READER')
        ->assertJsonStructure([
            'data' => [
                'user' => ['id', 'name', 'email', 'role', 'email_verified'],
                'token',
            ],
        ]);

    expect($response->json('data.token'))->toBeString()->toHaveLength(64);

    $user = User::query()->where('email', 'awa@example.test')->first();
    expect($user)->not->toBeNull()
        ->and($user->role)->toBe('READER')
        ->and(Hash::check('un-mot-de-passe-solide', $user->password_hash))->toBeTrue();

    // Le jeton renvoyé ouvre bien l'espace personnel.
    $this->withToken($response->json('data.token'))
        ->getJson('/api/v1/auth/me')
        ->assertOk()
        ->assertJsonPath('data.email', 'awa@example.test');
});

it('refuse une inscription incomplète ou déjà prise', function () {
    $this->postJson('/api/v1/auth/register', registerPayload(['email' => 'pas-une-adresse']))
        ->assertStatus(422)
        ->assertJsonValidationErrors('email');

    $this->postJson('/api/v1/auth/register', registerPayload([
        'password_confirmation' => 'autre-chose',
    ]))->assertStatus(422)->assertJsonValidationErrors('password');

    $this->postJson('/api/v1/auth/register', registerPayload())->assertCreated();

    $this->postJson('/api/v1/auth/register', registerPayload(['name' => 'Awa bis']))
        ->assertStatus(422)
        ->assertJsonValidationErrors('email');

    expect(User::query()->count())->toBe(1);
});

it('ne laisse jamais choisir un rôle élevé', function () {
    $this->postJson('/api/v1/auth/register', registerPayload(['role' => 'ADMIN']))
        ->assertCreated()
        ->assertJsonPath('data.user.role', 'READER');
});

it('connecte un compte existant et refuse un mauvais mot de passe', function () {
    $this->postJson('/api/v1/auth/register', registerPayload())->assertCreated();

    $this->postJson('/api/v1/auth/login', [
        'email' => 'AWA@example.test',
        'password' => 'un-mot-de-passe-solide',
    ])->assertOk()->assertJsonPath('data.user.email', 'awa@example.test');

    $this->postJson('/api/v1/auth/login', [
        'email' => 'awa@example.test',
        'password' => 'mauvais-mot-de-passe',
    ])->assertStatus(422)
        ->assertJsonPath('error.code', 'INVALID_CREDENTIALS')
        ->assertJsonPath('error.message', 'Adresse ou mot de passe incorrect.');
});

it('protège le profil et le ferme à la déconnexion', function () {
    $this->getJson('/api/v1/auth/me')
        ->assertStatus(401)
        ->assertJsonPath('error.code', 'UNAUTHENTICATED');

    $token = $this->postJson('/api/v1/auth/register', registerPayload())
        ->json('data.token');

    $this->withToken($token)->postJson('/api/v1/auth/logout')
        ->assertOk()
        ->assertJsonPath('data.message', 'Vous êtes déconnecté.');

    expect(ApiToken::query()->count())->toBe(0);

    // Le jeton supprimé ne vaut plus rien.
    $this->withToken($token)->getJson('/api/v1/auth/me')->assertStatus(401);
});

it('refuse un compte suspendu', function () {
    $token = $this->postJson('/api/v1/auth/register', registerPayload())
        ->json('data.token');

    User::query()->where('email', 'awa@example.test')->update(['suspended_at' => now()]);

    $this->withToken($token)->getJson('/api/v1/auth/me')
        ->assertStatus(403)
        ->assertJsonPath('error.code', 'ACCOUNT_SUSPENDED');
});
