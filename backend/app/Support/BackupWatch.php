<?php

namespace App\Support;

use App\Mail\BackupStale;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

/**
 * Alerte « aucune sauvegarde depuis N heures » (36 h par défaut).
 *
 * Une sauvegarde qui cesse sans que personne s'en aperçoive est le vrai danger :
 * le déclencheur peut se taire (disque plein, compte suspendu, tâche effacée,
 * processus détaché tué) et le site, lui, continue de répondre. Le contrôle lit
 * deux choses après l'envoi de la réponse — le nom du dernier dump et la date de
 * la dernière alerte — et n'ouvre jamais une archive.
 *
 * Le silence se choisit : sans `BACKUP_ALERT_EMAIL`, la panne reste dans les
 * journaux. Avec, un courriel part au plus une fois par jour.
 */
final class BackupWatch
{
    public const ALERT_MARKER = '.last-alert';

    public function __construct(
        private readonly string $directory,
        private readonly string $database,
        private readonly ?string $to = null,
        private readonly int $after = 129600,
        private readonly int $cooldown = 86400,
    ) {}

    public static function fromConfig(): self
    {
        $to = config('backup.alert.to');

        return new self(
            (string) config('backup.directory'),
            (string) config('database.connections.mysql.database', ''),
            is_string($to) && $to !== '' ? $to : null,
            max(3600, (int) config('backup.alert.after', 129600)),
            max(3600, (int) config('backup.alert.cooldown', 86400)),
        );
    }

    /** Horodatage du dernier dump de **cette** base, lu dans son nom. */
    public function lastAt(): ?int
    {
        foreach (BackupRetention::candidates($this->directory, $this->database) as $file) {
            $at = $this->stampOf($file);

            if ($at !== null) {
                return $at;
            }
        }

        return null;
    }

    public function age(?int $now = null): ?int
    {
        $now ??= time();
        $last = $this->lastAt();

        return $last === null ? null : max(0, $now - $last);
    }

    /** Seuil d'alerte en secondes (36 h par défaut), pour l'afficher tel quel. */
    public function after(): int
    {
        return $this->after;
    }

    /** Vrai quand il n'y a aucun dump, ou que le dernier dépasse le délai. */
    public function stale(?int $now = null): bool
    {
        $age = $this->age($now);

        return $age === null || $age >= $this->after;
    }

    /**
     * Envoie l'alerte si elle est due et qu'aucune n'est partie depuis le délai
     * de repos. Vrai quand un courriel est réellement parti.
     */
    public function alertIfStale(?int $now = null): bool
    {
        $now ??= time();

        if (! $this->stale($now)) {
            return false;
        }

        $marker = rtrim($this->directory, '/\\').'/'.self::ALERT_MARKER;
        $sentAt = @filemtime($marker);

        if ($sentAt !== false && ($now - $sentAt) < $this->cooldown) {
            return false;
        }

        $age = $this->age($now);
        Log::warning($this->summary($age));

        if ($this->to === null) {
            return false;
        }

        Mail::to($this->to)->send(new BackupStale(
            database: $this->database,
            age: $age,
            lastAt: $this->lastAt(),
            after: $this->after,
            directory: $this->directory,
        ));

        @touch($marker, $now);

        return true;
    }

    public function summary(?int $age): string
    {
        $last = $this->lastAt();

        if ($last === null) {
            return "Sauvegarde : aucun dump de {$this->database} dans {$this->directory}.";
        }

        return sprintf(
            'Sauvegarde : le dernier dump de %s a %d h (%s).',
            $this->database,
            intdiv((int) $age, 3600),
            gmdate('Y-m-d H:i', $last).' UTC',
        );
    }

    /** `db-<base>-<Ymd-His>.sql.gz` → horodatage Unix. */
    private function stampOf(string $file): ?int
    {
        if (preg_match('/-(\d{8}-\d{6})\.sql\.gz$/', basename($file), $match) !== 1) {
            return null;
        }

        $stamp = \DateTimeImmutable::createFromFormat('Ymd-His', $match[1], new \DateTimeZone('UTC'));

        return $stamp === false ? null : $stamp->getTimestamp();
    }
}
