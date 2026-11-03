<?php

namespace App\Enums;

/**
 * Types d'article. Seuls `BIOGRAPHY`, `REGION` et `INSTITUTION` portent une
 * infobox structurée au MVP (CONTEXT §8.3) ; `TOPIC` couvre les sujets qui
 * n'entrent dans aucune de ces trois formes (« autres types : infobox absente
 * au MVP »).
 */
enum ArticleType: string
{
    case BIOGRAPHY = 'BIOGRAPHY';
    case REGION = 'REGION';
    case INSTITUTION = 'INSTITUTION';
    case TOPIC = 'TOPIC';

    /** Libellé affiché dans l'interface (français). */
    public function label(): string
    {
        return match ($this) {
            self::BIOGRAPHY => 'Biographie',
            self::REGION => 'Territoire',
            self::INSTITUTION => 'Institution',
            self::TOPIC => 'Sujet',
        };
    }
}
