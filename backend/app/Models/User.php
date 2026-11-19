<?php

namespace App\Models;

use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
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
 * @property UserRole $role
 * @property Carbon|null $email_verified_at
 * @property Carbon|null $suspended_at
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
#[Fillable(['name', 'email', 'password_hash', 'role', 'bio', 'avatar_url', 'email_verified_at', 'suspended_at'])]
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
            'role' => UserRole::class,
            'email_verified_at' => 'datetime',
            'suspended_at' => 'datetime',
        ];
    }

    /**
     * Laravel vérifie le mot de passe via `getAuthPassword()` : le schéma
     * range le hash dans `password_hash` (CONTEXT §8.2), pas dans `password`.
     */
    public function getAuthPassword(): string
    {
        return (string) $this->password_hash;
    }

    public function isSuspended(): bool
    {
        return $this->suspended_at !== null;
    }

    /** @return HasMany<Article, $this> */
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class, 'author_id');
    }

    /** @return HasMany<ApiToken, $this> */
    public function apiTokens(): HasMany
    {
        return $this->hasMany(ApiToken::class, 'user_id');
    }
}
