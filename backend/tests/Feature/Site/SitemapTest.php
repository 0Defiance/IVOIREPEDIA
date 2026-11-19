<?php

use App\Models\Article;
use App\Models\Category;
use App\Models\CensusDivision;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('liste les pages publiques, les articles publiés, les catégories et les lieux', function () {
    $site = rtrim((string) config('ivoirepedia.site_url'), '/');

    $category = Category::query()->create(['name' => 'Histoire', 'slug' => 'histoire', 'position' => 1]);
    $empty = Category::query()->create(['name' => 'Vide', 'slug' => 'vide', 'position' => 2]);

    Article::factory()->published()->create([
        'category_id' => $category->id,
        'slug' => 'publie',
        'title' => 'Publié',
    ]);

    Article::factory()->create([
        'category_id' => $empty->id,
        'slug' => 'brouillon',
        'title' => 'Brouillon',
    ]);

    CensusDivision::query()->create([
        'level' => CensusDivision::CITY,
        'name' => 'ABIDJAN',
        'slug' => 'abidjan',
        'population' => 6321017,
        'position' => 1,
    ]);

    $response = $this->get('/sitemap.xml')->assertOk();

    $response->assertHeader('content-type', 'application/xml; charset=UTF-8')
        ->assertSee('<?xml version="1.0" encoding="UTF-8"?>', false)
        ->assertSee('<loc>'.$site.'/articles/publie</loc>', false)
        ->assertSee('<loc>'.$site.'/categories/histoire</loc>', false)
        ->assertSee('<loc>'.$site.'/lieux/abidjan</loc>', false)
        ->assertSee('<loc>'.$site.'/a-propos</loc>', false)
        ->assertSee('<loc>'.$site.'/sources</loc>', false)
        ->assertDontSee('brouillon')
        ->assertDontSee('/categories/vide');

    $xml = simplexml_load_string((string) $response->getContent());

    expect($xml)->not->toBeFalse()
        ->and($xml->url)->not->toHaveCount(0);
});

it('n’expose ni article programmé ni page d’administration', function () {
    Article::factory()->create([
        'slug' => 'programme',
        'published_at' => now()->addDay(),
    ]);

    $response = $this->get('/sitemap.xml')->assertOk();

    $response->assertDontSee('programme')
        ->assertDontSee('/admin');
});
