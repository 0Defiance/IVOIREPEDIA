<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Référence bibliographique d'un article — CONTEXT §8.2.
 * La table s'appelle `article_references` (`references` est réservé en MySQL)
 * et l'ordre d'affichage est porté par `position`.
 *
 * @property string $id
 * @property string $article_id
 * @property int $position
 * @property string $kind
 * @property string|null $authors
 * @property string $title
 * @property string|null $publisher
 * @property int|null $year
 * @property string|null $url
 * @property Carbon|null $accessed_at
 * @property string|null $note
 */
#[Fillable([
    'article_id', 'position', 'kind', 'authors', 'title', 'publisher',
    'year', 'url', 'accessed_at', 'note',
])]
class ArticleReference extends Model
{
    use HasUuids;

    protected $table = 'article_references';

    /** La table ne porte pas de colonnes de dates (CONTEXT §8.2). */
    public $timestamps = false;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'position' => 'integer',
            'year' => 'integer',
            'accessed_at' => 'date',
        ];
    }

    /** @return BelongsTo<Article, $this> */
    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class);
    }
}
