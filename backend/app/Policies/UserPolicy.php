<?php

namespace App\Policies;

use App\Enums\UserRole;
use App\Models\User;

/**
 * Gestion des comptes — ADMIN seulement (CONTEXT §10).
 *
 * Deux garde-fous protègent le dernier administrateur : personne ne peut se
 * retirer ses propres droits ni suspendre le seul ADMIN restant, sinon le
 * panneau devient inaccessible sans intervention en base.
 */
class UserPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->role->canManageUsers();
    }

    public function update(User $user, User $target): bool
    {
        return $user->role->canManageUsers();
    }

    public function changeRole(User $user, User $target): bool
    {
        if (! $user->role->canManageUsers() || $user->is($target)) {
            return false;
        }

        return $this->otherAdminExists($target);
    }

    public function suspend(User $user, User $target): bool
    {
        if (! $user->role->canManageUsers() || $user->is($target)) {
            return false;
        }

        return $this->otherAdminExists($target);
    }

    /** Restaurer un compte n'est jamais bloquant, sauf pour soi-même. */
    public function reinstate(User $user, User $target): bool
    {
        return $user->role->canManageUsers() && ! $user->is($target);
    }

    /** Le compte visé est-il le dernier ADMIN actif ? */
    private function otherAdminExists(User $target): bool
    {
        if ($target->role !== UserRole::ADMIN) {
            return true;
        }

        return User::query()
            ->where('role', UserRole::ADMIN->value)
            ->whereNull('suspended_at')
            ->whereKeyNot($target->getKey())
            ->exists();
    }
}
