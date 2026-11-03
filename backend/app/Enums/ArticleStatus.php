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
}
