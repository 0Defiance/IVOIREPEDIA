<?php

namespace App\Console\Commands;

use App\Models\CensusDivision;
use App\Models\ClimateCity;
use App\Models\CountryIndicator;
use App\Models\CountryIndicatorPoint;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Throwable;

/**
 * Remplit les indicateurs et les divisions administratives du pays.
 *
 * Deux gisements, deux natures :
 *  - la Banque mondiale (WDI) fournit une série annuelle, sous licence CC BY 4.0 ;
 *  - le RGPH 2021 fournit des effectifs datés par division administrative.
 *
 * La commande est idempotente : relancée, elle met à jour sans dupliquer.
 * `--offline` n'interroge pas le réseau et n'importe que le recensement, ce qui
 * permet aux tests et à l'intégration continue de tourner sans dépendance
 * externe.
 */
class SyncCountryStatistics extends Command
{
    protected $signature = 'country:sync-statistics
                            {--offline : ne pas interroger la Banque mondiale}
                            {--from-file=database/data/worldbank-civ.json : séries déjà téléchargées à importer}
                            {--ca-bundle= : chemin d’un bundle de certificats, pour un poste sans magasin système}';

    protected $description = "Importe les indicateurs de la Côte d'Ivoire (Banque mondiale) et les divisions du RGPH 2021";

    public function handle(): int
    {
        $this->importCensus();
        $this->importClimate();

        if (! $this->option('offline')) {
            $this->importWorldBank();
        }

        $this->newLine();
        $this->info(sprintf(
            '%d indicateurs, %d points de série, %d divisions administratives.',
            CountryIndicator::query()->count(),
            CountryIndicatorPoint::query()->count(),
            CensusDivision::query()->count(),
        ));

        return self::SUCCESS;
    }

    /** Recensement : divisions administratives et indicateurs datés. */
    private function importCensus(): void
    {
        $path = database_path('data/rgph-2021.json');

        if (! File::exists($path)) {
            $this->warn('Fichier du recensement absent : '.$path);

            return;
        }

        /** @var array<string, mixed> $data */
        $data = json_decode((string) File::get($path), true, 512, JSON_THROW_ON_ERROR);
        $source = $data['source'];

        $national = $data['national'];
        $this->censusIndicator('RGPH.POP.TOTL', 'Population résidente', null, (float) $national['total'], 0, 2021, 0, $source);
        $this->censusIndicator('RGPH.MENAGES', 'Ménages ordinaires', 'ménages', (float) $national['households'], 0, 2021, 1, $source);
        $this->censusIndicator('RGPH.TAILLE.MENAGE', 'Taille moyenne des ménages', 'personnes', (float) $national['averageSize'], 1, 2021, 2, $source);
        $this->censusIndicator(
            'RGPH.FEMMES.ZS',
            'Part des femmes dans la population',
            '%',
            round($national['women'] / $national['total'] * 100, 2),
            1,
            2021,
            3,
            $source,
        );

        $this->importDivisions((array) $data['districts'], CensusDivision::DISTRICT);
        $this->importDivisions((array) $data['regions'], CensusDivision::REGION);
        $this->importDivisions((array) $data['cities'], CensusDivision::CITY);

        $this->line(sprintf(
            'RGPH 2021 : %d districts, %d régions, %d villes.',
            count($data['districts']),
            count($data['regions']),
            count($data['cities']),
        ));
    }

    /**
     * @param  array<string, mixed>  $source
     */
    private function censusIndicator(
        string $code,
        string $label,
        ?string $unit,
        float $value,
        int $decimals,
        int $year,
        int $position,
        array $source,
    ): void {
        $indicator = CountryIndicator::query()->updateOrCreate(
            ['code' => $code],
            [
                'label' => $label,
                'theme' => 'demographie',
                'unit' => $unit,
                'decimals' => $decimals,
                'value' => $value,
                'year' => $year,
                'source_name' => 'ANStat — '.$source['title'],
                'source_url' => $source['url'],
                'source_licence' => $source['licence'],
                'note' => 'Effectifs publiés du recensement, non recalculés.',
                'position' => $position,
            ],
        );

        $indicator->points()->updateOrCreate(
            ['year' => $year],
            ['value' => $value],
        );
    }

