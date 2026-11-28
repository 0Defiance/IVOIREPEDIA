<?php

namespace App\Console\Commands;

use App\Support\OffsiteBackups;
use Illuminate\Console\Command;

/**
 * Envoie les sauvegardes sur un disque objet, hors de l'hébergeur.
 *
 * `backup:run` l'appelle à la fin de chaque sauvegarde réussie : une copie
 * hors-site n'a de valeur que si personne ne doit y penser. La commande reste
 * utilisable seule pour rattraper un envoi en retard.
 */
class BackupOffsite extends Command
{
    protected $signature = 'backup:offsite
                            {--dry-run : lister ce qui serait envoyé, sans rien envoyer}';

    protected $description = 'Copie les sauvegardes hors du serveur (disque objet S3) et applique la rétention distante';

    public function handle(): int
    {
        $offsite = OffsiteBackups::fromConfig();

        if ($offsite === null) {
            $this->error('Aucun disque hors-site configuré : renseigner BACKUP_OFFSITE_DISK (docs/DEPLOIEMENT.md §8.5).');

            return self::FAILURE;
        }

        if ($this->option('dry-run')) {
            foreach ($offsite->pending() as $path) {
                $this->line('offsite='.$offsite->keyFor($path));
            }

            return self::SUCCESS;
        }

        $result = $offsite->sync();

        foreach ($result['uploaded'] as $key) {
            $this->line("offsite={$key}");
        }

        foreach ($result['pruned'] as $key) {
            $this->line("pruned={$key}");
        }

        $this->info(count($result['uploaded']).' archive(s) envoyée(s), '.count($result['pruned']).' purgée(s).');

        return self::SUCCESS;
    }
}
