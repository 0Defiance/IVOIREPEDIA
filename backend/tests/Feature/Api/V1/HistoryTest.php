<?php

use App\Models\HistoryStory;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Section « Histoire incroyable » : les récits sont importés depuis le fichier
 * versionné, chacun avec sa source, et l'API les expose dans l'ordre.
 */
uses(RefreshDatabase::class);

it('importe les récits avec leur source', function () {
    $this->artisan('history:sync-stories')->assertSuccessful();

    $bassam = HistoryStory::query()->where('slug', 'grand-bassam-capitale-abandonnee')->first();

    expect(HistoryStory::query()->count())->toBeGreaterThanOrEqual(6)
        ->and($bassam)->not->toBeNull()
        ->and($bassam->source_url)->toBe('https://whc.unesco.org/fr/list/1322')
        ->and($bassam->paragraphs)->toHaveCount(3)
        ->and($bassam->source_year)->toBe(2012);
});

it('importe deux fois sans dupliquer', function () {
    $this->artisan('history:sync-stories')->assertSuccessful();
    $before = HistoryStory::query()->count();

    $this->artisan('history:sync-stories')->assertSuccessful();

    expect(HistoryStory::query()->count())->toBe($before);
});

it('expose les récits dans l’ordre, avec leurs repères chiffrés', function () {
    $this->artisan('history:sync-stories')->assertSuccessful();

    $response = $this->getJson('/api/v1/history')->assertOk();

    expect($response->json('data'))->toHaveCount(HistoryStory::query()->count())
        ->and($response->json('data.0.slug'))->toBe('grand-bassam-capitale-abandonnee')
        ->and($response->json('data.0.source.url'))->toBe('https://whc.unesco.org/fr/list/1322')
        ->and($response->json('data.0.figures.0.value'))->toBe('2012')
        ->and($response->json('meta.count'))->toBe(HistoryStory::query()->count());
});
