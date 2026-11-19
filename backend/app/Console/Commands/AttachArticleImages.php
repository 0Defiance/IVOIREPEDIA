<?php

namespace App\Console\Commands;

use App\Models\Article;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

/**
 * Attache à chaque article son illustration sourcée.
 *
 * Le jeu de données (`database/data/article-images.php`) a été constitué à
 * partir de Wikimedia Commons : image de tête de l'article Wikipédia quand
 * elle existe, sinon photographie du sujet. Chaque entrée porte l'URL, le
 * texte alternatif, l'auteur, la licence et la page de description, que
 * l'application affiche sous l'image.
 *
 * La commande est idempotente et non destructive : elle ne réécrit un article
 * que si l'un des champs d'illustration a changé, et elle ne remplace jamais
 * une image choisie à la main depuis `/admin` — `--force` le fait
 * explicitement, quand le jeu de données a une meilleure photo à proposer.
 */
class AttachArticleImages extends Command
{
    protected $signature = 'articles:attach-images
                            {--dry-run : afficher les changements sans les enregistrer}
                            {--force : remplacer aussi les images choisies à la main}';

    protected $description = 'Attache les illustrations sourcées de Wikimedia Commons aux articles';

    public function handle(): int
    {
        $path = database_path('data/article-images.php');

        if (! File::exists($path)) {
            $this->error("Fichier d'illustrations absent : {$path}");

            return self::FAILURE;
        }

        /** @var array<string, array<string, string>> $images */
        $images = require $path;
        $dryRun = (bool) $this->option('dry-run');
        $force = (bool) $this->option('force');
        $updated = 0;
        $unchanged = 0;
        $missing = [];
        $incomplete = [];
        $edited = [];

        foreach ($images as $slug => $image) {
            $article = Article::query()->where('slug', $slug)->first();

            if ($article === null) {
                $missing[] = $slug;

                continue;
            }

            if (! $this->isComplete($image)) {
                $incomplete[] = $slug;

                continue;
            }

            // Une autre image que celle du jeu de données : choix éditorial.
            if (! $force && $article->cover_image_url !== null && $article->cover_image_url !== $image['url']) {
                $edited[] = $slug;

                continue;
            }

            $article->cover_image_url = $image['url'];
            $article->cover_image_alt = $image['alt'];
            $article->cover_image_credit = $image['credit'];
            $article->cover_image_license = $image['license'];
            $article->cover_image_source_url = $image['page'];

            if (! $article->isDirty()) {
                $unchanged++;

                continue;
            }

            $updated++;

            if (! $dryRun) {
                $article->save();
            }

            $this->line(sprintf(
                '%s %s : %s (%s)',
                $dryRun ? '· ' : '✓ ',
                $slug,
                $image['license'],
                $image['credit'],
            ));
        }

        if ($missing !== []) {
            $this->warn('Articles absents de la base : '.implode(', ', $missing));
        }

        if ($incomplete !== []) {
            $this->warn('Illustrations incomplètes : '.implode(', ', $incomplete));
        }

        if ($edited !== []) {
            $this->warn('Images choisies à la main, conservées : '.implode(', ', $edited).' (utilisez --force pour reprendre le jeu de données).');
        }

        $this->newLine();
        $this->info(sprintf(
            '%d article(s) illustré(s), %d déjà à jour%s.',
            $updated,
            $unchanged,
            $dryRun ? ' (simulation)' : '',
        ));

        return $incomplete === [] ? self::SUCCESS : self::FAILURE;
    }

    /** @param  array<string, string>  $image */
    private function isComplete(array $image): bool
    {
        foreach (['url', 'alt', 'credit', 'license', 'page'] as $key) {
            if (($image[$key] ?? '') === '') {
                return false;
            }
        }

        return true;
    }
}
