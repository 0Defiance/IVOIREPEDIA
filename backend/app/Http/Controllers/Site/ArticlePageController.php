<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\ArticleSlugRedirect;
use App\Support\DeltaHtml;
use App\Support\FlutterShell;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;

/**
 * Page publique d'un article.
 *
 * La même adresse `/articles/{slug}` a deux rendus, pour rester cohérente
 * avec le reste du site :
 *
 * - un visiteur reçoit la coquille Flutter, avec le titre, la description,
 *   l'Open Graph et la canonique de l'article dans le `<head>` ; Flutter
 *   reprend ensuite la main et affiche la page de lecture habituelle. Cette
 *   coquille part du `public/index.html` déployé (voir `FlutterShell`) ;
 * - un robot (moteur de recherche, aperçu de partage) ou un client qui
 *   demande `?html=1` reçoit le HTML complet rendu par Laravel, sans
 *   JavaScript.
 *
 * Les deux versions portent le même contenu : le pré-rendu ne sert pas un
 * texte différent aux moteurs, il sert le même article dans un autre rendu.
 */
class ArticlePageController extends Controller
{
    /** Robots, aperçus de partage et clients qui n'exécutent pas JavaScript. */
    private const RENDERED_HTML_PATTERN = '/bot|crawl|spider|slurp|preview|facebookexternalhit|whatsapp|telegram|discord|linkedin|pinterest|embedly|quora/i';

    public function __invoke(Request $request, string $slug): View|Response|RedirectResponse
    {
        $article = Article::query()
            ->published()
            ->where('slug', $slug)
            ->with(['category', 'author', 'tags', 'references'])
            ->first();

        $siteUrl = rtrim((string) config('ivoirepedia.site_url'), '/');

        if ($article === null) {
            $target = $this->redirectTarget($slug);

            if ($target !== null) {
                return redirect()->to($siteUrl.'/articles/'.$target, 301);
            }

            return $this->missing($request, $slug, $siteUrl);
        }

        $summary = trim((string) preg_replace('/\s+/', ' ', strip_tags($article->summary)));

        $data = [
            'article' => $article,
            'content' => DeltaHtml::render($article->content),
            'sections' => DeltaHtml::sections($article->content),
            'siteUrl' => $siteUrl,
            'title' => $article->title,
            'canonical' => $siteUrl.'/articles/'.$article->slug,
            'coverUrl' => $this->absolute($article->cover_image_url, $siteUrl),
            'description' => Str::limit($summary, 200),
            'publishedAt' => $article->published_at,
            'modifiedAt' => $article->updated_at,
            'section' => $article->category->name,
            'tags' => $article->tags->pluck('name')->all(),
        ];

        if ($this->wantsRenderedHtml($request)) {
            return view('site.article', $data);
        }

        return response((new FlutterShell)->render($data));
    }

    /**
     * Ancien slug renommé : redirection permanente vers l'adresse actuelle.
     *
     * La cible doit être publiée : une redirection ne doit jamais envoyer vers
     * un article retiré du site.
     */
    private function redirectTarget(string $slug): ?string
    {
        $target = ArticleSlugRedirect::query()
            ->where('old_slug', $slug)
            ->value('new_slug');

        if ($target === null) {
            return null;
        }

        $published = Article::query()->published()->where('slug', $target)->exists();

        return $published ? $target : null;
    }

    /** Article inconnu : page 404 dans le rendu attendu par le client. */
    private function missing(Request $request, string $slug, string $siteUrl): Response
    {
        if ($this->wantsRenderedHtml($request)) {
            return response()->view('site.missing', ['siteUrl' => $siteUrl], 404);
        }

        return response((new FlutterShell)->render([
            'article' => null,
            'content' => '',
            'sections' => [],
            'siteUrl' => $siteUrl,
            'title' => 'Article introuvable',
            'canonical' => $siteUrl.'/articles/'.$slug,
            'coverUrl' => null,
            'description' => "Cet article n'existe pas ou n'est pas publié.",
            'publishedAt' => null,
            'modifiedAt' => null,
            'section' => null,
            'tags' => [],
        ]), 404);
    }

    /**
     * `?html=1` force la version pré-rendue ; les robots la reçoivent d'office.
     * Un navigateur ordinaire n'a ni l'un ni l'autre.
     */
    private function wantsRenderedHtml(Request $request): bool
    {
        if ($request->boolean('html')) {
            return true;
        }

        $agent = (string) $request->userAgent();

        return $agent !== '' && preg_match(self::RENDERED_HTML_PATTERN, $agent) === 1;
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
