<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\HistoryStory;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

/**
 * Frise chronologique de l'histoire ivoirienne — lecture seule.
 *
 * La frise n'a pas de contenu propre : elle est alimentée par les récits de
 * « Histoire incroyable », chacun portant une année de référence. Ajouter un
 * récit daté suffit donc à ajouter un jalon, sans second jeu de données à
 * maintenir ni risque de divergence entre les deux pages.
 *
 * L'année sert au classement ; c'est `period` qui est affiché, parce qu'un
 * récit peut couvrir un siècle entier.
 */
class TimelineController extends Controller
{
    private const CACHE_KEY = 'history.timeline.v1';

    public function __invoke(): JsonResponse
    {
        $payload = Cache::remember(self::CACHE_KEY, now()->addHours(6), function (): array {
            $stories = HistoryStory::query()
                ->whereNotNull('year')
                ->orderBy('year')
                ->orderBy('position')
                ->get();

            return [
                'data' => $stories
                    ->map(fn (HistoryStory $story): array => [
                        'slug' => $story->slug,
                        'year' => $story->year,
                        'era' => $this->era($story->year),
                        'period' => $story->period,
                        'title' => $story->title,
                        'teaser' => $story->teaser,
                        'source' => [
                            'title' => $story->source_title,
                            'publisher' => $story->source_publisher,
                            'year' => $story->source_year,
                            'url' => $story->source_url,
                        ],
                    ])
                    ->values()
                    ->all(),
                'meta' => [
                    'count' => $stories->count(),
                    'first_year' => $stories->first()?->year,
                    'last_year' => $stories->last()?->year,
                ],
            ];
        });

        return response()->json($payload)
            ->header('Cache-Control', 'public, max-age=3600');
    }

    /** Regroupement lisible : la frise saute les siècles vides. */
    private function era(?int $year): string
    {
        return match (true) {
            $year === null => 'Date inconnue',
            $year < 1800 => 'Avant 1800',
            $year < 1900 => 'XIXe siècle',
            $year < 2000 => 'XXe siècle',
            default => 'XXIe siècle',
        };
    }
}