    /**
     * @param  array<int, array<string, mixed>>  $rows
     */
    private function importDivisions(array $rows, string $level): void
    {
        $sorted = collect($rows)->sortByDesc('total')->values();

        foreach ($sorted as $index => $row) {
            $name = Str::title(mb_strtolower((string) $row['name']));

            CensusDivision::query()->updateOrCreate(
                ['level' => $level, 'slug' => Str::slug((string) $row['name'])],
                [
                    'name' => $name,
                    'parent' => $row['department'] ? Str::title(mb_strtolower((string) $row['department'])) : null,
                    'population' => (int) $row['total'],
                    'men' => isset($row['men']) ? (int) $row['men'] : null,
                    'women' => isset($row['women']) ? (int) $row['women'] : null,
                    'households' => isset($row['households']) ? (int) $row['households'] : null,
                    'average_size' => isset($row['averageSize']) ? (float) $row['averageSize'] : null,
                    'position' => $index,
                ],
            );
        }
    }

    /**
     * Climatologie : normales mensuelles et cumuls annuels par ville.
     *
     * L'instantané `climate-normals.json` est produit par
     * `database/data/fetch-climate-normals.py` à partir de la réanalyse ERA5
     * (Open-Meteo, CC BY 4.0). Il est importé même en mode `--offline` : la
     * climatologie ne dépend donc pas du réseau au moment du déploiement.
     */
    private function importClimate(): void
    {
        $path = database_path('data/climate-normals.json');

        if (! File::exists($path)) {
            $this->warn('Fichier climatologique absent : '.$path);

            return;
        }

        /** @var array<string, mixed> $data */
        $data = json_decode((string) File::get($path), true, 512, JSON_THROW_ON_ERROR);
        $source = $data['source'];
        $period = $data['period'];
        $months = 0;

        foreach ((array) $data['cities'] as $index => $row) {
            $city = ClimateCity::query()->updateOrCreate(
                ['slug' => $row['slug']],
                [
                    'name' => $row['name'],
                    'latitude' => (float) $row['latitude'],
                    'longitude' => (float) $row['longitude'],
                    'annual_rain_mm' => (float) $row['annual_rain_mm'],
                    'period_start' => (int) substr((string) $period['start'], 0, 4),
                    'period_end' => (int) substr((string) $period['end'], 0, 4),
                    'source_name' => $source['name'],
                    'source_url' => $source['url'],
                    'source_licence' => $source['licence'],
                    'position' => $index,
                ],
            );

            // Les enfants sont remplacés : une correction de l'instantané ne
            // doit pas laisser traîner d'anciennes valeurs.
            $city->months()->delete();
            $city->years()->delete();

            foreach ((array) $row['months'] as $month) {
                $city->months()->create([
                    'month' => (int) $month['month'],
                    'rain_mm' => (float) $month['rain_mm'],
                    'rain_days' => isset($month['rain_days']) ? (float) $month['rain_days'] : null,
                    'temperature_c' => isset($month['temperature_c']) ? (float) $month['temperature_c'] : null,
                ]);
                $months++;
            }

            foreach ((array) $row['years'] as $year) {
                $city->years()->create([
                    'year' => (int) $year['year'],
                    'rain_mm' => (float) $year['rain_mm'],
                ]);
            }
        }

        $this->line(sprintf(
            'Climat %d-%d : %d villes, %d normales mensuelles.',
            $period['start'],
            $period['end'],
            count((array) $data['cities']),
            $months,
        ));
    }

