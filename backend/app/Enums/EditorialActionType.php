<?php

namespace App\Enums;

/**
 * Types d'action du journal éditorial (`editorial_actions.type`).
 *
 * La table est append-only : une action n'est jamais modifiée ni supprimée.
 * Chaque transition du workflow y laisse une ligne, avec son auteur.
 */
enum EditorialActionType: string
{
    case SUBMIT = 'SUBMIT';
    case START_REVIEW = 'START_REVIEW';
    case REQUEST_REVISION = 'REQUEST_REVISION';
    case APPROVE = 'APPROVE';
    case PUBLISH = 'PUBLISH';
    case ARCHIVE = 'ARCHIVE';
    case RESTORE = 'RESTORE';
    case DELETE = 'DELETE';
    case EDIT = 'EDIT';
    case ROLE_CHANGE = 'ROLE_CHANGE';
    case SUSPEND = 'SUSPEND';
    case REINSTATE = 'REINSTATE';

    /** Nom d'action du workflow (§9.2) → type de journal. */
    public static function forAction(string $action): self
    {
        return match ($action) {
            'submit' => self::SUBMIT,
            'start_review' => self::START_REVIEW,
            'request_revision' => self::REQUEST_REVISION,
            'approve' => self::APPROVE,
            'publish' => self::PUBLISH,
            'archive' => self::ARCHIVE,
            'restore' => self::RESTORE,
            'delete' => self::DELETE,
            default => throw new \InvalidArgumentException("Action inconnue : {$action}"),
        };
    }

    /** Libellé français du journal. */
    public function label(): string
    {
        return match ($this) {
            self::SUBMIT => 'Soumission',
            self::START_REVIEW => 'Prise en relecture',
            self::REQUEST_REVISION => 'Révision demandée',
            self::APPROVE => 'Approbation',
            self::PUBLISH => 'Publication',
            self::ARCHIVE => 'Archivage',
            self::RESTORE => 'Restauration',
            self::DELETE => 'Suppression',
            self::EDIT => 'Modification',
            self::ROLE_CHANGE => 'Changement de rôle',
            self::SUSPEND => 'Suspension',
            self::REINSTATE => 'Réactivation',
        };
    }
}
