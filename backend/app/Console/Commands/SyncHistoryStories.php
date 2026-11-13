<?php

namespace App\Console\Commands;

use App\Models\HistoryStory;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

/**
 * Importe les récits de la section « Histoire incroyable ».
 *
 * Idempotent : le slug identifie le récit, une nouvelle exécution met à jour le
 * texte sans créer de doublon. Comme les autres jeux de données du projet, le
 * contenu vit dans `database/data/` et reste versionné avec sa source.
 */
class SyncHistoryStories extends Command
{
    protected $signature = 'history:sync-stories';

    protected $description = "Importe les récits d'histoire sourcés";

    public function handle(): int
    {
        $path = database_path('data/history-stories.php');

        if (! File::exists($path)) {
            $this->error("Fichier des récits absent : {$path}");

            return self::FAILURE;
        }

        /** @var array<int, array<string, mixed>> $stories */
        $stories = require $path;

        foreach ($stories as $position => $story) {
            HistoryStory::query()->updateOrCreate(
                ['slug' => $story['slug']],
                [
                    'title' => $story['title'],
                    'period' => $story['period'] ?? null,
                    'year' => $story['year'] ?? null,
                    'teaser' => $story['teaser'],
                    'paragraphs' => $story['paragraphs'],
                    'figures' => $story['figures'] ?? null,
                    'source_title' => $story['source_title'],
                    'source_publisher' => $story['source_publisher'] ?? null,
                    'source_year' => $story['source_year'] ?? null,
                    'source_url' => $story['source_url'],
                    'position' => $position,
                ],
            );
        }

        $this->info(sprintf('%d récits importés.', HistoryStory::query()->count()));

        return self::SUCCESS;
    }
}
