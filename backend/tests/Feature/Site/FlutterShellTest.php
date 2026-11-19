<?php

use App\Support\FlutterShell;

/** @param  array<string, mixed>  $overrides */
function shellData(array $overrides = []): array
{
    return [
        'article' => null,
        'content' => '',
        'sections' => [],
        'siteUrl' => 'https://ivoirepedia.alwaysdata.net',
        'title' => 'Daloa',
        'canonical' => 'https://ivoirepedia.alwaysdata.net/articles/daloa',
        'coverUrl' => null,
        'description' => 'Une ville du centre-ouest ivoirien.',
        'publishedAt' => null,
        'modifiedAt' => null,
        'section' => null,
        'tags' => [],
        ...$overrides,
    ];
}

it('part du document Flutter déployé et y injecte les métadonnées de la page', function () {
    $document = <<<'HTML'
<!DOCTYPE html>
<html lang="fr">
<head>
  <base href="$FLUTTER_BASE_HREF">
  <title>Ivoirepedia</title>
  <meta name="description" content="L’encyclopédie libre de la Côte d’Ivoire.">
</head>
<body>
  <div id="loading">BUILD-DEPLOYE</div>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
HTML;

    $path = tempnam(sys_get_temp_dir(), 'flutter-shell-');
    file_put_contents($path, $document);

    try {
        $html = (new FlutterShell($path))->render(shellData());
    } finally {
        unlink($path);
    }

    expect($html)
        ->toContain('BUILD-DEPLOYE')
        ->toContain('flutter_bootstrap.js')
        ->toContain('<base href="/">')
        ->not->toContain('$FLUTTER_BASE_HREF')
        ->toContain('<title>Daloa — IVOIREPEDIA</title>')
        ->not->toContain('L’encyclopédie libre de la Côte d’Ivoire.')
        ->toContain('<meta name="description" content="Une ville du centre-ouest ivoirien.">')
        ->toContain('<link rel="canonical" href="https://ivoirepedia.alwaysdata.net/articles/daloa">')
        ->toContain('<meta property="og:title" content="Daloa">')
        ->toContain('Lire la version texte de cet article');

    // Le repli sans JavaScript passe juste avant la fermeture du corps.
    expect(strpos($html, '<noscript>'))->toBeLessThan(strpos($html, '</body>'));
});

it('rend une page sans Flutter quand aucun document n’est disponible', function () {
    $html = (new FlutterShell(__DIR__.'/absent/index.html'))->render(shellData());

    expect($html)
        ->toContain('<title>Daloa — IVOIREPEDIA</title>')
        ->toContain('Une ville du centre-ouest ivoirien.')
        ->toContain('<link rel="canonical" href="https://ivoirepedia.alwaysdata.net/articles/daloa">')
        ->toContain('<meta property="og:title" content="Daloa">')
        ->toContain('Lire la version texte de cet article')
        ->not->toContain('flutter_bootstrap.js');
});
