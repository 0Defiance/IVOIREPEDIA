<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Carbon;

/**
 * Utilisateur — schéma CONTEXT §8.2 : identifiant UUID, hash bcrypt dans
 * `password_hash`, rôle éditorial en chaîne (enum PHP cf. Sprint 1).
 *
 * @property string $id
 * @property string $name
 * @property string $email
 * @property string $password_hash
 * @property string $role
 * @property Carbon|null $email_verified_at
 * @property Carbon|null $suspended_at
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
#[Fillable(['name', 'email', 'password_hash', 'role', 'bio', 'avatar_url', 'email_verified_at'])]
#[Hidden(['password_hash', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, HasUuids, Notifiable;

    /** La colonne s'appelle password_hash (§8.2), pas le défaut `password`. */
    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'suspended_at' => 'datetime',
        ];
    }
}
