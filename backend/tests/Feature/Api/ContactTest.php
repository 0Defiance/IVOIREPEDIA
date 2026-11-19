<?php

use App\Enums\ContactMessageStatus;
use App\Models\ContactMessage;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Formulaire de contact public : chaque test passe par la route HTTP réelle,
 * avec les paramètres que l'application Flutter envoie.
 */
uses(RefreshDatabase::class);

/** @param array<string, string> $overrides */
function contactPayload(array $overrides = []): array
{
    return array_merge([
        'name' => 'Awa Koné',
        'email' => 'Awa@Example.test',
        'message' => 'La date de fondation de Katiola me semble fausse, pouvez-vous vérifier ?',
    ], $overrides);
}

it('enregistre un message et renvoie un accusé de réception', function () {
    $this->postJson('/api/v1/contact', contactPayload())
        ->assertCreated()
        ->assertJsonPath('data.status', 'NEW')
        ->assertJsonStructure(['data' => ['id', 'status']]);

    $message = ContactMessage::query()->sole();

    expect($message->name)->toBe('Awa Koné')
        ->and($message->email)->toBe('awa@example.test')
        ->and($message->status)->toBe(ContactMessageStatus::NEW)
        ->and($message->handled_at)->toBeNull();
});

it('accepte un message sans nom ni adresse', function () {
    $this->postJson('/api/v1/contact', [
        'message' => 'Une source plus récente existe pour le recensement de 2021.',
    ])->assertCreated();

    $message = ContactMessage::query()->sole();

    expect($message->name)->toBeNull()
        ->and($message->email)->toBeNull();
});

it('refuse un message vide ou trop court', function () {
    $this->postJson('/api/v1/contact', ['message' => 'Trop court'])
        ->assertStatus(422)
        ->assertJsonValidationErrors('message');

    $this->postJson('/api/v1/contact', [])
        ->assertStatus(422)
        ->assertJsonValidationErrors('message');

    expect(ContactMessage::query()->count())->toBe(0);
});

it('refuse une adresse électronique invalide', function () {
    $this->postJson('/api/v1/contact', contactPayload(['email' => 'pas-une-adresse']))
        ->assertStatus(422)
        ->assertJsonValidationErrors('email');

    expect(ContactMessage::query()->count())->toBe(0);
});

it('refuse un message qui remplit le piège à robots', function () {
    $this->postJson('/api/v1/contact', contactPayload(['website' => 'https://spam.test']))
        ->assertStatus(422)
        ->assertJsonValidationErrors('website');

    expect(ContactMessage::query()->count())->toBe(0);
});

it('plafonne les envois pour éviter le dépôt en masse', function () {
    for ($i = 0; $i < 5; $i++) {
        $this->postJson('/api/v1/contact', contactPayload())
            ->assertCreated();
    }

    $this->postJson('/api/v1/contact', contactPayload())
        ->assertStatus(429);

    expect(ContactMessage::query()->count())->toBe(5);
});
