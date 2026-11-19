<?php

namespace App\Models;

use App\Enums\ContactMessageStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * Message d'un lecteur, envoyé depuis la page « Contact » du site.
 *
 * Le nom et l'adresse sont facultatifs : on peut signaler une erreur sans
 * créer un compte. Sans adresse, aucune réponse n'est possible — la page le
 * dit avant l'envoi.
 *
 * @property string $id
 * @property string|null $name
 * @property string|null $email
 * @property string $message
 * @property ContactMessageStatus $status
 * @property Carbon|null $handled_at
 * @property Carbon|null $created_at
 */
#[Fillable(['name', 'email', 'message', 'status', 'handled_at'])]
class ContactMessage extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => ContactMessageStatus::class,
            'handled_at' => 'datetime',
        ];
    }
}
