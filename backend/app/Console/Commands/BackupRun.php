<?php

namespace App\Console\Commands;

use App\Support\BackupRetention;
use App\Support\DailyBackup;
use Illuminate\Console\Command;
use RuntimeException;
use Symfony\Component\Process\ExecutableFinder;
use Symfony\Component\Process\Process;

/**
 * Sauvegarde la base et les médias dans `~/backups`.
 *
 * C'est le seul endroit qui fabrique un dump : `tools/backup_db.py` l'appelle
 * par SSH pour le lancer à la main et rapatrier les fichiers (il lit les lignes
 * `dump=` et `media=` écrites ici). La rétention est celle de
 * `BackupRetention` — par base, pour qu'un dump de développement ne puisse pas
 * évincer celui de production.
 *
 * Lancé chaque nuit par la tâche planifiée du compte, qui exécute
 * `php artisan schedule:run` (`routes/console.php`, docs/DEPLOIEMENT.md §8).
 */
class BackupRun extends Command
{
    protected $signature = 'backup:run
                            {--keep=7 : paires conservées par base}
                            {--database= : base à sauvegarder (par défaut celle du .env)}
                            {--skip-media : ne pas archiver les médias}
                            {--dir= : dossier de destination (par défaut ~/backups)}
                            {--dry-run : afficher le plan sans exécuter mysqldump}';

    protected $description = 'Sauvegarde la base et les médias, avec une rétention par base';

    public function handle(): int
    {
        $config = config('database.connections.mysql');
        $database = (string) ($this->option('database') ?: ($config['database'] ?? ''));

        if ($database === '') {
            $this->error('Aucune base à sauvegarder : renseigner --database ou DB_DATABASE.');

            return self::FAILURE;
        }

        $keep = max(1, (int) $this->option('keep'));
        $directory = $this->directory();
        $stamp = date('Ymd-His');
        $dump = BackupRetention::path($directory, 'db', $database, $stamp);
        $media = BackupRetention::path($directory, 'media', $database, $stamp);
        $withMedia = ! $this->option('skip-media');

        if ($this->option('dry-run')) {
            $this->line("dump={$dump}");
            if ($withMedia) {
                $this->line("media={$media}");
            }
            $this->line('Rétention : '.$keep.' paires pour '.$database.' seulement.');

            return self::SUCCESS;
        }

        if (! is_dir($directory) && ! mkdir($directory, 0750, true) && ! is_dir($directory)) {
            $this->error("Dossier de sauvegarde inaccessible : {$directory}");

            return self::FAILURE;
        }

        $credentials = $this->credentialsFile($config);

        try {
            if (! $this->dumpDatabase($credentials, $database, $dump)) {
                @unlink($dump);
                $this->markAttempt($directory, false);

                return self::FAILURE;
            }

            if ($withMedia && ! $this->archiveMedia($media)) {
                $this->markAttempt($directory, false);

                return self::FAILURE;
            }
        } finally {
            @unlink($credentials);
        }

        // Repère partagé avec le déclencheur par requête : quelle que soit la
        // voie, une seule sauvegarde par jour.
        $this->markAttempt($directory, true);

        $this->line("dump={$dump}");
        $this->info("Dump : {$dump} (".$this->humanSize($dump).')');

        if ($withMedia) {
            $this->line("media={$media}");
            $this->info("Médias : {$media} (".$this->humanSize($media).')');
        }

        foreach (['db', 'media'] as $kind) {
            if ($kind === 'media' && ! $withMedia) {
                continue;
            }
            $pruned = BackupRetention::expired(BackupRetention::candidates($directory, $database, $kind), $keep);
            foreach ($pruned as $file) {
                @unlink($file);
                $this->line('Supprimé (rétention '.$keep.') : '.basename($file));
            }
        }

        return self::SUCCESS;
    }

    /** `~/backups` par défaut (config/backup.php) : hors de `backend/`, donc jamais dans un déploiement. */
    private function directory(): string
    {
        $option = (string) $this->option('dir');
        if ($option !== '') {
            return $option;
        }

        return (string) config('backup.directory');
    }

    /**
     * Fichier d'options MySQL (600), supprimé après usage : le mot de passe ne
     * passe ni par la ligne de commande ni par l'environnement du processus.
     *
     * @param  array<string, mixed>  $config
     */
    private function credentialsFile(array $config): string
    {
        $path = tempnam(sys_get_temp_dir(), 'ivp-backup-');
        if ($path === false) {
            throw new RuntimeException('Fichier temporaire impossible pour les identifiants MySQL.');
        }

        $quote = static fn (string $value): string => '"'.str_replace(['\\', '"'], ['\\\\', '\\"'], $value).'"';

        $body = implode("\n", [
            '[client]',
            'host = '.$quote((string) $config['host']),
            'port = '.(string) ($config['port'] ?? 3306),
            'user = '.$quote((string) $config['username']),
            'password = '.$quote((string) $config['password']),
            '',
        ]);

        file_put_contents($path, $body);
        chmod($path, 0600);

        return $path;
    }

    private function dumpDatabase(string $credentials, string $database, string $dump): bool
    {
        $command = sprintf(
            '%s --defaults-extra-file=%s --single-transaction --quick --skip-lock-tables '
            .'--default-character-set=utf8mb4 %s | %s -9 > %s',
            escapeshellarg($this->binary('mysqldump')),
            escapeshellarg($credentials),
            escapeshellarg($database),
            escapeshellarg($this->binary('gzip')),
            escapeshellarg($dump),
        );

        return $this->runShell($command, 'mysqldump');
    }

    private function archiveMedia(string $media): bool
    {
        $command = sprintf(
            '%s czf %s -C %s --exclude=storage/logs storage/app',
            escapeshellarg($this->binary('tar')),
            escapeshellarg($media),
            escapeshellarg(base_path()),
        );

        return $this->runShell($command, 'tar');
    }

    private function runShell(string $command, string $label): bool
    {
        $process = Process::fromShellCommandline($command);
        $process->setTimeout(900);
        $process->run();

        if (! $process->isSuccessful()) {
            $detail = trim($process->getErrorOutput()) ?: trim($process->getOutput());
            $this->error("{$label} a échoué".($detail !== '' ? " : {$detail}" : '.'));

            return false;
        }

        return true;
    }

    /**
     * Repère de tentative : un succès repousse la suivante de 24 h, un échec la
     * ramène dans une heure. Le déclencheur par requête a déjà posé une
     * réservation ; c'est ce fichier qui dit la vérité finale.
     */
    private function markAttempt(string $directory, bool $success): void
    {
        $interval = (int) config('backup.interval', 86400);
        $stamp = $success ? time() : time() - $interval + 3600;

        @touch($directory.'/'.DailyBackup::MARKER, $stamp);
    }

    /** Chemin absolu : la tâche planifiée n'hérite pas toujours du PATH du shell. */
    private function binary(string $name): string
    {
        return (new ExecutableFinder)->find($name) ?? $name;
    }

    private function humanSize(string $path): string
    {
        $bytes = @filesize($path);
        if ($bytes === false) {
            return 'taille inconnue';
        }

        return $bytes >= 1048576
            ? sprintf('%.1f Mo', $bytes / 1048576)
            : sprintf('%d Ko', max(1, (int) round($bytes / 1024)));
    }
}
