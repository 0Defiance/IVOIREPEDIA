<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * Récit de la section « Histoire incroyable ».
 *
 * Chaque récit porte sa source : sans document vérifiable, il n'est pas publié.
 *
 * @property string $slug
 * @property string $title
 * @property string|null $period
 * @property string $teaser
 * @property array<int, string> $paragraphs
 * @property array<int, array<string, string>>|null $figures
 * @property int $position
 */
#[Fillable([
    'slug', 'title', 'period', 'teaser', 'paragraphs', 'figures',
    'source_title', 'source_publisher', 'source_year', 'source_url', 'position',
])]
class HistoryStory extends Model
{
    use HasUuids;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'paragraphs' => 'array',
            'figures' => 'array',
            'source_year' => 'integer',
            'position' => 'integer',
        ];
    }
}
