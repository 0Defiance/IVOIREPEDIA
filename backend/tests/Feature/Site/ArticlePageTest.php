<?php

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Models\Article;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

/** @param  array<string, mixed>  $overrides */
function siteArticle(array $overrides = []): Article
{
    return Article::factory()->published()->create([
        'type' => ArticleType::TOPIC,
        ...$overrides,
    ]);
}

it('sert le contenu de l’article en HTML, avec titre de section ancré', function () {
    $article = siteArticle([
        'title' => 'Abidjan',
        'slug' => 'abidjan',
        'summary' => 'La capitale économique de la Côte d’Ivoire.',
        'content' => ['ops' => [
            ['insert' => "Abidjan est la capitale économique du pays.[1]\n"],
            ['insert' => "Histoire\n", 'attributes' => ['header' => 2]],
            ['insert' => "Le pont Henri Konan Bédié relie les deux rives.\n"],
        ]],
    ]);

    $article->references()->create([
        'position' => 1,
        'kind' => 'OTHER',
        'title' => 'RGPH 2021',
        'year' => 2022,
    ]);

    $response = $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/abidjan')
        ->assertOk();

    $response->assertHeader('content-type', 'text/html; charset=UTF-8')
        ->assertSee('Abidjan')
        ->assertSee('La capitale économique de la Côte d’Ivoire.')
        ->assertSee('<h2 id="histoire">Histoire</h2>', false)
        ->assertSee('Le pont Henri Konan Bédié relie les deux rives.')
        ->assertSee('href="#reference-1"', false)
        ->assertSee('id="reference-1"', false)
        ->assertSee('RGPH 2021');
});

it('expose les cartes de partage Open Graph et la canonique', function () {
    $site = rtrim((string) config('ivoirepedia.site_url'), '/');

    siteArticle([
        'title' => 'Le cacao en Côte d’Ivoire',
        'slug' => 'cacao',
        'summary' => 'Une filière qui structure l’économie du pays.',
        'cover_image_url' => 'https://upload.wikimedia.org/wikipedia/commons/cacao.jpg',
        'cover_image_alt' => 'Cabosses de cacao',
        'cover_image_credit' => 'Wikimedia Commons',
        'cover_image_license' => 'CC BY-SA 4.0',
    ]);

    $response = $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/cacao')
        ->assertOk();

    $response->assertSee('<link rel="canonical" href="'.$site.'/articles/cacao">', false)
        ->assertSee('<meta property="og:type" content="article">', false)
        ->assertSee('<meta property="og:title" content="Le cacao en Côte d’Ivoire">', false)
        ->assertSee('<meta property="og:url" content="'.$site.'/articles/cacao">', false)
        ->assertSee('<meta property="og:image" content="https://upload.wikimedia.org/wikipedia/commons/cacao.jpg">', false)
        ->assertSee('<meta property="og:image:alt" content="Cabosses de cacao">', false)
        ->assertSee('<meta name="twitter:card" content="summary_large_image">', false)
        ->assertSee('<meta property="article:section"', false)
        ->assertSee('Wikimedia Commons');
});

it('échappe le HTML présent dans le contenu éditorial', function () {
    siteArticle([
        'slug' => 'injection',
        'content' => ['ops' => [
            ['insert' => "Un <script>alert(1)</script> et du <b>gras</b>.\n"],
        ]],
    ]);

    $response = $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/injection')
        ->assertOk();

    $response->assertDontSee('<script>alert(1)</script>', false)
        ->assertSee('&lt;script&gt;alert(1)&lt;/script&gt;', false)
        ->assertSee('&lt;b&gt;gras&lt;/b&gt;', false);
});

it('groupe les listes et rend les citations', function () {
    siteArticle([
        'slug' => 'listes',
        'content' => ['ops' => [
            ['insert' => "Une introduction.\n"],
            ['insert' => "Premier point\n", 'attributes' => ['list' => 'bullet']],
            ['insert' => "Deuxième point\n", 'attributes' => ['list' => 'bullet']],
            ['insert' => "Une citation.\n", 'attributes' => ['blockquote' => true]],
        ]],
    ]);

    $response = $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/listes')
        ->assertOk();

    $response->assertSee('<ul>', false)
        ->assertSee('<li>Premier point</li>', false)
        ->assertSee('<li>Deuxième point</li>', false)
        ->assertSee('<blockquote><p>Une citation.</p></blockquote>', false);
});

it('renvoie 404 pour un article non publié ou inconnu', function () {
    siteArticle(['slug' => 'brouillon', 'status' => ArticleStatus::DRAFT]);
    siteArticle(['slug' => 'programme', 'published_at' => now()->addDay()]);

    $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/brouillon')
        ->assertNotFound()
        ->assertSee('Cet article n’existe pas ou n’est pas encore publié.');

    $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/programme')
        ->assertNotFound();
    $this->withHeader('User-Agent', 'Googlebot/2.1 (+http://www.google.com/bot.html)')
        ->get('/articles/inconnu')
        ->assertNotFound();
});

it('sert l’application Flutter aux visiteurs avec les métadonnées de l’article', function () {
    siteArticle([
        'title' => 'Daloa',
        'slug' => 'daloa',
        'summary' => 'Une ville du centre-ouest ivoirien.',
    ]);

    $response = $this->withHeader(
        'User-Agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    )->get('/articles/daloa')->assertOk();

    $response->assertSee('<base href="/">', false)
        ->assertSee('flutter_bootstrap.js', false)
        ->assertSee('<title>Daloa — IVOIREPEDIA</title>', false)
        ->assertSee('<meta property="og:title" content="Daloa">', false)
        ->assertDontSee('<article class="article">', false);
});

it('garde la version HTML accessible aux visiteurs avec ?html=1', function () {
    siteArticle([
        'title' => 'Daloa',
        'slug' => 'daloa',
        'summary' => 'Une ville du centre-ouest ivoirien.',
    ]);

    $this->withHeader(
        'User-Agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    )->get('/articles/daloa?html=1')
        ->assertOk()
        ->assertSee('<article class="article">', false)
        ->assertSee('Une ville du centre-ouest ivoirien.');
});

it('renvoie la coquille Flutter sur un article inconnu pour un visiteur', function () {
    $this->withHeader(
        'User-Agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    )->get('/articles/inconnu')
        ->assertNotFound()
        ->assertSee('flutter_bootstrap.js', false);
});
