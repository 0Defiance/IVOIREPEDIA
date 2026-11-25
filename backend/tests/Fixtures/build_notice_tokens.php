<?php

/**
 * Régénère tests/Fixtures/notice_tokens.php à partir d'un dossier de notices
 * Wikipédia (extraits en texte brut, action=query&prop=extracts&explaintext=1,
 * un fichier <slug>.txt par fiche).
 *
 * Usage : php tests/Fixtures/build_notice_tokens.php /chemin/vers/notices
 *
 * Chaque notice est réduite à l'ensemble de ses jetons alphanumériques
 * distincts, en minuscules : le test de recouvrement compare les phrases des
 * fiches à cet ensemble, sans embarquer les notices elles-mêmes.
 */
$dir = $argv[1] ?? null;

if ($dir === null || ! is_dir($dir)) {
    fwrite(STDERR, "Usage : php build_notice_tokens.php <dossier des notices>\n");
    exit(1);
}

$notices = [];

foreach (glob(rtrim($dir, '/\\').'/*.txt') ?: [] as $file) {
    $slug = basename($file, '.txt');
    $text = file_get_contents($file);

    if ($text === false || trim($text) === '') {
        continue;
    }

    $normalized = mb_strtolower(preg_replace('/[^\p{L}\p{N}]+/u', ' ', $text) ?? '');
    $tokens = array_values(array_unique(array_filter(
        preg_split('/\s+/u', trim($normalized)) ?: [],
        fn (string $token): bool => $token !== '',
    )));
    sort($tokens);

    $notices[$slug] = implode(' ', $tokens);
}

ksort($notices);

$php = "<?php\n\n";
$php .= "/*\n";
$php .= " * Jetons distincts des notices Wikipédia citées par les fiches de\n";
$php .= " * database/data/personalities.php (extraits en texte brut, relevés le\n";
$php .= " * 25 novembre 2026). Fichier généré par build_notice_tokens.php : ne pas\n";
$php .= " * éditer à la main.\n";
$php .= " */\n\n";
$php .= "return [\n";

foreach ($notices as $slug => $tokens) {
    $php .= '    '.var_export($slug, true).' => '.var_export($tokens, true).",\n";
}

$php .= "];\n";

file_put_contents(__DIR__.'/notice_tokens.php', $php);
echo count($notices).' notices, '.round(strlen($php) / 1048576, 2)." Mo\n";
