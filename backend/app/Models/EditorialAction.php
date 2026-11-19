<?php

namespace App\Models;

use App\Enums\ArticleStatus;
use App\Enums\EditorialActionType;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Ligne du journal éditorial — CONTEXT §8.2.
 *
 * Table append-only : on n'écrit que des lignes, jamais d'UPDATE ni de DELETE.
 * Chaque transition du workflow et chaque changement de compte y laisse une
 * trace, avec son auteur et son commentaire éventuel.
 *
 * @property string $id
 * @property string $article_id
 * @property string $actor_id
 * @property EditorialActionType $type
 * @property ArticleStatus|null $from_status
 * @property ArticleStatus|null $to_status
 * @property string|null $comment
 * @property Carbon|null $created_at
 * @property-read Article $article
 * @property-read User $actor
 */
#[Fillable(['article_id', 'actor_id', 'type', 'from_status', 'to_status', 'comment'])]
class EditorialAction extends Model
{
    use HasUuids;

    /** Une action historique est immuable : pas d'updated_at. */
    public const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'type' => EditorialActionType::class,
            'from_status' => ArticleStatus::class,
            'to_status' => ArticleStatus::class,
        ];
    }

    /** @return BelongsTo<Article, $this> */
    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class);
    }

    /** @return BelongsTo<User, $this> */
    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}
