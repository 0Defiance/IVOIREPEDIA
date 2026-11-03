<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Catégorie éditoriale — CONTEXT §8.2. Arborescence par `parent_id`,
 * ordonnée par `position` (`order` est un mot réservé MySQL).
 *
 * @property string $id
 * @property string $name
 * @property string $slug
 * @property string|null $description
 * @property int $position
 * @property string|null $parent_id
 * @property-read int|null $articles_count
 * @property-read Collection<int, Category> $children
 */
#[Fillable(['name', 'slug', 'description', 'position', 'parent_id'])]
class Category extends Model
{
    use HasUuids;

    /** @return HasMany<Article, $this> */
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }

    /** @return BelongsTo<Category, $this> */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(self::class, 'parent_id');
    }

    /** @return HasMany<Category, $this> */
    public function children(): HasMany
    {
        return $this->hasMany(self::class, 'parent_id')->orderBy('position');
    }
}
