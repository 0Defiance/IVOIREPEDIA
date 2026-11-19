<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Support\DeltaHtml;
use Illuminate\Contracts\View\View;
use Illuminate\Http\Response;
use Illuminate\Support\Str;

/**
 * Page publique d'un article, rendue côté serveur.
 *
 * Elle reçoit les adresses `/articles/{slug}` directement depuis Apache
 * (`.htaccess`) : le HTML contient le texte, les métadonnées Open Graph et la
 * canonique, ce que la coquille Flutter ne peut pas fournir aux moteurs de
 * recherche ni aux cartes de partage. La navigation interne à l'application
 * continue d'afficher la version Flutter, sans rechargement.
 */
class ArticlePageController extends Controller
{
    public function __invoke(string $slug): View|Response
    {
        $article = Article::query()
            ->published()
            ->where('slug', $slug)
            ->with(['category', 'author', 'tags', 'references'])
            ->first();

        $siteUrl = rtrim((string) config('ivoirepedia.site_url'), '/');

        if ($article === null) {
            return response()->view('site.missing', [
                'siteUrl' => $siteUrl,
            ], 404);
        }

        $summary = trim((string) preg_replace('/\s+/', ' ', strip_tags($article->summary)));

        return view('site.article', [
            'article' => $article,
            'content' => DeltaHtml::render($article->content),
            'sections' => DeltaHtml::sections($article->content),
            'siteUrl' => $siteUrl,
            'canonical' => $siteUrl.'/articles/'.$article->slug,
            'coverUrl' => $this->absolute($article->cover_image_url, $siteUrl),
            'description' => Str::limit($summary, 200),
        ]);
    }

    /** Rend une couverture relative absolue, sans toucher aux URL distantes. */
    private function absolute(?string $url, string $siteUrl): ?string
    {
        if ($url === null || trim($url) === '') {
            return null;
        }

        if (Str::startsWith($url, ['http://', 'https://'])) {
            return $url;
        }

        return $siteUrl.'/'.ltrim($url, '/');
    }
}
