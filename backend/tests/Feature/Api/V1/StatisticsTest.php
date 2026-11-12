<?php

use App\Models\CensusDivision;
use App\Models\CountryIndicator;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Statistiques publiques — page « La Côte d'Ivoire en chiffres ».
 *
 * Deux choses à prouver : l'API expose des chiffres datés et sourcés, et
 * l'import du recensement fonctionne sans réseau (donc en intégration continue).
 */
uses(RefreshDatabase::class);

it('expose les indicateurs par thème, avec source, année et série', function () {
    $population = CountryIndicator::query()->create([
        'code' => 'SP.POP.TOTL',
        'label' => 'Population totale',
        'theme' => 'demographie',
        'unit' => 'habitants',
        'decimals' => 0,
        'value' => 31934230,
        'year' => 2024,
        'source_name' => 'Banque mondiale — WDI',
        'source_url' => 'https://data.worldbank.org/country/ci',
        'source_licence' => 'CC BY 4.0',
        'position' => 0,
    ]);

    $population->points()->createMany([
        ['year' => 2023, 'value' => 31165654],
        ['year' => 2024, 'value' => 31934230],
    ]);

    CountryIndicator::query()->create([
        'code' => 'NY.GDP.MKTP.CD',
        'label' => 'Produit intérieur brut',
        'theme' => 'economie',
        'unit' => 'USD courants',
        'value' => 78800000000,
        'year' => 2023,
        'source_name' => 'Banque mondiale — WDI',
        'position' => 0,
    ]);

    CensusDivision::query()->create([
        'level' => CensusDivision::DISTRICT,
        'name' => 'Abidjan',
        'slug' => 'abidjan',
        'population' => 6321017,
        'households' => 1414136,
        'average_size' => 4.5,
        'position' => 0,
    ]);

    $response = $this->getJson('/api/v1/statistics')->assertOk();

    $demographie = collect($response->json('data.themes'))->firstWhere('code', 'demographie');

    expect($demographie)->not->toBeNull()
        ->and($demographie['indicators'][0]['code'])->toBe('SP.POP.TOTL')
        ->and($demographie['indicators'][0]['display'])->toBe('31 934 230 habitants')
        ->and($demographie['indicators'][0]['year'])->toBe(2024)
        ->and($demographie['indicators'][0]['source']['licence'])->toBe('CC BY 4.0')
        ->and($demographie['indicators'][0]['series'])->toHaveCount(2)
        ->and($response->json('data.divisions.districts.0.name'))->toBe('Abidjan')
        ->and($response->json('data.divisions.districts.0.population'))->toBe(6321017)
        ->and($response->json('meta.sources'))->toContain('Banque mondiale — WDI');
});

it('importe le recensement et ses divisions sans réseau', function () {
    $this->artisan('country:sync-statistics', ['--offline' => true])->assertSuccessful();

    $national = CountryIndicator::query()->where('code', 'RGPH.POP.TOTL')->first();
    $abidjan = CensusDivision::query()->where('level', 'district')->where('slug', 'abidjan')->first();
    $bouake = CensusDivision::query()->where('level', 'city')->where('slug', 'bouake')->first();

    expect($national)->not->toBeNull()
        ->and((int) $national->value)->toBe(29389150)
        ->and($national->year)->toBe(2021)
        ->and($national->source_licence)->toContain('Licence Ouverte')
        ->and($abidjan->population)->toBe(6321017)
        ->and($bouake->population)->toBe(832371)
        ->and(CensusDivision::query()->ofLevel('region')->count())->toBe(31)
        ->and(CensusDivision::query()->ofLevel('district')->count())->toBe(14);
});
