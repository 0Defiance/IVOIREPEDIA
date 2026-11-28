<?php

namespace App\Support;

/**
 * Nommage et rétention des sauvegardes — une base ne peut pas en évincer une autre.
 *
 * Les fichiers portent le nom de leur base : `db-<base>-<horodatage>.sql.gz` et
 * `media-<base>-<horodatage>.tar.gz`. La rétention se calcule donc **base par
 * base** : une série de sauvegardes de `ivoirepedia_dev` — un essai de
 * restauration, par exemple — ne peut pas faire disparaître le dernier dump de
 * `ivoirepedia_prod`, qui doit toujours être le dernier à vieillir.
 */
final class BackupRetention
{
    /** Extension de chaque type d'archive, par préfixe de nom. */
    public const KINDS = ['db' => 'sql.gz', 'media' => 'tar.gz'];

    /** Nom de base utilisable dans un nom de fichier (`:memory:` → `memory`). */
    public static function label(string $database): string
    {
        $label = preg_replace('/[^A-Za-z0-9_]+/', '_', $database) ?? '';
        $label = trim($label, '_');

        return $label === '' ? 'base' : $label;
    }

    /** Chemin complet d'une sauvegarde, tel que la commande l'écrira. */
    public static function path(string $directory, string $kind, string $database, string $stamp): string
    {
        $suffix = self::KINDS[$kind] ?? self::KINDS['db'];

        return rtrim($directory, '/\\').'/'.$kind.'-'.self::label($database).'-'.$stamp.'.'.$suffix;
    }

    /**
     * Sauvegardes existantes de **cette** base, de la plus récente à la plus ancienne.
     *
     * L'horodatage est dans le nom (`Ymd-His`) : le tri lexicographique est donc
     * chronologique, sans dépendre des dates de modification du système de fichiers.
     *
     * @return list<string>
     */
    public static function candidates(string $directory, string $database, string $kind = 'db'): array
    {
        $suffix = self::KINDS[$kind] ?? self::KINDS['db'];
        $pattern = rtrim($directory, '/\\').'/'.$kind.'-'.self::label($database).'-*.'.$suffix;
        $files = glob($pattern) ?: [];
        rsort($files, SORT_STRING);

        return $files;
    }

    /**
     * Fichiers à supprimer pour ne garder que les $keep plus récents.
     *
     * @param  list<string>  $candidates  du plus récent au plus ancien
     * @return list<string>
     */
    public static function expired(array $candidates, int $keep): array
    {
        return array_slice($candidates, max(0, $keep));
    }
}
