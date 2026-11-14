<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ArticleReference;
use Illuminate\Http\JsonResponse;

/**
 * Bibliothèque des sources publiques — page « Charte et sources ».
 *
 * Toutes les références des articles publiés sont regroupées par éditeur
 * (ANStat, UNESCO, Conseil du café-cacao…), dédoublonnées puis rattachées aux
 * articles qui les citent. Un lecteur peut ainsi voir d'où viennent les
 * chiffres du site, institution par institution.
 */
class SourcesController extends Controller
{
    /** `GET /api/v1/sources` */
    public function __invoke(): JsonResponse
    {
        $references = ArticleReference::query()
            ->whereHas('article', fn ($query) => $query->published())
            ->with(['article:id,slug,title'])
            ->get();

        // Une même source citée par dix articles reste une seule référence :
        // on regroupe par éditeur, titre et adresse.
        $grouped = [];

        foreach ($references as $reference) {
            $publisher = $reference->publisher !== null && $reference->publisher !== ''
                ? $reference->publisher
                : 'Source non identifiée';
            $key = $publisher.'|'.$reference->title.'|'.($reference->url ?? '');

            if (! isset($grouped[$key])) {
                $grouped[$key] = [
                    'publisher' => $publisher,
                    'title' => $reference->title,
                    'year' => $reference->year,
                    'url' => $reference->url,
                    'articles' => [],
                ];
            }

            if ($reference->article !== null) {
                $grouped[$key]['articles'][$reference->article->slug] = $reference->article->title;
            }
        }

        $institutions = [];

        foreach ($grouped as $entry) {
            $name = $entry['publisher'];
            unset($entry['publisher']);

            $institutions[$name][] = [
                'title' => $entry['title'],
                'year' => $entry['year'],
                'url' => $entry['url'],
                'articles' => collect($entry['articles'])
                    ->map(fn (string $title, string $slug): array => ['slug' => $slug, 'title' => $title])
                    ->values()
                    ->all(),
            ];
        }

        $payload = [];

        foreach ($institutions as $name => $entries) {
            usort($entries, fn (array $a, array $b): int => strcmp($a['title'], $b['title']));

            $payload[] = [
                'name' => $name,
                'count' => count($entries),
                'references' => $entries,
            ];
        }

        // Les institutions officielles passent avant les encyclopédies : une
        // source primaire vaut mieux qu'une notice, même citée moins souvent.
        $weight = fn (string $name): int => str_starts_with($name, 'Wikipédia') ? 1 : 0;

        usort($payload, fn (array $a, array $b): int => $weight($a['name']) <=> $weight($b['name'])
            ?: $b['count'] <=> $a['count']
            ?: strcmp($a['name'], $b['name']));

        $articles = $references->pluck('article.slug')->filter()->unique();

        return response()->json([
            'data' => $payload,
            'meta' => [
                'institutions' => count($payload),
                'references' => count($grouped),
                'mentions' => $references->count(),
                'articles' => $articles->count(),
            ],
        ])->header('Cache-Control', 'public, max-age=1800');
    }
}
