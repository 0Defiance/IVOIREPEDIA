<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CensusDivision;
use App\Models\ClimateCity;
use App\Models\CountryIndicator;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

/**
 * Statistiques publiques du pays — page « La Côte d'Ivoire en chiffres ».
 *
 * Tout est en lecture seule et mis en cache six heures : la page ne doit pas
 * dépendre d'une base lente à chaque visite, et les chiffres ne changent pas
 * d'une heure à l'autre.
 */
class StatisticsController extends Controller
{
    private const CACHE_KEY = 'statistics.public.v1';

    public function __invoke(): JsonResponse
    {
        $payload = Cache::remember(self::CACHE_KEY, now()->addHours(6), fn (): array => $this->build());

        return response()->json($payload)
            ->header('Cache-Control', 'public, max-age=3600');
    }

    /**
     * @return array<string, mixed>
     */
    private function build(): array
    {
        $config = config('statistics');
        $indicators = CountryIndicator::query()->with('points')->get()->keyBy('code');

        $themes = [];

        foreach ($config['themes'] as $code => $definition) {
            $rows = [];

            foreach (array_keys($definition['indicators']) as $indicatorCode) {
                $indicator = $indicators->get($indicatorCode);

                if ($indicator !== null) {
                    $rows[] = $this->indicatorPayload($indicator);
                }
            }

            if ($rows !== []) {
                $themes[] = ['code' => $code, 'label' => $definition['label'], 'indicators' => $rows];
            }
        }

        $headline = [];

        foreach ($config['headline'] as $indicatorCode) {
            $indicator = $indicators->get($indicatorCode);

            if ($indicator !== null) {
                $headline[] = $this->indicatorPayload($indicator);
            }
        }

        // Les indicateurs du recensement ne sont pas dans la configuration : ils
        // sont ajoutés en tête de la démographie pour que la population résidente
        // (29 389 150 en 2021) ne soit pas confondue avec l'estimation annuelle
        // de la Banque mondiale.
        $census = $indicators->filter(fn (CountryIndicator $indicator): bool => str_starts_with($indicator->code, 'RGPH.'));
        $population = $census->get('RGPH.POP.TOTL');
        $households = $census->get('RGPH.MENAGES');
        $averageSize = $census->get('RGPH.TAILLE.MENAGE');
        $womenShare = $census->get('RGPH.FEMMES.ZS');

        return [
            'data' => [
                'census' => [
                    'year' => 2021,
                    'population' => $population === null ? 0 : (int) $population->value,
                    'households' => $households === null ? 0 : (int) $households->value,
                    'average_size' => $averageSize === null ? 0.0 : (float) $averageSize->value,
                    'women_share' => $womenShare === null ? 0.0 : (float) $womenShare->value,
                    'source' => $this->sourcePayload($population),
                    'growth' => $this->censusGrowth(),
                ],
                'headline' => $headline,
                'themes' => $themes,
                'climate' => $this->climate(),
                'divisions' => [
                    'districts' => $this->divisions(CensusDivision::DISTRICT),
                    'regions' => $this->divisions(CensusDivision::REGION),
                    'cities' => $this->divisions(CensusDivision::CITY),
                ],
            ],
            'meta' => [
                'updated_at' => $indicators->max(fn (CountryIndicator $indicator) => $indicator->updated_at)?->toIso8601String(),
                'indicators' => $indicators->count(),
                // Année la plus récente publiée, tous indicateurs confondus :
                // c'est la date affichée en tête de page.
                'data_through' => $indicators->max(fn (CountryIndicator $indicator) => $indicator->year),
                'census_year' => 2021,
                'census_note' => 'Le RGPH 2021 est le dernier recensement publié : '
                    .'les effectifs de districts, régions et villes datent du 14 décembre 2021 '
                    .'et ne sont pas remplacés par des estimations.',
                'sources' => collect($themes)
                    ->flatMap(fn (array $theme) => $theme['indicators'])
                    ->pluck('source.name')
                    ->unique()
                    ->values()
                    ->all(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function indicatorPayload(CountryIndicator $indicator): array
    {
        return [
            'code' => $indicator->code,
            'label' => $indicator->label,
            'unit' => $indicator->unit,
            'decimals' => $indicator->decimals,
            'value' => $indicator->value === null ? null : (float) $indicator->value,
            'display' => $indicator->displayValue(),
            'year' => $indicator->year,
            'source' => $this->sourcePayload($indicator),
            // Évolution annuelle moyenne des cinq dernières années : c'est
            // l'information qu'une valeur seule ne donne pas.
            'trend' => $this->trend($indicator),
            'series' => $indicator->points
                ->map(fn ($point) => ['year' => $point->year, 'value' => (float) $point->value])
                ->values()
                ->all(),
        ];
    }

    /**
     * Évolution annuelle moyenne sur les cinq dernières années disponibles.
     *
     * Le pourcentage est un taux de croissance composé ; pour un indicateur
     * déjà exprimé en pourcentage (alphabétisation, chômage…), il n'a pas de
     * sens et l'écart est donné en points.
     *
     * @return array<string, mixed>|null
     */
    private function trend(CountryIndicator $indicator): ?array
    {
        $points = $indicator->points->sortBy('year')->values();

        if ($points->count() < 2) {
            return null;
        }

        $last = $points->last();
        $first = $points->filter(fn ($point): bool => $point->year >= $last->year - 5)->first() ?? $points->first();
        $span = $last->year - $first->year;
        $start = (float) $first->value;
        $end = (float) $last->value;

        if ($span <= 0 || $start == 0.0) {
            return null;
        }

        $perYear = ($end - $start) / $span;
        $isPercentage = str_contains((string) $indicator->unit, '%');
        $percent = $isPercentage || $start <= 0
            ? null
            : (pow($end / $start, 1 / $span) - 1) * 100;

        $amount = number_format(abs($perYear), $perYear >= 0 && abs($perYear) < 10 ? 2 : 0, ',', ' ');
        $label = $isPercentage
            ? sprintf('%+.2f point par an (%d-%d)', $perYear, $first->year, $last->year)
            : ($percent === null
                ? sprintf('%s %s par an (%d-%d)', $perYear >= 0 ? '+' : '-', $amount, $first->year, $last->year)
                : sprintf('%+.1f %% par an (%d-%d)', $percent, $first->year, $last->year));

        return [
            'from_year' => $first->year,
            'to_year' => $last->year,
            'span_years' => $span,
            'absolute_per_year' => round($perYear, 3),
            'percent_per_year' => $percent === null ? null : round($percent, 2),
            'direction' => $end > $start ? 'hausse' : ($end < $start ? 'baisse' : 'stable'),
            'display' => str_replace('.', ',', $label),
        ];
    }

    /**
     * Croissance démographique nationale la plus récente (série SP.POP.GROW).
     *
     * @return array<string, mixed>|null
     */
    private function censusGrowth(): ?array
    {
        $indicator = CountryIndicator::query()->with('points')->where('code', 'SP.POP.GROW')->first();
        $last = $indicator?->points->sortBy('year')->last();

        if ($last === null) {
            return null;
        }

        return [
            'percent_per_year' => round((float) $last->value, 2),
            'year' => $last->year,
            'source' => $this->sourcePayload($indicator),
        ];
    }

    /**
     * @return array<string, string|null>
     */
    private function sourcePayload(?CountryIndicator $indicator): array
    {
        return [
            'name' => $indicator?->source_name,
            'url' => $indicator?->source_url,
            'licence' => $indicator?->source_licence,
        ];
    }

    /**
     * Climatologie des villes : normales mensuelles et cumuls annuels.
     *
     * Les normales viennent de la réanalyse ERA5 (Open-Meteo, CC BY 4.0) et
     * couvrent 1991-2020 : c'est une moyenne de trente ans, pas une mesure de
     * l'année en cours, et l'API le dit dans `period`.
     *
     * @return array<string, mixed>
     */
    private function climate(): array
    {
        $cities = ClimateCity::query()
            ->with(['months', 'years'])
            ->orderBy('position')
            ->get();

        $first = $cities->first();

        return [
            'period' => $first === null ? null : [
                'start' => $first->period_start,
                'end' => $first->period_end,
            ],
            'source' => [
                'name' => $first?->source_name,
                'url' => $first?->source_url,
                'licence' => $first?->source_licence,
            ],
            'cities' => $cities->map(fn (ClimateCity $city): array => [
                'slug' => $city->slug,
                'name' => $city->name,
                'annual_rain_mm' => (float) $city->annual_rain_mm,
                'months' => $city->months->map(fn ($month): array => [
                    'month' => $month->month,
                    'rain_mm' => (float) $month->rain_mm,
                    'rain_days' => $month->rain_days === null ? null : (float) $month->rain_days,
                    'temperature_c' => $month->temperature_c === null ? null : (float) $month->temperature_c,
                ])->values()->all(),
                'years' => $city->years->map(fn ($year): array => [
                    'year' => $year->year,
                    'rain_mm' => (float) $year->rain_mm,
                ])->values()->all(),
            ])->values()->all(),
        ];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function divisions(string $level): array
    {
        return CensusDivision::query()
            ->ofLevel($level)
            ->orderBy('position')
            ->get()
            ->map(fn (CensusDivision $division): array => [
                'name' => $division->name,
                'slug' => $division->slug,
                'parent' => $division->parent,
                'population' => $division->population,
                'men' => $division->men,
                'women' => $division->women,
                'households' => $division->households,
                'average_size' => $division->average_size === null ? null : (float) $division->average_size,
            ])
            ->all();
    }
}
