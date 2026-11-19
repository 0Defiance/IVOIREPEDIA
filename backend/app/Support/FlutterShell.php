<?php

namespace App\Support;

/**
 * Coquille Flutter d'une page article.
 *
 * Le document part du build Flutter réellement déployé (`public/index.html`) :
 * écran de lancement, icônes, manifeste et script de démarrage ne sont plus
 * recopiés dans un gabarit Blade, donc ils ne peuvent plus diverger de
 * l'application. Quand ce build n'est pas présent (développement local, tests),
 * on lit `app/web/index.html`, sa source versionnée ; à défaut, une page de
 * repli minimale est rendue, sans Flutter.
 *
 * Seul le contenu dynamique (titre, description, canonique, Open Graph) est
 * injecté dans ce document : le visiteur reçoit la même application, avec les
 * métadonnées de l'article dans le `<head>`.
 */
final class FlutterShell
{
    /** Document déployé par le build Flutter, puis sa source versionnée. */
    private const SOURCES = [
        'public/index.html',
        '../app/web/index.html',
    ];

    /** @var list<string> */
    private array $sources;

    /** @param  string|null  $source  Document imposé (tests) ; sinon les sources par défaut. */
    public function __construct(?string $source = null)
    {
        $this->sources = $source === null
            ? array_map(static fn (string $relative): string => base_path($relative), self::SOURCES)
            : [$source];
    }

    /**
     * Page complète à renvoyer : le document Flutter annoté, ou la page de
     * repli si aucun document n'est disponible.
     *
     * @param  array<string, mixed>  $data
     */
    public function render(array $data): string
    {
        $document = $this->document();

        if ($document === null) {
            return view('site.shell-fallback', $data)->render();
        }

        $head = trim(view('site.partials.shell-head', $data)->render());
        $noscript = trim(view('site.partials.shell-noscript', $data)->render());

        return $this->inject($document, $head, $noscript, $data);
    }

    /** Premier document lisible parmi les sources. */
    public function document(): ?string
    {
        foreach ($this->sources as $path) {
            if (! is_file($path) || ! is_readable($path)) {
                continue;
            }

            $contents = file_get_contents($path);

            if ($contents !== false && trim($contents) !== '') {
                return $contents;
            }
        }

        return null;
    }

    /**
     * Injecte les métadonnées de l'article dans le document Flutter.
     *
     * @param  array<string, mixed>  $data
     */
    private function inject(string $document, string $head, string $noscript, array $data): string
    {
        // Le gabarit source garde la variable de build (`$FLUTTER_BASE_HREF`) ;
        // le document déployé porte déjà « / ». Les deux rendent la même base.
        $document = str_replace('$FLUTTER_BASE_HREF', '/', $document);

        $title = '<title>'.e($data['title']).' — IVOIREPEDIA</title>';
        $description = '<meta name="description" content="'.e($data['description']).'">';

        $hasTitle = preg_match('/<title>.*?<\/title>/is', $document) === 1;
        $document = $this->replaceOnce($document, '/<title>.*?<\/title>/is', $title);

        $hasDescription = preg_match('/<meta\s+name="description"[^>]*>/i', $document) === 1;
        $document = $this->replaceOnce(
            $document,
            '/<meta\s+name="description"[^>]*>/i',
            $description,
        );

        // Un document qui n'aurait ni titre ni description les reçoit quand même.
        $head = implode("\n", array_filter([
            $hasTitle ? null : $title,
            $hasDescription ? null : $description,
            $head,
        ]));

        $document = $this->beforeClosingTag($document, 'head', $head);

        return $this->beforeClosingTag($document, 'body', $noscript);
    }

    /** Remplace la première occurrence du motif, ou laisse le document intact. */
    private function replaceOnce(string $document, string $pattern, string $replacement): string
    {
        $replacements = 0;

        $result = preg_replace_callback(
            $pattern,
            static fn (): string => $replacement,
            $document,
            1,
            $replacements,
        );

        return $result !== null && $replacements > 0 ? $result : $document;
    }

    /** Pose un bloc juste avant la balise fermante, ou à la fin du document. */
    private function beforeClosingTag(string $document, string $tag, string $markup): string
    {
        if ($markup === '') {
            return $document;
        }

        $position = stripos($document, '</'.$tag.'>');

        if ($position === false) {
            return $document."\n".$markup."\n";
        }

        return substr($document, 0, $position).$markup."\n".substr($document, $position);
    }
}
