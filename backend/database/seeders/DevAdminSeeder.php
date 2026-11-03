<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Compte ADMIN de développement — uniquement pour travailler en local
 * (rôle élevé via phpMyAdmin avant que l'UI admin n'existe, Sprint 5).
 * L'email est unique : rejouer le seeder ne crée pas de doublon.
 */
class DevAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = 'admin@ivoirepedia.test';

        if (app()->environment('production')) {
            return; // jamais de compte de dev en production
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'id' => (string) Str::uuid(),
                'name' => 'Admin de dev',
                'password_hash' => Hash::make('password'),
                'role' => 'ADMIN',
                'email_verified_at' => now(),
            ],
        );
    }
}
