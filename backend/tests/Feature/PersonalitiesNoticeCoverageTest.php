<?php

use App\Models\Article;
use Database\Seeders\CategorySeeder;
use Database\Seeders\PersonalitiesSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

/**
 * Chaque phrase factuelle d'une biographie doit rester proche de la notice
 * qu'elle cite : on mesure la part de ses mots (hors mots-outils) présents
 * dans la notice, et toute phrase dont les ancres — dates, nombres, noms
 * propres — figurent toutes dans la notice doit dépasser le seuil.
 *
 * Le seuil, les mots-outils et les formules évaluatives écartées sont ceux de
 * l'audit de recouvrement des séances 94 à 96. La fixture notice_tokens.php
 * contient les jetons des notices, sans les notices elles-mêmes (voir
 * build_notice_tokens.php).
 */
uses(RefreshDatabase::class);

const NOTICE_OVERLAP_THRESHOLD = 0.55;

/** @return array<int, string> */
function noticeCoverageStopwords(): array
{
    return ['le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'et', 'en', 'au', 'aux', 'dans', 'pour', 'par', 'sur', 'avec', 'il', 'elle', 'ils', 'elles', 'est', 'sont', 'a', 'ont', 'qui', 'que', 'son', 'sa', 'ses', 'ce', 'cette', 'ces', 'se', 'ne', 'pas', 'plus', 'comme', 'l', 'd', 's', 'à', 'ou', 'où', 'y', 'n'];
}

/** @return array<int, string> */
function noticeCoverageTokens(string $text): array
{
    $normalized = mb_strtolower(preg_replace('/[^\p{L}\p{N}]+/u', ' ', $text) ?? '');
    $stopwords = noticeCoverageStopwords();
    $tokens = [];

    foreach (preg_split('/\s+/u', trim($normalized)) ?: [] as $word) {
        if (mb_strlen($word) > 2 && ! in_array($word, $stopwords, true)) {
            $tokens[] = $word;
        }
    }

    return array_values(array_unique($tokens));
}

/** Texte des paragraphes de la fiche, sans les titres de section. */
function noticeCoverageBody(Article $article): string
{
    $parts = [];
    $ops = $article->content['ops'] ?? [];

    if (! is_array($ops)) {
        return '';
    }

    foreach ($ops as $op) {
        if (! is_array($op) || ! isset($op['insert']) || ! is_string($op['insert'])) {
            continue;
        }

        if (isset($op['attributes']['header'])) {
            continue;
        }

        $parts[] = $op['insert'];
    }

    return trim(implode(' ', $parts));
}

/** @return array<int, string> */
function noticeCoverageAnchors(string $sentence): array
{
    preg_match_all('/\b(1[6-9]\d{2}|20[0-2]\d)\b/u', $sentence, $years);
    preg_match_all('/(?<![\p{L}\d])(\d{1,3}(?:[  ]\d{3})*|\d+)(?![\d\p{L}])/u', $sentence, $numbers);
    preg_match_all('/\b\p{Lu}[\p{L}\-’\']{2,}/u', $sentence, $names);

    $ignored = ['Le', 'La', 'Les', 'Il', 'Elle', 'En', 'Au', 'Aux', 'Dans', 'Pour', 'Par', 'Sur', 'Avec', 'Son', 'Sa', 'Ses', 'Ce', 'Cette', 'Ces', 'Après', 'Puis', 'Mais', 'Des', 'Du', 'De', 'Un', 'Une'];
    $anchors = array_merge($years[1], array_filter($numbers[1], fn (string $number): bool => strlen($number) > 1), $names[0]);

    return array_values(array_unique(array_filter($anchors, fn (string $anchor): bool => ! in_array($anchor, $ignored, true))));
}

it('garde chaque phrase factuelle au-dessus du seuil de recouvrement de sa notice', function () {
    /** @var array<string, string> $notices */
    $notices = require __DIR__.'/../Fixtures/notice_tokens.php';

    $this->seed(CategorySeeder::class);
    $this->seed(PersonalitiesSeeder::class);

    $markers = ['reste', 'restent', 'figure', 'figurent', 'incarne', 'illustre', 'symbole', 'référence', 'compte parmi', 'comptent parmi', 'emblématique', 'réputation', 'considéré', 'considérée', 'témoin', 'pionnier', 'doyen', 'majeur', 'majeure', 'légende', 'prestigieux', 'prestigieuse', 'incontournable', 'rayonnement', 'héritage', 'mémoire collective', 'élite', 'au service de', 'au-delà', 'reconnu', 'reconnue'];

    $violations = [];
    $checked = 0;

    Article::query()->each(function (Article $article) use ($notices, $markers, &$violations, &$checked): void {
        $noticeText = $notices[$article->slug] ?? null;

        if ($noticeText === null) {
            return;
        }

        $checked++;
        $notice = array_flip(explode(' ', $noticeText));
        $text = trim($article->summary.' '.noticeCoverageBody($article));

        foreach (preg_split('/(?<=[.!?])\s+/u', $text) ?: [] as $sentence) {
            $sentence = trim($sentence);

            if (mb_strlen($sentence) < 40) {
                continue;
            }

            $tokens = noticeCoverageTokens($sentence);

            if ($tokens === []) {
                continue;
            }

            $known = count(array_filter($tokens, fn (string $token): bool => isset($notice[$token])));
            $ratio = $known / count($tokens);

            if ($ratio >= NOTICE_OVERLAP_THRESHOLD) {
                continue;
            }

            $lower = mb_strtolower($sentence);
            $isEvaluation = false;

            foreach ($markers as $marker) {
                if (mb_strpos($lower, $marker) !== false) {
                    $isEvaluation = true;

                    break;
                }
            }

            if ($isEvaluation) {
                continue;
            }

            $allAnchorsKnown = true;

            foreach (noticeCoverageAnchors($sentence) as $anchor) {
                $needle = mb_strtolower(str_replace('’', "'", $anchor));
                $parts = preg_split('/[^\p{L}\p{N}]+/u', $needle, -1, PREG_SPLIT_NO_EMPTY) ?: [];

                foreach ($parts as $part) {
                    if (! isset($notice[$part])) {
                        $allAnchorsKnown = false;

                        break 2;
                    }
                }
            }

            if (! $allAnchorsKnown) {
                continue;
            }

            $violations[] = $article->slug.' ('.round($ratio, 2).') : '.mb_substr($sentence, 0, 90);
        }
    });

    expect($checked)->toBeGreaterThanOrEqual(290);
    expect($violations)->toBe([]);
});
