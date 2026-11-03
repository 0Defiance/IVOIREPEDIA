<?php

namespace App\Http\Resources;

use App\Models\Article;
use Illuminate\Http\Request;

/**
 * Article complet pour la page de lecture : contenu Delta Quill, infobox,
 * références numérotées et étiquettes.
 *
 * @mixin Article
 */
class ArticleResource extends ArticleSummaryResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            ...parent::toArray($request),
            'content' => $this->content,
            'infobox' => $this->infobox,
            'updated_at' => $this->updated_at?->toIso8601String(),
            'tags' => $this->whenLoaded('tags', fn () => $this->tags
                ->map(fn ($tag) => ['name' => $tag->name, 'slug' => $tag->slug])
                ->values()),
            'references' => $this->whenLoaded('references', fn () => $this->references
                ->map(fn ($reference) => [
                    'position' => $reference->position,
                    'kind' => $reference->kind,
                    'authors' => $reference->authors,
                    'title' => $reference->title,
                    'publisher' => $reference->publisher,
                    'year' => $reference->year,
                    'url' => $reference->url,
                    'accessed_at' => $reference->accessed_at?->toDateString(),
                    'note' => $reference->note,
                ])
                ->values()),
        ];
    }
}
