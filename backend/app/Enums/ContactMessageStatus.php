<?php

namespace App\Enums;

/**
 * Suivi d'un message de contact : rien n'est supprimé, un message est
 * simplement marqué comme traité quand l'équipe y a répondu.
 */
enum ContactMessageStatus: string
{
    case NEW = 'NEW';
    case HANDLED = 'HANDLED';

    public function label(): string
    {
        return match ($this) {
            self::NEW => 'À traiter',
            self::HANDLED => 'Traité',
        };
    }

    /** Classes de la pastille de statut dans le panneau. */
    public function tone(): string
    {
        return match ($this) {
            self::NEW => 'submitted',
            self::HANDLED => 'published',
        };
    }
}
