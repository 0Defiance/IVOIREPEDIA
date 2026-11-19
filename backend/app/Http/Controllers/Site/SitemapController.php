<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\Category;
use App\Models\CensusDivision;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Response;

/**
 * `GET /sitemap.xml` — plan du site pour les moteurs de recherche.
 *
 * Seul le contenu réellement public y figure : articles publiés et datés,
 * catégories qui contiennent au moins un article publié, et fiches de lieux
 * issues du recensement. Aucun brouillon, aucune page d'administration.
 */
class SitemapController extends Controller
{
    /** Pages de l'application servies à tous, sans contenu variable. */
    private const STATIC_PATHS = [
        '/',
        '/statistiques',
        '/histoires',
        '/chronologie',
        '/sources',
        '/lieux',
        '/a-propos',
        '/charte',
        '/contact',
        '/confidentialite',
    ];

    public function __invoke(): Response
    {
        $siteUrl = rtrim((string) config('ivoirepedia.site_url'), '/');

        /** @var list<array{loc: string, lastmod: string|null}> $urls */
        $urls = [];

        foreach (self::STATIC_PATHS as $path) {
            $urls[] = ['loc' => $siteUrl.$path, 'lastmod' => null];
        }

        $categories = Category::query()
            ->whereHas('articles', fn (Builder $query) => $query->published())
            ->orderBy('position')
            ->get();

        foreach ($categories as $category) {
            $urls[] = ['loc' => $siteUrl.'/categories/'.$category->slug, 'lastmod' => null];
        }

        $articles = Article::query()
            ->published()
            ->orderByDesc('published_at')
            ->get();

        foreach ($articles as $article) {
            $urls[] = [
                'loc' => $siteUrl.'/articles/'.$article->slug,
                'lastmod' => $article->published_at?->toAtomString(),
            ];
        }

        $places = CensusDivision::query()->orderBy('slug')->get();
        $seenPlaces = [];

        foreach ($places as $place) {
            if (isset($seenPlaces[$place->slug])) {
                continue; // Abidjan est à la fois district et ville : une seule URL
            }

            $seenPlaces[$place->slug] = true;
            $urls[] = ['loc' => $siteUrl.'/lieux/'.$place->slug, 'lastmod' => null];
        }

        $xml = '<?xml version="1.0" encoding="UTF-8"?>'."\n"
            .view('site.sitemap', ['urls' => $urls])->render();

        return response($xml, 200, ['Content-Type' => 'application/xml; charset=UTF-8']);
    }
}
