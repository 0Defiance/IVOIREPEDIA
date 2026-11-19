<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Version d'article — journal append-only des jalons (ADR-005).
 *
 * Une version n'est pas une sauvegarde automatique : elle marque un jalon
 * (soumission, publication). `content_hash` (SHA-256 du JSON canonique)
 * permet de détecter une altération ultérieure.
 *
 * @property string $id
 * @property string $article_id
 * @property int $number
 * @property string $title
 * @property string $summary
 * @property array<string, mixed> $content
 * @property string $content_hash
 * @property string $author_id
 * @property string|null $reason
 * @property Carbon|null $created_at
 * @property-read User $author
 */
#[Fillable(['article_id', 'number', 'title', 'summary', 'content', 'content_hash', 'author_id', 'reason'])]
class ArticleVersion extends Model
{
    use HasUuids;

    /** Une version est immuable : pas d'updated_at. */
    public const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'number' => 'integer',
            'content' => 'array',
        ];
    }

    /**
     * Empreinte stable d'un contenu Delta : deux JSON sémantiquement égaux
     * donnent la même empreinte, quel que soit l'ordre des clés produit par
     * PHP.
     *
     * @param  array<string, mixed>  $content
     */
    public static function hashContent(array $content): string
    {
        $json = json_encode($content, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        return hash('sha256', $json === false ? '' : $json);
    }

    /** @return BelongsTo<Article, $this> */
    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class);
    }

    /** @return BelongsTo<User, $this> */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}
