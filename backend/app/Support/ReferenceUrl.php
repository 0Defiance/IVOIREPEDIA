<?php

namespace App\Support;

/**
 * Une référence de bibliographie doit pointer vers une page précise : l'accueil
 * d'un site (sans chemin, ou seulement « / ») ne porte aucune information
 * vérifiable. Une URL à requête, comme assnat.ci/?page, reste une page réelle.
 */
final class ReferenceUrl
{
    public static function isHomePage(string $url): bool
    {
        $parts = parse_url($url);

        if ($parts === false || ! isset($parts['host'])) {
            return false;
        }

        $path = $parts['path'] ?? '';

        return ($path === '' || $path === '/') && ! isset($parts['query']);
    }
}
