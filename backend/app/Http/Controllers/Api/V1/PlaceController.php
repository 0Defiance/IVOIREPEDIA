<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ArticleSummaryResource;
use App\Models\Article;
use App\Models\CensusDivision;
use App\Models\ClimateCity;
use App\Models\CountryIndicator;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

/**
 * Fiches géographiques — districts, régions et villes du RGPH 2021.
 *
 * Une même commune peut apparaître à plusieurs niveaux (Abidjan est à la fois
 * un district et une ville) : la fiche rassemble donc toutes les lignes qui
 * portent le même identifiant d'URL, au lieu d'imposer un niveau dans l'adresse.
 *
 * Les effectifs sont ceux de l'ANStat (RGPH 2021), jamais recalculés ; le
 * climat n'est renseigné que pour les villes couvertes par la climatologie,
 * et les articles liés sont retrouvés par leur titre ou leur chapeau.
 */
class PlaceController extends Controller
{
    private const CACHE_KEY = 'places.index.v1';

    private const SOURCE = [
        'name' => 'ANStat — RGPH 2021, résultats globaux',
        'url' => 'https://plan.gouv.ci/uploads/publications/RGPH2021-RESULTATS-GLOBAUX-VF.pdf',
        'licence' => 'Licence Ouverte',
    ];

    /** `GET /api/v1/places` — les trois niveaux, prêts pour l'annuaire. */
    public function index(): JsonResponse
    {
        $payload = Cache::remember(self::CACHE_KEY, now()->addHours(6), fn (): array => [
            'data' => [
                'districts' => $this->rows(CensusDivision::DISTRICT),
                'regions' => $this->rows(CensusDivision::REGION),
                'cities' => $this->rows(CensusDivision::CITY),
            ],
            'meta' => [
                'census_year' => 2021,
                'source' => self::SOURCE,
            ],
        ]);

        return response()->json($payload)
            ->header('Cache-Control', 'public, max-age=3600');
    }

    /** `GET /api/v1/places/{slug}` — fiche d'un lieu. */
    public function show(string $slug): JsonResponse
    {
        $payload = Cache::remember(
            'places.show.v2.'.$slug,
            now()->addHours(6),
            fn (): ?array => $this->build($slug),
        );

        if ($payload === null) {
            return response()->json([
                'error' => [
                    'code' => 'NOT_FOUND',
                    'message' => "Ce lieu n'existe pas dans le recensement.",
                ],
            ], 404);
        }

        return response()->json(['data' => $payload])
            ->header('Cache-Control', 'public, max-age=3600');
    }

    /**
     * @return array<string, mixed>|null
     */
    private function build(string $slug): ?array
    {
        $entries = CensusDivision::query()
            ->where('slug', $slug)
            ->get()
            ->sortBy(fn (CensusDivision $division): int => match ($division->level) {
                CensusDivision::DISTRICT => 0,
                CensusDivision::REGION => 1,
                default => 2,
            })
            ->values();

        if ($entries->isEmpty()) {
            return null;
        }

        $primary = $entries->first();
        $parent = $this->parentOf($primary);

        return [
            'slug' => $slug,
            'name' => $primary->name,
            'level' => $primary->level,
            'parent' => $parent,
            'entries' => $entries->map(fn (CensusDivision $division): array => [
                'level' => $division->level,
                'label' => $this->levelLabel($division->level),
                'population' => $division->population,
                'men' => $division->men,
                'women' => $division->women,
                'households' => $division->households,
                'average_size' => $division->average_size === null ? null : (float) $division->average_size,
            ])->all(),
            'climate' => $this->climate($primary->name),
            'estimate' => $this->estimate($primary),
            'articles' => $this->articles($primary->name),
            'source' => self::SOURCE,
        ];
    }

    /**
     * Département de rattachement. Le recensement ne donne pas le district
     * d'une région : son `parent` est le département, et l'API le nomme ainsi.
     */
    private function parentOf(CensusDivision $division): ?string
    {
        return $division->level === CensusDivision::DISTRICT ? null : $division->parent;
    }

