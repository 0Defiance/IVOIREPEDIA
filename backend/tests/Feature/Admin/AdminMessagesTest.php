<?php

use App\Enums\ContactMessageStatus;
use App\Models\ContactMessage;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Messages de contact dans le panneau : la file de travail éditoriale.
 */
uses(RefreshDatabase::class);

function contactMessage(array $attributes = []): ContactMessage
{
    return ContactMessage::query()->create(array_merge([
        'name' => 'Awa Koné',
        'email' => 'awa@example.test',
        'message' => 'La date de fondation de Katiola me semble fausse.',
        'status' => ContactMessageStatus::NEW,
    ], $attributes));
}

it('montre les messages à traiter à un éditeur', function () {
    $editor = User::factory()->editor()->create();
    contactMessage();

    $this->actingAs($editor)
        ->get('/admin/messages')
        ->assertOk()
        ->assertSee('La date de fondation de Katiola me semble fausse.')
        ->assertSee('awa@example.test');
});

it('sépare les messages traités de la file', function () {
    $editor = User::factory()->editor()->create();
    $handled = contactMessage([
        'message' => 'Ancienne demande déjà réglée.',
        'status' => ContactMessageStatus::HANDLED,
        'handled_at' => now(),
    ]);

    $this->actingAs($editor)
        ->get('/admin/messages')
        ->assertOk()
        ->assertDontSee($handled->message);

    $this->actingAs($editor)
        ->get('/admin/messages?traites=1')
        ->assertOk()
        ->assertSee($handled->message);
});

it('marque un message comme traité et le retire de la file', function () {
    $editor = User::factory()->editor()->create();
    $message = contactMessage();

    $this->actingAs($editor)
        ->post("/admin/messages/{$message->id}/traiter")
        ->assertRedirect();

    $message->refresh();

    expect($message->status)->toBe(ContactMessageStatus::HANDLED)
        ->and($message->handled_at)->not->toBeNull();

    $this->actingAs($editor)
        ->get('/admin/messages')
        ->assertOk()
        ->assertDontSee($message->message);
});

it('refuse les messages à un contributeur', function () {
    $contributor = User::factory()->contributor()->create();
    contactMessage();

    $this->actingAs($contributor)
        ->get('/admin/messages')
        ->assertForbidden();
});

it('renvoie un visiteur vers la connexion du panneau', function () {
    $this->get('/admin/messages')->assertRedirect(route('admin.login'));
});
