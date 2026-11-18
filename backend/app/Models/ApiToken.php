<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

/**
 * Jeton d'API personnel — équivalent minimal de Sanctum, sans dépendance.
 *
 * Seule l'empreinte du jeton est stockée : le porteur ne peut pas le relire
 * depuis la base. Chaque jeton est rattaché à un utilisateur et expire au bout
 * de soixante jours ; la déconnexion le supprime.
 *
 * @property string $id
 * @property string $user_id
 * @property string $name
 * @property string $token_hash
 * @property Carbon|null $last_used_at
 * @property Carbon|null $expires_at
 * @property-read User|null $user
 */
class ApiToken extends Model
{
    use HasUuids;

    public $incrementing = false;

    protected $keyType = 'string';

    /** @var list<string> */
    protected $fillable = ['user_id', 'name', 'token_hash', 'last_used_at', 'expires_at'];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'last_used_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Émet un jeton pour cet utilisateur et renvoie sa valeur en clair.
     *
     * La valeur n'est jamais conservée : elle n'existe que dans la réponse
     * HTTP, que l'application range ensuite dans le stockage du navigateur.
     */
    public static function issue(User $user, string $name = 'web', int $days = 60): string
    {
        $plain = Str::random(64);

        self::create([
            'user_id' => $user->getKey(),
            'name' => $name,
            'token_hash' => hash('sha256', $plain),
            'expires_at' => now()->addDays($days),
        ]);

        return $plain;
    }

    /** Retrouve un jeton valide à partir de sa valeur en clair. */
    public static function findValid(string $plain): ?self
    {
        $token = self::query()
            ->with('user')
            ->where('token_hash', hash('sha256', $plain))
            ->first();

        if ($token === null) {
            return null;
        }

        if ($token->expires_at !== null && $token->expires_at->isPast()) {
            return null;
        }

        return $token;
    }
}
