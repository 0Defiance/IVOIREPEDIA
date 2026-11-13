<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\HistoryStory;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

/**
 * Section « Histoire incroyable » — lecture seule.
 *
 * Les récits changent rarement et sont identiques pour tous : une réponse en
 * cache de six heures suffit et évite de solliciter la base à chaque visite.
 */
class HistoryController extends Controller
{
    private const CACHE_KEY = 'history.stories.v1';

    public function __invoke(): JsonResponse
    {
        $payload = Cache::remember(self::CACHE_KEY, now()->addHours(6), fn (): array => [
            'data' => HistoryStory::query()
                ->orderBy('position')
                ->get()
                ->map(fn (HistoryStory $story): array => [
                    'slug' => $story->slug,
                    'title' => $story->title,
                    'period' => $story->period,
                    'teaser' => $story->teaser,
                    'paragraphs' => $story->paragraphs,
                    'figures' => $story->figures ?? [],
                    'source' => [
                        'title' => $story->source_title,
                        'publisher' => $story->source_publisher,
                        'year' => $story->source_year,
                        'url' => $story->source_url,
                    ],
                ])
                ->values()
                ->all(),
            'meta' => ['count' => HistoryStory::query()->count()],
        ]);

        return response()->json($payload)
            ->header('Cache-Control', 'public, max-age=3600');
    }
}
