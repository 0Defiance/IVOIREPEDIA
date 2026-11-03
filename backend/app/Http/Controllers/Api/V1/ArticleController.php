<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\ArticleIndexRequest;
use App\Http\Resources\ArticleResource;
use App\Http\Resources\ArticleSummaryResource;
use App\Models\Article;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * Lecture publique des articles — CONTEXT §11.1.
 * Aucune route d'écriture ici : la création/modification arrive au Sprint 2
 * et reste réservée aux rôles éditoriaux.
 */
class ArticleController extends Controller
{
    /** `GET /api/v1/articles?category=&tag=&q=&page=&limit=` */
    public function index(ArticleIndexRequest $request): JsonResponse
    {
        $query = $this->baseQuery($request);
        $limit = $request->limit();
        $page = $request->page();
        $total = (clone $query)->count();

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
            ],
        ]);
    }

    /** `GET /api/v1/articles/{slug}` — 404 si l'article n'est pas publié. */
    public function show(string $slug): ArticleResource|JsonResponse
    {
        $article = Article::query()
            ->published()
            ->where('slug', $slug)
            ->with(['category', 'author', 'tags', 'references'])
            ->first();

        if ($article === null) {
            return response()->json([
                'error' => [
                    'code' => 'NOT_FOUND',
                    'message' => "Cet article n'existe pas ou n'est pas publié.",
                ],
            ], 404);
        }

        return new ArticleResource($article);
    }

    /**
     * Filtres communs à la liste et à la recherche.
     *
     * @return Builder<Article>
     */
    protected function baseQuery(ArticleIndexRequest $request): Builder
    {
        $query = Article::query()->published();

        if ($category = $request->validated('category')) {
            $query->inCategory($category);
        }

        if ($tag = $request->validated('tag')) {
            $query->taggedWith($tag);
        }

        if ($term = $request->validated('q')) {
            $query->matching($term);
        }

        return $query;
    }

    /**
     * @return AnonymousResourceCollection<int, ArticleSummaryResource>
     */
    protected function collection(mixed $articles): AnonymousResourceCollection
    {
        return ArticleSummaryResource::collection($articles);
    }
}
