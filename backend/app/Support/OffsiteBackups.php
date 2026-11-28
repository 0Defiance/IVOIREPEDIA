<?php

namespace App\Support;

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;

/**
 * Copie hors-site des sauvegardes : les dumps quittent l'hébergeur.
 *
 * Jusqu'au 28 novembre 2026, tous les dumps vivaient dans `~/backups`, sur la
 * même machine et le même compte que la base : un incident de compte perdait
 * les deux (risque R-04, CONTEXT §17). `sync()` envoie sur un disque objet
 * compatible S3 (`config/filesystems.php`, disque `offsite`) les archives
 * encore absentes, puis applique **la même rétention par base** que le serveur.
 *
 * Rien n'est actif tant que `BACKUP_OFFSITE_DISK` n'est pas renseigné : le dump
 * local reste alors la seule copie, et `backup:offsite` le dit clairement.
 */
final class OffsiteBackups
{
    /** `db-<base>-<Ymd-His>.sql.gz` et `media-<base>-<Ymd-His>.tar.gz`. */
    private const NAME = '/^(db|media)-(.+)-(\d{8}-\d{6})\.(sql|tar)\.gz$/';

    /**
     * Repère de la dernière copie réellement confirmée, dans le dossier de
     * sauvegarde. Le panneau l'affiche : l'état du transfert distant n'a de
     * valeur que s'il est visible sans ouvrir de session SSH.
     */
    public const MARKER = '.last-offsite';

    public function __construct(
        private readonly Filesystem $disk,
        private readonly string $directory,
        private readonly string $prefix = 'ivoirepedia',
        private readonly int $keep = 30,
    ) {}

    /** Vrai quand un disque distant est configuré. */
    public static function enabled(): bool
    {
        return (string) config('backup.offsite.disk', '') !== '';
    }

    public static function fromConfig(): ?self
    {
        if (! self::enabled()) {
            return null;
        }

        return new self(
            Storage::disk((string) config('backup.offsite.disk')),
            (string) config('backup.directory'),
            trim((string) config('backup.offsite.prefix', 'ivoirepedia'), '/'),
            max(1, (int) config('backup.offsite.keep', 30)),
        );
    }

    /** Archives locales, des plus récentes aux plus anciennes. */
    public function localFiles(): array
    {
        $directory = rtrim($this->directory, '/\\');
        $files = array_merge(
            glob($directory.'/db-*.sql.gz') ?: [],
            glob($directory.'/media-*.tar.gz') ?: [],
        );
        rsort($files, SORT_STRING);

        return $files;
    }

    /** Clé distante d'une archive locale (`<prefix>/<nom>`). */
    public function keyFor(string $path): string
    {
        $name = basename($path);

        return $this->prefix === '' ? $name : $this->prefix.'/'.$name;
    }

    public function has(string $key): bool
    {
        return $this->disk->exists($key);
    }

    /**
     * Horodatage de la dernière copie confirmée, lu dans le dossier de
     * sauvegarde — aucun appel au disque distant, donc utilisable par une page.
     */
    public static function copiedAt(string $directory): ?int
    {
        $at = @filemtime(rtrim($directory, '/\\').'/'.self::MARKER);

        return $at === false ? null : $at;
    }

    /**
     * Archives locales absentes du disque distant, ou de taille différente.
     *
     * @return list<string>
     */
    public function pending(): array
    {
        $pending = [];

        foreach ($this->localFiles() as $path) {
            $key = $this->keyFor($path);
            $size = (int) @filesize($path);

            if ($this->disk->exists($key) && (int) $this->disk->size($key) === $size) {
                continue;
            }

            $pending[] = $path;
        }

        return $pending;
    }

    /** Envoi d'une archive, en flux : un dump de 40 Mo ne passe pas en mémoire. */
    public function upload(string $path): bool
    {
        $stream = @fopen($path, 'rb');
        if ($stream === false) {
            return false;
        }

        try {
            return $this->disk->writeStream($this->keyFor($path), $stream) !== false;
        } finally {
            if (is_resource($stream)) {
                fclose($stream);
            }
        }
    }

    /**
     * @return array{uploaded: list<string>, pruned: list<string>}
     */
    public function sync(): array
    {
        $uploaded = [];

        foreach ($this->pending() as $path) {
            if ($this->upload($path)) {
                $uploaded[] = $this->keyFor($path);
            }
        }

        // Rien d'envoyé, rien de neuf à dater : le repère dit « dernière copie »,
        // pas « dernier passage ».
        if ($uploaded !== []) {
            @touch(rtrim($this->directory, '/\\').'/'.self::MARKER);
        }

        return ['uploaded' => $uploaded, 'pruned' => $this->prune()];
    }

    /**
     * Même règle que sur le serveur : `keep` archives par type **et par base**,
     * pour qu'un dump de développement ne puisse pas évincer celui de production.
     *
     * @return list<string>
     */
    public function prune(): array
    {
        /** @var array<string, list<string>> $groups */
        $groups = [];

        foreach ($this->disk->allFiles($this->prefix) as $key) {
            if (preg_match(self::NAME, basename($key), $match) !== 1) {
                continue; // fichier inconnu : on n'y touche pas
            }

            $groups[$match[1].'-'.$match[2]][] = $key;
        }

        $pruned = [];

        foreach ($groups as $keys) {
            rsort($keys, SORT_STRING);

            foreach (array_slice($keys, $this->keep) as $old) {
                if ($this->disk->delete($old)) {
                    $pruned[] = $old;
                }
            }
        }

        return $pruned;
    }
}