    /**
     * Banque mondiale : série annuelle par indicateur.
     *
     * Deux chemins pour la même donnée : le réseau quand il est disponible,
     * ou un instantané JSON déjà téléchargé (`--from-file`). Le second évite
     * de dépendre d'un accès Internet à chaque déploiement et rend l'import
     * reproductible ; il porte sa provenance et sa date de récupération.
     */
    private function importWorldBank(): void
    {
        $config = config('statistics');
        $since = (int) $config['since'];
        $until = (int) date('Y') + 1;
        $source = $config['source'];
        $snapshot = $this->snapshot();

        foreach ($config['themes'] as $theme => $definition) {
            foreach ($definition['indicators'] as $code => [$label, $unit, $decimals]) {
                $points = $snapshot[$code] ?? $this->fetchWorldBank($code, $since, $until);

                if ($points === []) {
                    $this->warn("Aucune donnée pour {$code} ({$label}).");

                    continue;
                }

                $points = array_combine(
                    array_map('intval', array_keys($points)),
                    array_map('floatval', array_values($points)),
                );
                ksort($points);
                $lastYear = array_key_last($points);

                $indicator = CountryIndicator::query()->updateOrCreate(
                    ['code' => $code],
                    [
                        'label' => $label,
                        'theme' => $theme,
                        'unit' => $unit,
                        'decimals' => $decimals,
                        'value' => $points[$lastYear],
                        'year' => $lastYear,
                        'source_name' => $source['name'],
                        'source_url' => $source['url'],
                        'source_licence' => $source['licence'],
                        'position' => array_search($code, array_keys($definition['indicators']), true) ?: 0,
                    ],
                );

                foreach ($points as $year => $value) {
                    $indicator->points()->updateOrCreate(
                        ['year' => $year],
                        ['value' => $value],
                    );
                }

                $this->line(sprintf('%s : %s (%d)', $code, $points[$lastYear], $lastYear));
            }
        }
    }

    /**
     * Séries de l'instantané JSON, s'il est disponible.
     *
     * @return array<string, array<string, float>>
     */
    private function snapshot(): array
    {
        $file = (string) $this->option('from-file');

        if ($file === '') {
            return [];
        }

        $path = str_starts_with($file, '/') || preg_match('/^[A-Za-z]:/', $file) === 1
            ? $file
            : base_path($file);

        if (! File::exists($path)) {
            return [];
        }

        /** @var array<string, mixed> $payload */
        $payload = json_decode((string) File::get($path), true, 512, JSON_THROW_ON_ERROR);

        return (array) ($payload['series'] ?? []);
    }

    /**
     * @return array<int, float>
     */
    private function fetchWorldBank(string $code, int $since, int $until): array
    {
        $url = sprintf(
            'https://api.worldbank.org/v2/country/%s/indicator/%s?format=json&per_page=1000&date=%d:%d',
            config('statistics.country'),
            $code,
            $since,
            $until,
        );

        try {
            $request = Http::timeout(30)->retry(2, 500);

            // Certains postes Windows n'ont pas de magasin de certificats : on
            // accepte un bundle explicite plutôt que de désactiver la vérification.
            if ($bundle = $this->option('ca-bundle')) {
                $request = $request->withOptions(['verify' => $bundle]);
            }

            $response = $request->get($url);
        } catch (Throwable $exception) {
            $this->warn("Échec réseau pour {$code} : ".$exception->getMessage());

            return [];
        }

        if (! $response->successful()) {
            $this->warn("Réponse {$response->status()} pour {$code}.");

            return [];
        }

        $payload = $response->json();

        if (! is_array($payload) || ! isset($payload[1]) || ! is_array($payload[1])) {
            return [];
        }

        $points = [];

        foreach ($payload[1] as $row) {
            // `isset` écarte déjà les valeurs nulles renvoyées par l'API.
            if (! is_array($row) || ! isset($row['date'], $row['value'])) {
                continue;
            }

            $points[(int) $row['date']] = (float) $row['value'];
        }

        return $points;
    }
}
