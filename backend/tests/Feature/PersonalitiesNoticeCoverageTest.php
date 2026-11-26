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
 * Toutes les phrases sont contrôlées, y compris les formules évaluatives
 * (« reste », « figure », « considéré »…) et les phrases courtes : ni
 * exemption, ni plancher de longueur. Le seuil et les mots-outils sont ceux
 * de l'audit des séances 94 à 97. La fixture notice_tokens.php contient les
 * jetons des 401 notices, sans les notices elles-mêmes (voir
 * build_notice_tokens.php).
 *
 * Le test surveille aussi la ponctuation du résumé, des paragraphes et des
 * titres de section : les scripts de réécriture ont déjà laissé des doubles
 * points, des espaces avant ponctuation ou des espaces multiples dans
 * personalities.php.
 *
 * Enfin, une année ou un lieu de naissance ou de mort absent de la notice doit
 * venir d'une référence propre à la fiche : une source qui n'est pas Wikipédia.
 * Pour un lieu, c'est la ville — le mot principal, avant la parenthèse — qui
 * doit figurer dans la notice.
 *
 * La même règle vaut pour les ancres d'une phrase : une année, un nombre ou un
 * nom propre que la notice ne porte pas doit venir d'une référence propre. Une
 * phrase n'échappe donc plus au contrôle parce qu'elle nomme une personne, un
 * lieu ou un chiffre inconnu de la notice.
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

