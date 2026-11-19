<?php

namespace App\Services;

use App\Exceptions\ResetLinkException;
use App\Models\User;
use App\Notifications\ResetPasswordNotification;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Réinitialisation du mot de passe.
 *
 * Le schéma du projet dispose déjà de `verification_tokens` (CONTEXT §8.2) :
 * on y range l'empreinte SHA-256 d'un jeton à usage unique, valable une heure.
 * Aucun jeton en clair n'est conservé, et une demande ne révèle jamais si
 * l'adresse correspond à un compte.
 */
final class PasswordResetService
{
    public const TTL_MINUTES = 60;

    /** Délai minimal entre deux demandes pour le même compte. */
    public const COOLDOWN_SECONDS = 60;

    public const TYPE = 'PASSWORD_RESET';

    /**
     * Envoie un lien si le compte existe. Silencieux sinon : c'est ce qui
     * empêche d'utiliser ce formulaire pour découvrir les adresses inscrites.
     */
    public function request(string $email): void
    {
        $user = User::query()->where('email', mb_strtolower(trim($email)))->first();

        if ($user === null || $user->isSuspended()) {
            return;
        }

        $last = DB::table('verification_tokens')
            ->where('user_id', $user->getKey())
            ->where('type', self::TYPE)
            ->latest('created_at')
            ->first();

        if ($last !== null && Carbon::parse($last->created_at)->gt(now()->subSeconds(self::COOLDOWN_SECONDS))) {
            return; // une demande vient d'être faite : on n'en envoie pas une seconde
        }

        $plain = Str::random(48);

        DB::table('verification_tokens')->insert([
            'id' => (string) Str::uuid(),
            'user_id' => $user->getKey(),
            'type' => self::TYPE,
            'token_hash' => hash('sha256', $plain),
            'expires_at' => now()->addMinutes(self::TTL_MINUTES),
            'used_at' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $user->notify(new ResetPasswordNotification($plain));
    }

    /**
     * Change le mot de passe et brûle le jeton.
     *
     * @throws ResetLinkException
     */
    public function reset(string $email, string $token, string $password): void
    {
        $user = User::query()->where('email', mb_strtolower(trim($email)))->first();

        if ($user === null) {
            throw new ResetLinkException;
        }

        $row = DB::table('verification_tokens')
            ->where('user_id', $user->getKey())
            ->where('type', self::TYPE)
            ->where('token_hash', hash('sha256', $token))
            ->whereNull('used_at')
            ->first();

        if ($row === null || Carbon::parse($row->expires_at)->isPast()) {
            throw new ResetLinkException;
        }

        DB::transaction(function () use ($user, $row, $password): void {
            $user->forceFill(['password_hash' => Hash::make($password)])->save();

            DB::table('verification_tokens')->where('id', $row->id)->update([
                'used_at' => now(),
                'updated_at' => now(),
            ]);

            // Un mot de passe changé ferme les sessions ouvertes ailleurs.
            $user->apiTokens()->delete();
        });
    }
}
