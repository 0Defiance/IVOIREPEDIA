<?php

namespace App\Http\Resources;

use App\Models\Article;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Article tel qu'affiché dans une liste ou une carte : pas de contenu, pour
 * garder les réponses légères (ENF-PERF-05).
 *
 * @mixin Article
 */
class ArticleSummaryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'title' => $this->title,
            'summary' => $this->summary,
            'type' => $this->type->value,
            'type_label' => $this->type->label(),
            'cover_image_url' => $this->cover_image_url,
            'cover_image_alt' => $this->cover_image_alt,
            'published_at' => $this->published_at?->toIso8601String(),
            'reading_minutes' => $this->readingMinutes(),
            'category' => $this->whenLoaded('category', fn () => [
                'name' => $this->category->name,
                'slug' => $this->category->slug,
            ]),
            'author' => $this->whenLoaded('author', fn () => [
                'name' => $this->author->name,
            ]),
        ];
    }
}
