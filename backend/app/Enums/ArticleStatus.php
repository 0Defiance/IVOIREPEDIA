<?php

namespace App\Enums;

/**
 * Statuts du workflow éditorial — CONTEXT §9.1/§9.2 (source de vérité).
 * Stockés en base sous forme de chaîne (`articles.status`).
 */
enum ArticleStatus: string
{
    case DRAFT = 'DRAFT';
    case SUBMITTED = 'SUBMITTED';
    case IN_REVIEW = 'IN_REVIEW';
    case REVISION_REQUESTED = 'REVISION_REQUESTED';
    case APPROVED = 'APPROVED';
    case PUBLISHED = 'PUBLISHED';
    case ARCHIVED = 'ARCHIVED';
    case DELETED = 'DELETED';

    /** Seul statut visible du grand public (CONTEXT §11.1). */
    public function isPublic(): bool
    {
        return $this === self::PUBLISHED;
    }

    /** Libellé français, pour le panneau éditorial. */
    public function label(): string
    {
        return match ($this) {
            self::DRAFT => 'Brouillon',
            self::SUBMITTED => 'Soumis',
            self::IN_REVIEW => 'En relecture',
            self::REVISION_REQUESTED => 'Révision demandée',
            self::APPROVED => 'Approuvé',
            self::PUBLISHED => 'Publié',
            self::ARCHIVED => 'Archivé',
            self::DELETED => 'Supprimé',
        };
    }

    /** Classes de la pastille de statut dans le panneau. */
    public function tone(): string
    {
        return match ($this) {
            self::DRAFT => 'draft',
            self::SUBMITTED => 'submitted',
            self::IN_REVIEW => 'in_review',
            self::REVISION_REQUESTED => 'revision_requested',
            self::APPROVED => 'approved',
            self::PUBLISHED => 'published',
            self::ARCHIVED => 'archived',
            self::DELETED => 'deleted',
        };
    }
}