/** @return array<int, string> Titres de section de la fiche (blocs h2). */
function noticeCoverageHeadings(Article $article): array
{
    $headings = [];
    $ops = $article->content['ops'] ?? [];

    if (! is_array($ops)) {
        return [];
    }

    foreach ($ops as $op) {
        if (! is_array($op) || ! isset($op['insert']) || ! is_string($op['insert'])) {
            continue;
        }

        if (isset($op['attributes']['header'])) {
            $headings[] = trim($op['insert']);
        }
    }

    return $headings;
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

/** Minuscules sans accents, pour comparer villes et jetons sans piège typographique. */
function noticeCoveragePlain(string $value): string
{
    return strtr(mb_strtolower($value), [
        'à' => 'a', 'â' => 'a', 'ä' => 'a', 'á' => 'a', 'ã' => 'a', 'å' => 'a',
        'ç' => 'c', 'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
        'î' => 'i', 'ï' => 'i', 'í' => 'i', 'ô' => 'o', 'ö' => 'o', 'ó' => 'o', 'õ' => 'o',
        'ù' => 'u', 'û' => 'u', 'ü' => 'u', 'ú' => 'u', 'ÿ' => 'y', 'ñ' => 'n',
    ]);
}

/**
 * Le mot principal du lieu (la ville, avant la parenthèse) figure-t-il dans la
 * notice (accentué ou non) ? Une précision entre parenthèses ne suffit pas :
 * sinon un lieu inventé passerait grâce à la région citée par la notice.
 */
function noticeCoveragePlaceKnown(string $place, array $plainNotice): bool
{
    $head = preg_split('/\s*[\(\[]/u', $place)[0];

    $words = array_filter(
        preg_split('/\s+/u', trim(preg_replace('/[^\p{L}\p{N}]+/u', ' ', noticeCoveragePlain($head)) ?? '')) ?: [],
        fn (string $word): bool => mb_strlen($word) > 2
    );

    if ($words === []) {
        return true;
    }

    foreach ($words as $word) {
        if (! isset($plainNotice[$word])) {
            return false;
        }
    }

    return true;
}

/** La fiche cite-t-elle une source qui n'est pas Wikipédia ? */
function noticeCoverageHasOwnSource(Article $article): bool
{
    foreach ($article->references as $reference) {
        $publisher = (string) $reference->publisher;
        $url = (string) $reference->url;

        if (preg_match('/wiki/i', $publisher) !== 1 && preg_match('/wikipedia\.org/i', $url) !== 1) {
            return true;
        }
    }

    return false;
}

/**
 * Mots capitalisés qui restent des noms communs : titres administratifs,
 * compétitions, surnoms d'équipe. Ils ne sont jamais des ancres factuelles.
 *
 * @return array<int, string>
 */
function noticeCoverageCommonCapitals(): array
{
    return ['État', 'États', 'École', 'Église', 'Assemblée', 'Sénat', 'Parlement', 'Front', 'Rassemblement', 'Union', 'Intérieur', 'Sécurité', 'Défense', 'Économie', 'Énergie', 'Santé', 'Développement', 'Coupe', 'Coupes', 'Mondial', 'Mondiaux', 'Éléphants', 'Invincibles', 'Africains', 'Blues', 'Éditions', 'International'];
}

/**
 * Ancres factuelles d'une phrase : une année, un nombre ou un nom propre absent
 * de la notice est une donnée que la notice ne porte pas.
 *
 * Ne sont pas des ancres : la majuscule de début de phrase, un mot capitalisé
 * précédé d'un déterminant ou d'un numéral (« les Éléphants », « du Front »,
 * « deux Coupes »), un sobriquet entre guillemets (« Big »), un sigle (CAN,
 * PDCI-RDA) — il abrège un nom que la notice porte en clair —, les noms
 * communs listés par noticeCoverageCommonCapitals() et les âges (ils découlent
 * des dates, déjà contrôlées).
 *
 * @return array<int, array{0: string, 1: string}> ancre et nature
 */
function noticeCoverageSentenceAnchors(string $sentence): array
{
    $anchors = [];

    preg_match_all('/\b(1[6-9]\d{2}|20[0-2]\d)\b/u', $sentence, $years);
    foreach ($years[1] as $year) {
        $anchors[] = [$year, 'année'];
    }

    preg_match_all('/(?<![\p{L}\d])(\d{1,3}(?:[  ]\d{3})*|\d+)(?![\d\p{L}])/u', $sentence, $numbers, PREG_OFFSET_CAPTURE);
    foreach ($numbers[1] as [$number, $byteOffset]) {
        if (strlen($number) < 2) {
            continue;
        }

        // Un âge découle des dates déjà contrôlées : ce n'est pas une donnée nouvelle.
        $after = substr($sentence, $byteOffset + strlen($number), 6);
        if (preg_match('/^\s*ans\b/u', $after) === 1) {
            continue;
        }

        $anchors[] = [$number, 'chiffre'];
    }

    preg_match_all('/\b\p{Lu}[\p{L}\-’\']{2,}/u', $sentence, $names, PREG_OFFSET_CAPTURE);

    $runs = [];
    $previousEnd = -2;

    foreach ($names[0] as [$word, $byteOffset]) {
        $gap = substr($sentence, $previousEnd, $byteOffset - $previousEnd);

        if ($runs !== [] && preg_match('/^[\s\-\'’]+$/u', $gap) === 1) {
            $runs[count($runs) - 1]['words'][] = $word;
        } else {
            $runs[] = [
                'words' => [$word],
                'position' => mb_strlen(substr($sentence, 0, $byteOffset)),
            ];
        }

        $previousEnd = $byteOffset + strlen($word);
    }

    foreach ($runs as $run) {
        $words = $run['words'];
        $position = $run['position'];

        if ($position === 0) {
            continue;
        }

        $before = mb_strtolower(mb_substr($sentence, max(0, $position - 16), min(16, $position)));

        if (preg_match('/(?:^|[\s(«"])(?:l|d|n|s|j|m|t|c|qu)[\'’]\s*$/u', $before) === 1) {
            continue;
        }

        if (preg_match('/(?:^|[\s(«"])(?:le|la|les|un|une|des|du|au|aux|ce|cet|cette|ces|leur|leurs|deux|trois|quatre|cinq|six|sept|huit|neuf|dix|plusieurs|quelques|certains)\s*[«"]?\s*$/u', $before) === 1) {
            continue;
        }

        if (preg_match('/[«"]\s*$/u', $before) === 1) {
            continue;
        }

        $isSigle = true;
        $isCapitalOfSpeech = true;

        foreach ($words as $word) {
            if (preg_match('/^[\p{Lu}\-]{2,}$/u', $word) !== 1) {
                $isSigle = false;
            }

            if (! in_array($word, noticeCoverageCommonCapitals(), true)) {
                $isCapitalOfSpeech = false;
            }
        }

        if ($isSigle || $isCapitalOfSpeech) {
            continue;
        }

        $anchors[] = [implode(' ', $words), 'nom propre'];
    }

    return $anchors;
}

/** Défauts de ponctuation laissés par les scripts de réécriture, motif => libellé. */
function personalitiesPunctuationPatterns(): array
{
    return [
        '/\.\./u' => 'double point',
        '/\s[.,]/u' => 'espace avant virgule ou point',
        '/ {2,}/u' => 'espaces multiples',
    ];
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

    $violations = [];
    $formatting = [];
    $unsourcedYears = [];
    $unsourcedPlaces = [];
    $unsourcedAnchors = [];
    $checked = 0;

    Article::query()->with('references')->each(function (Article $article) use ($notices, &$violations, &$formatting, &$unsourcedYears, &$unsourcedPlaces, &$unsourcedAnchors, &$checked): void {
        $noticeText = $notices[$article->slug] ?? null;

        if ($noticeText === null) {
            return;
        }

        $checked++;

        $notice = array_flip(explode(' ', $noticeText));

        $plainNotice = [];
        foreach (explode(' ', $noticeText) as $token) {
            $plainNotice[noticeCoveragePlain($token)] = true;
        }

        $noticeWords = array_flip(
            preg_split('/[^\p{L}\p{N}]+/u', noticeCoveragePlain($noticeText), -1, PREG_SPLIT_NO_EMPTY) ?: []
        );

        $noticeNumbers = [];
        $noticeTokens = explode(' ', $noticeText);

        foreach ($noticeTokens as $noticeToken) {
            if (preg_match('/\d/u', $noticeToken) === 1) {
                $noticeNumbers[preg_replace('/\D/', '', $noticeToken) ?? ''] = true;
            }
        }

        $hasOwnSource = noticeCoverageHasOwnSource($article);

        $titleWords = preg_split('/[^\p{L}\p{N}]+/u', noticeCoveragePlain($article->title), -1, PREG_SPLIT_NO_EMPTY) ?: [];

        foreach (['birthPlace' => 'lieu de naissance', 'deathPlace' => 'lieu de mort'] as $field => $label) {
            $place = $article->infobox[$field] ?? null;

            if (! is_string($place) || trim($place) === '') {
                continue;
            }

            if (noticeCoveragePlaceKnown($place, $plainNotice) || noticeCoverageHasOwnSource($article)) {
                continue;
            }

            $unsourcedPlaces[] = $article->slug.' ('.$label.' '.$place.') : lieu absent de la notice et sans référence hors Wikipédia';
        }

        foreach (['birthDate' => 'naissance', 'deathDate' => 'mort'] as $field => $label) {
            $value = $article->infobox[$field] ?? null;

            if (! is_string($value) || $value === '') {
                continue;
            }

            preg_match_all('/\b(1[6-9]\d{2}|20[0-2]\d)\b/u', $value, $years);

            foreach ($years[1] as $year) {
                if (isset($notice[$year]) || noticeCoverageHasOwnSource($article)) {
                    continue;
                }

                $unsourcedYears[] = $article->slug.' ('.$label.' '.$year.') : année absente de la notice et sans référence hors Wikipédia';
            }
        }

        $punctuated = ['résumé' => $article->summary, 'paragraphes' => noticeCoverageBody($article)];

        foreach (noticeCoverageHeadings($article) as $index => $heading) {
            $punctuated['titre '.($index + 1)] = $heading;
        }

        foreach (personalitiesPunctuationPatterns() as $pattern => $label) {
            foreach ($punctuated as $where => $chunk) {
                if (preg_match($pattern, $chunk) === 1) {
                    $formatting[] = $article->slug.' ('.$where.') : '.$label;
                }
            }
        }

        $text = trim($article->summary.' '.noticeCoverageBody($article));

        foreach (preg_split('/(?<=[.!?])\s+/u', $text) ?: [] as $sentence) {
            $sentence = trim($sentence);

            if ($sentence === '') {
                continue;
            }

            $tokens = noticeCoverageTokens($sentence);

            if ($tokens === []) {
                continue;
            }

            if (! $hasOwnSource) {
                foreach (noticeCoverageSentenceAnchors($sentence) as [$anchor, $label]) {
                    $parts = preg_split('/[^\p{L}\p{N}]+/u', noticeCoveragePlain($anchor), -1, PREG_SPLIT_NO_EMPTY) ?: [];

                    // Le nom du sujet est garanti par le titre de l'article, pas par une phrase.
                    if ($parts !== [] && array_diff($parts, $titleWords) === []) {
                        continue;
                    }

                    // Un nombre se compare chiffre à chiffre : « 1 500 » et « 1500 » sont le même.
                    if ($label === 'chiffre') {
                        $known = isset($noticeNumbers[preg_replace('/\D/', '', $anchor) ?? '']);
                        $groups = preg_split('/\s+/u', trim($anchor)) ?: [];

                        if (! $known && count($groups) > 1) {
                            $known = true;

                            foreach ($groups as $group) {
                                if (! isset($noticeNumbers[preg_replace('/\D/', '', $group) ?? ''])) {
                                    $known = false;
                                }
                            }
                        }

                        if (! $known) {
                            $unsourcedAnchors[] = $article->slug.' ('.$label.' '.$anchor.') : absent de la notice et sans référence hors Wikipédia';
                        }

                        continue;
                    }

                    foreach ($parts as $part) {
                        if (! isset($noticeWords[$part])) {
                            $unsourcedAnchors[] = $article->slug.' ('.$label.' '.$anchor.') : absent de la notice et sans référence hors Wikipédia';

                            break;
                        }
                    }
                }
            }

            $known = count(array_filter($tokens, fn (string $token): bool => isset($notice[$token])));
            $ratio = $known / count($tokens);

            if ($ratio >= NOTICE_OVERLAP_THRESHOLD) {
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

    expect($checked)->toBe(401);
    expect($violations)->toBe([]);
    expect($formatting)->toBe([]);
    expect($unsourcedYears)->toBe([]);
    expect($unsourcedPlaces)->toBe([]);
    expect($unsourcedAnchors)->toBe([]);
});
