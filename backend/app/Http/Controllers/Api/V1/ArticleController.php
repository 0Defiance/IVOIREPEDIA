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
use Illuminate\Support\Facades\Cache;

/**
 * Lecture publique des articles — CONTEXT §11.1.
 * Aucune route d'écriture ici : la création/modification arrive au Sprint 2
 * et reste réservée aux rôles éditoriaux.
 */
class ArticleController extends Controller
{
    /**
     * Fraîcheur de la liste publique. Courte à dessein : chaque écriture
     * d'article change la version du cache et périme donc l'entrée.
     */
    private const INDEX_TTL_MINUTES = 2;

    /** `GET /api/v1/articles?category=&tag=&q=&page=&limit=` */
    public function index(ArticleIndexRequest $request): JsonResponse
    {
        // L'accueil demande la même liste à chaque visite : la servir depuis
        // le cache évite le comptage et la jointure des catégories/auteurs à
        // chaque chargement de page.
        $key = 'articles.index.'.Article::cacheGeneration().'.'.md5($request->fullUrl());

        $payload = Cache::remember(
            $key,
            now()->addMinutes(self::INDEX_TTL_MINUTES),
            function () use ($request): array {
                $query = $this->baseQuery($request);
                $limit = $request->limit();
                $page = $request->page();
                $total = (clone $query)->count();

                $articles = $query
                    ->with(['category', 'author'])
                    ->orderByDesc('published_at')
                    ->forPage($page, $limit)
                    ->get();

                return [
                    'data' => ArticleSummaryResource::collection($articles)->resolve(),
                    'meta' => [
                        'page' => $page,
                        'limit' => $limit,
                        'total' => $total,
                    ],
                ];
            },
        );

        return response()->json($payload);
    }

    /**
     * `GET /api/v1/articles/random` — un article publié tiré au hasard.
     *
     * Le tirage se fait en base, sur l'ensemble des articles publiés : le
     * bouton « article au hasard » de l'accueil n'est donc pas limité à la
     * première page de la liste.
     */
    public function random(): JsonResponse
    {
        $article = Article::query()
            ->published()
            ->with(['category', 'author'])
            ->inRandomOrder()
            ->first();

        if ($article === null) {
            return response()->json([
                'error' => [
                    'code' => 'NOT_FOUND',
                    'message' => 'Aucun article publié pour le moment.',
                ],
            ], 404);
        }

        return response()->json([
            'data' => ArticleSummaryResource::make($article)->resolve(),
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

        if ($slugs = $request->slugs()) {
            $query->whereIn('slug', $slugs);
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
