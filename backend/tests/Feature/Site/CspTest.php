<?php

use App\Models\Article;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * CSP **bloquante** (docs/SECURITE.md §1).
 *
 * L'en-tête est posé par Apache depuis `public/.htaccess` : les tests HTTP de
 * Laravel ne le voient pas. Ces tests lisent donc le fichier tel qu'il part en
 * production et vérifient le HTML réellement rendu — la seule question qui
 * compte étant « reste-t-il un script en ligne que la politique refuserait ? ».
 */
uses(RefreshDatabase::class);

function cspPolicyFromHtaccess(): ?string
{
    $htaccess = @file_get_contents(dirname(__DIR__, 3).'/public/.htaccess');

    if ($htaccess === false) {
        return null;
    }

    if (preg_match('/Header always set Content-Security-Policy "([^"]+)"/', $htaccess, $match) !== 1) {
        return null;
    }

    return $match[1];
}

/** Directive d'une politique CSP, lue sans dépendre de l'ordre des règles. */
function cspDirective(string $policy, string $name): ?string
{
    foreach (explode(';', $policy) as $rule) {
        $rule = trim($rule);

        if (str_starts_with($rule, $name.' ')) {
            return substr($rule, strlen($name) + 1);
        }
    }

    return null;
}

it('sert la CSP en mode bloquant, jamais en Report-Only', function () {
    $htaccess = (string) file_get_contents(dirname(__DIR__, 3).'/public/.htaccess');

    expect($htaccess)->toContain('Header always set Content-Security-Policy "')
        ->and($htaccess)->not->toContain('Content-Security-Policy-Report-Only');
});

it('garde script-src sans unsafe-inline et ouvre juste les images sourcées', function () {
    $policy = cspPolicyFromHtaccess();

    expect($policy)->not->toBeNull();

    $script = (string) cspDirective((string) $policy, 'script-src');
    $style = (string) cspDirective((string) $policy, 'style-src');
    $image = (string) cspDirective((string) $policy, 'img-src');

    // Aucun script en ligne toléré ; 'unsafe-eval' non plus (Flutter n'a besoin
    // que de compiler du WebAssembly).
    expect($script)->toContain("'self'")
        ->and($script)->not->toContain("'unsafe-inline'")
        ->and($script)->not->toContain("'unsafe-eval'")
        ->and($script)->toContain("'wasm-unsafe-eval'");

    // Le moteur injecte ses feuilles à la volée : style-src doit rester souple.
    expect($style)->toContain("'unsafe-inline'");

    // Les couvertures d'articles sont hébergées par Wikimedia (75 en production
    // le 28 novembre 2026) : sans ces deux hôtes, elles disparaîtraient.
    expect($image)->toContain('https://upload.wikimedia.org')
        ->and($image)->toContain('https://thumb.wikimedia.org');
});

it('rend le formulaire d’article sans aucun script en ligne', function () {
    $admin = User::factory()->admin()->create();

    $html = (string) $this->actingAs($admin)
        ->get('/admin/articles/nouveau')
        ->assertOk()
        ->assertSee('Ajouter une source')
        ->getContent();

    // Le script vit dans un fichier de la même origine, donc `script-src 'self'`
    // suffit : c'est ce que la CSP bloquante exige.
    expect($html)->toContain('admin/article-form.js')
        ->and(file_exists(dirname(__DIR__, 3).'/public/admin/article-form.js'))->toBeTrue();

    preg_match_all('/<script\b[^>]*>/i', $html, $matches);

    foreach ($matches[0] as $tag) {
        expect($tag)->toMatch('/\bsrc=/i');
    }
});

it('ne laisse dans une page d’article que le bloc de données JSON-LD', function () {
    Article::factory()->published()->create(['title' => 'Daloa', 'slug' => 'daloa']);

    $html = (string) $this->get('/articles/daloa?html=1')
        ->assertOk()
        ->getContent();

    preg_match_all('/<script\b[^>]*>/i', $html, $matches);

    expect($matches[0])->not->toBeEmpty();

    foreach ($matches[0] as $tag) {
        // JSON-LD n'est pas exécuté : la CSP ne s'y applique pas.
        expect($tag)->toMatch('/type="application\/ld\+json"/i');
    }
});
