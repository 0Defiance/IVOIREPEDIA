<?php

namespace Database\Factories;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            // Schéma §8.2 : la colonne s'appelle password_hash.
            'password_hash' => static::$password ??= Hash::make('password'),
            'role' => UserRole::READER,
        ];
    }

    /** Compte qui peut rédiger et soumettre. */
    public function contributor(): static
    {
        return $this->state(fn (array $attributes) => ['role' => UserRole::CONTRIBUTOR]);
    }

    /** Compte qui révise, approuve et publie. */
    public function editor(): static
    {
        return $this->state(fn (array $attributes) => ['role' => UserRole::EDITOR]);
    }

    /** Compte qui administre les comptes et supprime. */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => ['role' => UserRole::ADMIN]);
    }

    /** Compte suspendu : ne peut plus se connecter. */
    public function suspended(): static
    {
        return $this->state(fn (array $attributes) => ['suspended_at' => now()]);
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
