<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CensusDivision;
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
                ],
                'headline' => $headline,
                'themes' => $themes,
                'divisions' => [
                    'districts' => $this->divisions(CensusDivision::DISTRICT),
                    'regions' => $this->divisions(CensusDivision::REGION),
                    'cities' => $this->divisions(CensusDivision::CITY),
                ],
            ],
            'meta' => [
                'updated_at' => $indicators->max(fn (CountryIndicator $indicator) => $indicator->updated_at)?->toIso8601String(),
                'indicators' => $indicators->count(),
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
            'series' => $indicator->points
                ->map(fn ($point) => ['year' => $point->year, 'value' => (float) $point->value])
                ->values()
                ->all(),
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