    /**
     * Estimation pour l'année en cours.
     *
     * Aucun recensement n'a été publié depuis 2021 : on extrapole les effectifs
     * du RGPH avec la croissance démographique nationale la plus récente de la
     * Banque mondiale. Le calcul est affiché avec sa méthode, et présenté comme
     * une estimation — jamais comme un chiffre officiel.
     *
     * @return array<string, mixed>|null
     */
    private function estimate(CensusDivision $division): ?array
    {
        $indicator = CountryIndicator::query()->with('points')->where('code', 'SP.POP.GROW')->first();
        $last = $indicator?->points->sortBy('year')->last();

        if ($last === null) {
            return null;
        }

        $rate = (float) $last->value / 100;
        $years = max(0, 2026 - 2021);

        return [
            'year' => 2026,
            'population' => (int) round($division->population * (1 + $rate) ** $years),
            'growth_percent' => round((float) $last->value, 2),
            'growth_year' => $last->year,
            'basis' => sprintf(
                'RGPH 2021 extrapolé avec la croissance nationale de %s %% par an (%d)',
                number_format((float) $last->value, 1, ',', ' '),
                $last->year,
            ),
            'note' => 'Estimation de calcul : aucun recensement n’a été publié après 2021.',
        ];
    }

    /**
     * @return array<string, mixed>|null
     */
    private function climate(string $name): ?array
    {
        // Les noms du recensement sont en capitales sans accents (« BOUAKE »),
        // ceux de la climatologie accentués (« Bouaké ») : la comparaison se
        // fait donc sur une forme normalisée.
        $city = ClimateCity::query()
            ->with('months')
            ->get()
            ->first(fn (ClimateCity $candidate): bool => $this->normalize($candidate->name) === $this->normalize($name));

        if ($city === null) {
            return null;
        }

        $wettest = $city->months->sortByDesc('rain_mm')->first();
        $months = $city->months->sortBy('month')->values();
        $temperatures = $months->pluck('temperature_c')->filter(fn ($value) => $value !== null);

        return [
            'slug' => $city->slug,
            'name' => $city->name,
            'period' => ['start' => $city->period_start, 'end' => $city->period_end],
            'annual_rain_mm' => (float) $city->annual_rain_mm,
            'wettest_month' => $wettest === null ? null : [
                'month' => $wettest->month,
                'rain_mm' => (float) $wettest->rain_mm,
            ],
            'average_temperature_c' => $temperatures->isEmpty()
                ? null
                : round($temperatures->avg(), 1),
            'source' => [
                'name' => $city->source_name,
                'url' => $city->source_url,
                'licence' => $city->source_licence,
            ],
        ];
    }

    /**
     * Articles dont le titre ou le chapeau nomme le lieu : c'est la seule
     * jointure dont nous disposons avant la saisie éditoriale des lieux.
     *
     * @return array<int, array<string, mixed>>
     */
    private function articles(string $name): array
    {
        $articles = Article::query()
            ->published()
            ->where(function ($query) use ($name): void {
                $query->where('title', 'like', '%'.$name.'%')
                    ->orWhere('summary', 'like', '%'.$name.'%');
            })
            ->with(['category', 'author'])
            ->orderByDesc('published_at')
            ->limit(6)
            ->get();

        return ArticleSummaryResource::collection($articles)->resolve();
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function rows(string $level): array
    {
        /** @var Collection<int, CensusDivision> $divisions */
        $divisions = CensusDivision::query()
            ->ofLevel($level)
            ->orderBy('position')
            ->get();

        return $divisions
            ->map(fn (CensusDivision $division): array => [
                'name' => $division->name,
                'slug' => $division->slug,
                'parent' => $division->parent,
                'population' => $division->population,
            ])
            ->values()
            ->all();
    }

    private function normalize(string $value): string
    {
        return Str::lower(Str::ascii($value));
    }

    private function levelLabel(string $level): string
    {
        return match ($level) {
            CensusDivision::DISTRICT => 'District',
            CensusDivision::REGION => 'Région',
            default => 'Ville',
        };
    }
}
