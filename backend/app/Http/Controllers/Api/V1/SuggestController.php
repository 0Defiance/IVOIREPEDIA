<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Article;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * `GET /api/v1/search/suggest?q=` — suggestions de la recherche instantanée.
 *
 * Réponse volontairement courte (six entrées, quatre champs) : elle est
 * appelée à chaque frappe depuis la barre de recherche, donc elle doit rester
 * moins chère que la recherche complète, qui pagine et renvoie les chapeaux.
 */
class SuggestController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $term = trim((string) $request->query('q', ''));

        if (mb_strlen($term) < 2) {
            return response()->json(['data' => [], 'meta' => ['query' => $term]]);
        }

        $articles = Article::query()
            ->published()
            ->matching($term)
            ->with('category')
            ->orderByDesc('published_at')
            ->limit(6)
            ->get();

        return response()->json([
            'data' => $articles
                ->map(fn (Article $article): array => [
                    'slug' => $article->slug,
                    'title' => $article->title,
                    'category' => $article->category->name,
                ])
                ->values()
                ->all(),
            'meta' => ['query' => $term],
        ])->header('Cache-Control', 'public, max-age=60');
    }
}
