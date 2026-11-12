<?php

namespace App\Console\Commands;

use App\Models\Article;
use App\Models\ArticleReference;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

/**
 * Applique les compléments sourcés aux articles existants.
 *
 * Deux opérations, idempotentes :
 *  - renseigne les clés d'infobox manquantes (population communale du RGPH) ;
 *  - ajoute les références absentes, sans toucher aux références éditoriales
 *    déjà présentes ni dupliquer celles qui existent.
 *
 * La référence historique pointant vers `ins.ci` est remplacée : le document
 * officiel du RGPH 2021 est désormais publié et c'est lui qui fait foi.
 */
class EnrichArticles extends Command
{
    protected $signature = 'articles:enrich-sources
                            {--dry-run : afficher les changements sans les enregistrer}';

    protected $description = 'Complète les infobox et les références des articles depuis les sources vérifiées';

    private const SUPERSEDED_URL = 'https://www.ins.ci';

    public function handle(): int
    {
        $path = database_path('data/article-enrichment.php');

        if (! File::exists($path)) {
            $this->error("Fichier d'enrichissement absent : {$path}");

            return self::FAILURE;
        }

        /** @var array<string, array<string, mixed>> $data */
        $data = require $path;
        $dryRun = (bool) $this->option('dry-run');
        $articles = 0;
        $references = 0;
        $infoboxes = 0;
        $missing = [];

        foreach ($data as $slug => $enrichment) {
            $article = Article::query()->where('slug', $slug)->first();

            if ($article === null) {
                $missing[] = $slug;

                continue;
            }

            $articles++;

            $infobox = $article->infobox ?? [];
            $changed = false;

            foreach ((array) ($enrichment['infobox'] ?? []) as $key => $value) {
                if (($infobox[$key] ?? null) !== $value) {
                    $infobox[$key] = $value;
                    $changed = true;
                }
            }

            if ($changed) {
                $infoboxes++;

                if (! $dryRun) {
                    $article->infobox = $infobox;
                    $article->save();
                }
            }

            $added = $this->syncReferences($article, (array) ($enrichment['references'] ?? []), $dryRun);
            $references += $added;

            $this->line(sprintf(
                '%s %s : %s, %d référence(s) ajoutée(s)',
                $dryRun ? '· ' : '✓ ',
                $slug,
                $changed ? 'infobox complétée' : 'infobox inchangée',
                $added,
            ));
        }

        if ($missing !== []) {
            $this->warn('Articles absents de la base : '.implode(', ', $missing));
        }

        $this->newLine();
        $this->info(sprintf(
            '%d article(s) examiné(s), %d infobox complétée(s), %d référence(s) ajoutée(s)%s.',
            $articles,
            $infoboxes,
            $references,
            $dryRun ? ' (simulation)' : '',
        ));

        return self::SUCCESS;
    }

    /**
     * @param  array<int, array<string, mixed>>  $references
     */
    private function syncReferences(Article $article, array $references, bool $dryRun): int
    {
        // La référence « ins.ci » est remplacée par le document officiel publié.
        if (! $dryRun) {
            ArticleReference::query()
                ->where('article_id', $article->id)
                ->where('url', self::SUPERSEDED_URL)
                ->delete();
        }

        $existing = ArticleReference::query()
            ->where('article_id', $article->id)
            ->get()
            ->keyBy(fn (ArticleReference $reference): string => $reference->url ?? 'title:'.$reference->title);

        $position = (int) ArticleReference::query()
            ->where('article_id', $article->id)
            ->max('position');

        $added = 0;

        foreach ($references as $reference) {
            $key = $reference['url'] ?? 'title:'.$reference['title'];

            if ($existing->has($key)) {
                continue;
            }

            $added++;
            $position++;

            if ($dryRun) {
                continue;
            }

            ArticleReference::query()->create([
                'article_id' => $article->id,
                'position' => $position,
                'kind' => $reference['kind'] ?? 'OTHER',
                'authors' => $reference['authors'] ?? null,
                'title' => $reference['title'],
                'publisher' => $reference['publisher'] ?? null,
                'year' => $reference['year'] ?? null,
                'url' => $reference['url'] ?? null,
                'accessed_at' => now()->toDateString(),
                'note' => $reference['note'] ?? null,
            ]);
        }

        return $added;
    }
}
