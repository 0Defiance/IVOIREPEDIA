<?php

namespace App\Enums;

/**
 * Rôles éditoriaux — CONTEXT §10 (source de vérité).
 *
 * Stockés en base sous forme de chaîne (`users.role`). La hiérarchie est
 * stricte : chaque rôle reprend les droits du précédent, sauf la révision,
 * qui reste réservée aux EDITOR et ADMIN.
 */
enum UserRole: string
{
    case READER = 'READER';
    case CONTRIBUTOR = 'CONTRIBUTOR';
    case EDITOR = 'EDITOR';
    case ADMIN = 'ADMIN';

    /** Rang dans la hiérarchie : un rôle supérieur inclut les droits du précédent. */
    public function rank(): int
    {
        return match ($this) {
            self::READER => 0,
            self::CONTRIBUTOR => 1,
            self::EDITOR => 2,
            self::ADMIN => 3,
        };
    }

    /** Proposer un article : rédiger, modifier son brouillon, le soumettre. */
    public function canContribute(): bool
    {
        return $this->rank() >= self::CONTRIBUTOR->rank();
    }

    /** Réviser, approuver, publier, archiver, corriger un article publié. */
    public function canReview(): bool
    {
        return $this->rank() >= self::EDITOR->rank();
    }

    /** Gérer les comptes, les rôles et les suspensions. */
    public function canManageUsers(): bool
    {
        return $this === self::ADMIN;
    }

    /** Libellé affiché dans le panneau d'administration. */
    public function label(): string
    {
        return match ($this) {
            self::READER => 'Lecteur',
            self::CONTRIBUTOR => 'Contributeur',
            self::EDITOR => 'Éditeur',
            self::ADMIN => 'Administrateur',
        };
    }

    /** Rôles proposés dans le panneau, du plus étroit au plus large. */
    public static function assignable(): array
    {
        return [self::READER, self::CONTRIBUTOR, self::EDITOR, self::ADMIN];
    }
}
