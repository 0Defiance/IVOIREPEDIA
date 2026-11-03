<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\ArticleIndexRequest;
use App\Http\Resources\ArticleSummaryResource;
use App\Models\Article;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;

/**
 * `GET /api/v1/search?q=&page=` — RCH-01.
 * Recherche volontairement simple au MVP (LIKE sur titre et résumé) : le
 * full-text MySQL est prévu en V1 (CONTEXT §14).
 */
class SearchController extends Controller
{
    public function __invoke(ArticleIndexRequest $request): JsonResponse
    {
        $term = trim((string) $request->validated('q'));

        if ($term === '') {
            return response()->json([
                'data' => [],
                'meta' => ['page' => 1, 'limit' => 0, 'total' => 0, 'query' => ''],
            ]);
        }

        $query = Article::query()
            ->published()
            ->matching($term);

        if ($category = $request->validated('category')) {
            $query->inCategory($category);
        }

        $limit = $request->limit();
        $page = $request->page();
        $total = (clone $query)->count();

        /** @var Builder<Article> $query */
        $articles = $query
            ->with(['category', 'author'])
            ->orderByDesc('published_at')
            ->forPage($page, $limit)
            ->get();

        return response()->json([
            'data' => ArticleSummaryResource::collection($articles)->resolve(),
            'meta' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'query' => $term,
            ],
        ]);
    }
}
