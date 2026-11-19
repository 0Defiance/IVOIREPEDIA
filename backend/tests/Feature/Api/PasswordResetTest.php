<?php

use App\Models\ApiToken;
use App\Models\User;
use App\Notifications\ResetPasswordNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;

/**
 * Mot de passe oublié : demande, courriel, consommation du lien.
 *
 * Le jeton en clair n'existe que dans le courriel : la base ne garde que son
 * empreinte SHA-256. Les tests le lisent donc dans la notification.
 */
uses(RefreshDatabase::class);

function requestReset(string $email)
{
    return test()->postJson('/api/v1/auth/forgot-password', ['email' => $email]);
}

/** Jeton en clair envoyé par le courriel de réinitialisation. */
function capturedToken(User $user): string
{
    $token = null;

    Notification::assertSentTo($user, ResetPasswordNotification::class, function (ResetPasswordNotification $notification) use (&$token): bool {
        $token = $notification->token;

        return true;
    });

    return (string) $token;
}

it('envoie un lien de réinitialisation à un compte connu', function () {
    Notification::fake();

    $user = User::factory()->create(['email' => 'awa@example.test']);

    requestReset('AWA@example.test')
        ->assertOk()
        ->assertJsonPath('data.message', 'Si un compte existe avec cette adresse, un lien vient de lui être envoyé.');

    Notification::assertSentTo($user, ResetPasswordNotification::class);

    $row = DB::table('verification_tokens')->where('user_id', $user->getKey())->first();

    expect($row)->not->toBeNull()
        ->and($row->type)->toBe('PASSWORD_RESET')
        ->and($row->token_hash)->toHaveLength(64)
        ->and($row->used_at)->toBeNull();
});

it('répond la même chose pour une adresse inconnue, sans rien envoyer', function () {
    Notification::fake();

    requestReset('inconnu@example.test')
        ->assertOk()
        ->assertJsonPath('data.message', 'Si un compte existe avec cette adresse, un lien vient de lui être envoyé.');

    Notification::assertNothingSent();
    expect(DB::table('verification_tokens')->count())->toBe(0);
});

it('change le mot de passe avec un lien valide et le brûle', function () {
    Notification::fake();

    $user = User::factory()->create(['email' => 'awa@example.test']);
    ApiToken::issue($user);

    requestReset('awa@example.test')->assertOk();
    $token = capturedToken($user);

    $this->postJson('/api/v1/auth/reset-password', [
        'email' => 'awa@example.test',
        'token' => $token,
        'password' => 'nouveau-mot-de-passe',
        'password_confirmation' => 'nouveau-mot-de-passe',
    ])->assertOk()
        ->assertJsonPath('data.message', 'Votre mot de passe est changé. Vous pouvez vous connecter.');

    expect(Hash::check('nouveau-mot-de-passe', $user->refresh()->password_hash))->toBeTrue()
        ->and(ApiToken::query()->count())->toBe(0);

    // Le même lien ne sert qu'une fois.
    $this->postJson('/api/v1/auth/reset-password', [
        'email' => 'awa@example.test',
        'token' => $token,
        'password' => 'encore-un-autre',
        'password_confirmation' => 'encore-un-autre',
    ])->assertStatus(422)
        ->assertJsonPath('error.code', 'INVALID_RESET_TOKEN');
});

it('refuse un lien expiré ou inconnu', function () {
    $user = User::factory()->create(['email' => 'awa@example.test']);

    DB::table('verification_tokens')->insert([
        'id' => (string) Str::uuid(),
        'user_id' => $user->getKey(),
        'type' => 'PASSWORD_RESET',
        'token_hash' => hash('sha256', 'jeton-expire-depuis-longtemps'),
        'expires_at' => now()->subMinute(),
        'used_at' => null,
        'created_at' => now()->subHour(),
        'updated_at' => now()->subHour(),
    ]);

    foreach (['jeton-expire-depuis-longtemps', 'jeton-qui-n-existe-pas-du-tout'] as $token) {
        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'awa@example.test',
            'token' => $token,
            'password' => 'nouveau-mot-de-passe',
            'password_confirmation' => 'nouveau-mot-de-passe',
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'INVALID_RESET_TOKEN');
    }

    expect(Hash::check('password', $user->refresh()->password_hash))->toBeTrue();
});

it('valide le nouveau mot de passe', function () {
    $this->postJson('/api/v1/auth/reset-password', [
        'email' => 'awa@example.test',
        'token' => 'un-jeton-assez-long-pour-passer',
        'password' => 'court',
        'password_confirmation' => 'différent',
    ])->assertStatus(422)
        ->assertJsonValidationErrors(['password']);
});

it('ne renvoie pas de second courriel dans la minute', function () {
    Notification::fake();

    $user = User::factory()->create(['email' => 'awa@example.test']);

    requestReset('awa@example.test')->assertOk();
    requestReset('awa@example.test')->assertOk();

    Notification::assertSentToTimes($user, ResetPasswordNotification::class, 1);
});
