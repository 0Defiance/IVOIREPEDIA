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

    expect(HistoryStory::query()->count())->toBeGreaterThanOrEqual(11)
        ->and($bassam)->not->toBeNull()
        ->and($bassam->source_url)->toBe('https://whc.unesco.org/fr/list/1322')
        ->and($bassam->paragraphs)->toHaveCount(3)
        ->and($bassam->source_year)->toBe(2012);
});

it('importe les récits anciens avec une source vérifiable', function (string $slug, string $url) {
    $this->artisan('history:sync-stories')->assertSuccessful();

    $story = HistoryStory::query()->where('slug', $slug)->first();

    expect($story)->not->toBeNull()
        ->and($story->source_url)->toBe($url)
        ->and($story->paragraphs)->toHaveCount(3)
        ->and($story->figures)->toHaveCount(2);
})->with([
    ['indenie-abengourou', 'https://www.ajol.info/index.php/akiri/article/view/328069'],
    ['baoule-traversee-du-comoe', 'https://www.revueakofena.com/hs-19_27/'],
    ['sanwi-balahinma-manlan-ahua', 'https://www.academieoutremer.fr/images/files/Sanvi-Royaume-Akan-(59_300).pdf'],
    ['samory-guelemou-1898', 'https://journals.openedition.org/rha/7701'],
]);

it('ne publie aucun récit sans URL de source', function () {
    $this->artisan('history:sync-stories')->assertSuccessful();

    HistoryStory::query()->each(function (HistoryStory $story) {
        expect($story->source_url)->toStartWith('https://')
            ->and($story->source_title)->not->toBeEmpty()
            ->and($story->source_year)->toBeGreaterThan(1900);
    });
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
        ->and($response->json('data.0.slug'))->toBe('indenie-abengourou')
        ->and($response->json('data.0.source.url'))->toBe('https://www.ajol.info/index.php/akiri/article/view/328069')
        ->and($response->json('data.0.figures.0.value'))->toBe('1701')
        ->and($response->json('data.3.slug'))->toBe('grand-bassam-capitale-abandonnee')
        ->and($response->json('meta.count'))->toBe(HistoryStory::query()->count());
});
