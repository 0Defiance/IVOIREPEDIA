<?php

namespace App\Support;

use Closure;
use Illuminate\Support\Facades\Log;

/**
 * Sauvegarde quotidienne, déclenchée par une visite quand rien d'autre ne le fait.
 *
 * Le compte d'hébergement refuse `crontab` : l'automatisation prévue par
 * l'hébergeur est une tâche du panneau (`php artisan schedule:run` chaque
 * minute, `routes/console.php`). Tant qu'elle n'est pas créée — et en secours si
 * elle disparaît — la première requête de la journée déclenche la sauvegarde,
 * **dans un autre processus PHP** (`spawn`) : ni le visiteur d'un article ni un
 * appel d'API n'attendent le dump, qui n'est qu'un `stat` pour eux. Un verrou
 * empêche deux requêtes simultanées de le lancer deux fois.
 *
 * Ce déclencheur est donc global et non limité aux pages publiques : le
 * 28 novembre 2026, une journée sans visite d'article (API et coquille Flutter
 * seules) ne produisait aucune sauvegarde, ce que le groupe `web` seul ne
 * pouvait pas éviter.
 *
 * Le repère est le même fichier que celui écrit par `backup:run`
 * (`.last-backup`) : quelle que soit la voie, une seule sauvegarde par jour.
 */
final class DailyBackup
{
    public const MARKER = '.last-backup';

    /** Nouvelle tentative une heure après un échec, sans marteler à chaque visite. */
    private const RETRY_DELAY = 3600;

    /** @var Closure():int */
    private readonly Closure $runner;

    /**
     * @param  (Closure():int)|null  $runner  lance la sauvegarde, renvoie son code de sortie
     */
    public function __construct(
        private readonly string $directory,
        ?Closure $runner = null,
        private readonly int $interval = 86400,
        private readonly int $keep = 7,
    ) {
        $this->runner = $runner ?? $this->spawn(...);
    }

    /**
     * Lance `backup:run` dans un autre processus PHP et rend la main aussitôt.
     *
     * C'est ce qui permet au déclencheur de rester sur **toutes** les requêtes :
     * un appel d'API ne paie qu'un `stat` sur le repère, le dump tourne ailleurs.
     * Le processus détaché écrit lui-même le repère à la fin (succès ou échec),
     * et la réservation ci-dessous empêche deux requêtes de le lancer deux fois.
     */
    private function spawn(): int
    {
        $command = sprintf(
            '%s %s backup:run --keep=%d > /dev/null 2>&1 &',
            escapeshellarg(PHP_BINARY),
            escapeshellarg(base_path('artisan')),
            $this->keep,
        );
        exec($command, $ignored, $code);

        return $code;
    }

    /** Dossier et quota lus dans `config/backup.php` (jamais `env()` hors config). */
    public static function fromConfig(): self
    {
        return new self(
            (string) config('backup.directory'),
            interval: (int) config('backup.interval', 86400),
            keep: (int) config('backup.keep', 7),
        );
    }

    public function directory(): string
    {
        return $this->directory;
    }

    public function markerPath(): string
    {
        return $this->directory.'/'.self::MARKER;
    }

    /** Vrai quand aucune sauvegarde n'a eu lieu depuis un intervalle. */
    public function due(?int $now = null): bool
    {
        $now ??= time();
        $last = @filemtime($this->markerPath());

        return $last === false || ($now - $last) >= $this->interval;
    }

    /** Sauvegarde si elle est due ; vrai si une tentative a eu lieu. */
    public function runIfDue(?int $now = null): bool
    {
        $now ??= time();

        if (! $this->due($now)) {
            return false;
        }

        if (! is_dir($this->directory) && ! @mkdir($this->directory, 0750, true) && ! is_dir($this->directory)) {
            Log::warning("Sauvegarde impossible : dossier {$this->directory} inaccessible.");

            return false;
        }

        $lock = @fopen($this->directory.'/.backup.lock', 'c');
        if ($lock === false || ! flock($lock, LOCK_EX | LOCK_NB)) {
            if ($lock !== false) {
                fclose($lock);
            }

            // Une autre requête a pris le verrou : c'est elle qui sauvegarde.
            return false;
        }

        try {
            // Réservation immédiate : si le dump tourne dans un autre processus,
            // une deuxième requête ne doit pas le relancer avant qu'il ait fini.
            $this->record(true, $now);
            $code = ($this->runner)();

            if ($code !== 0) {
                $this->record(false, $now);
                Log::warning("Sauvegarde quotidienne en échec (code {$code}).");
            }

            return true;
        } finally {
            flock($lock, LOCK_UN);
            fclose($lock);
        }
    }

    /**
     * Repère de tentative : après un succès il repousse la suivante de 24 h ;
     * après un échec il la ramène dans une heure.
     */
    private function record(bool $success, int $now): void
    {
        @touch($this->markerPath(), $success ? $now : $now - $this->interval + self::RETRY_DELAY);
    }
}
