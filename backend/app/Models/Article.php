<?php

namespace App\Models;

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;

/**
 * Article encyclopédique — CONTEXT §8.2/§8.3.
 *
 * `content` et `infobox` sont du JSON : Delta Quill, jamais de HTML (ADR-003),
 * ce qui évite toute injection de balises côté lecture publique.
 *
 * @property string $id
 * @property string $title
 * @property string $slug
 * @property string $summary
 * @property array<string, mixed> $content
 * @property array<string, mixed>|null $infobox
 * @property ArticleType $type
 * @property ArticleStatus $status
 * @property string|null $cover_image_url
 * @property string|null $cover_image_alt
 * @property Carbon|null $published_at
 * @property Carbon|null $updated_at
 * @property-read Category $category
 * @property-read User $author
 * @property-read Collection<int, Tag> $tags
 * @property-read Collection<int, ArticleReference> $references
 */
#[Fillable([
    'title', 'slug', 'summary', 'content', 'infobox', 'type', 'status',
    'cover_image_url', 'cover_image_alt', 'lock_version', 'current_version',
    'author_id', 'category_id', 'published_at',
])]
class Article extends Model
{
    use HasUuids, SoftDeletes;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'content' => 'array',
            'infobox' => 'array',
            'type' => ArticleType::class,
            'status' => ArticleStatus::class,
            'published_at' => 'datetime',
            'lock_version' => 'integer',
            'current_version' => 'integer',
        ];
    }

    /**
     * Univers de la lecture publique : publié ET daté (un article programmé
     * n'apparaît pas avant son heure). Cf. CONTEXT §11.1.
     *
     * @param  Builder<Article>  $query
     */
    public function scopePublished(Builder $query): void
    {
        $query->where('status', ArticleStatus::PUBLISHED)
            ->whereNotNull('published_at')
            ->where('published_at', '<=', now());
    }

    /** @param  Builder<Article>  $query */
    public function scopeInCategory(Builder $query, string $slug): void
    {
        $query->whereHas('category', fn (Builder $q) => $q->where('slug', $slug));
    }

    /** @param  Builder<Article>  $query */
    public function scopeTaggedWith(Builder $query, string $slug): void
    {
        $query->whereHas('tags', fn (Builder $q) => $q->where('slug', $slug));
    }

    /** Recherche simple : titre, résumé, et nom de catégorie (RCH-01). */
    public function scopeMatching(Builder $query, string $term): void
    {
        $like = '%'.str_replace(['%', '_'], ['\%', '\_'], $term).'%';

        $query->where(function (Builder $q) use ($like): void {
            $q->where('title', 'like', $like)
                ->orWhere('summary', 'like', $like);
        });
    }

    /** @return BelongsTo<User, $this> */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    /** @return BelongsTo<Category, $this> */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /** @return BelongsToMany<Tag, $this> */
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'article_tag');
    }

    /** @return HasMany<ArticleReference, $this> */
    public function references(): HasMany
    {
        return $this->hasMany(ArticleReference::class)->orderBy('position');
    }

    /** Temps de lecture estimé (≈ 200 mots/minute), pour l'interface. */
    public function readingMinutes(): int
    {
        $text = '';
        $ops = $this->content['ops'] ?? [];

        if (is_array($ops)) {
            foreach ($ops as $op) {
                if (is_array($op) && isset($op['insert']) && is_string($op['insert'])) {
                    $text .= ' '.$op['insert'];
                }
            }
        }

        $words = max(1, str_word_count($text));

        return max(1, (int) ceil($words / 200));
    }
}
