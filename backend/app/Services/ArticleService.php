<?php

namespace App\Services;

use App\Enums\ArticleStatus;
use App\Enums\EditorialActionType;
use App\Exceptions\WorkflowException;
use App\Models\Article;
use App\Models\ArticleVersion;
use App\Models\EditorialAction;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Transitions d'article : la seule porte d'écriture du statut.
 *
 * `Workflow` dit ce qui est permis (classe pure) ; ce service l'exécute dans
 * une transaction, verrouille la ligne, écrit la version du jalon et le
 * journal éditorial. Aucun contrôleur ne doit écrire `articles.status` :
 * c'est la condition pour que `editorial_actions` reste complet.
 */
final class ArticleService
{
    /**
     * Applique une action du workflow et renvoie l'article à jour.
     *
     * @throws WorkflowException refus du workflow ou garde de publication
     */
    public function transition(
        Article $article,
        string $action,
        User $actor,
        ?string $comment = null,
    ): Article {
        return DB::transaction(function () use ($article, $action, $actor, $comment): Article {
            /** @var Article $fresh */
            $fresh = Article::query()->lockForUpdate()->findOrFail($article->getKey());

            $from = $fresh->status;

            $to = Workflow::assertTransition([
                'action' => $action,
                'actorRole' => $actor->role,
                'actorId' => (string) $actor->getKey(),
                'authorId' => (string) $fresh->author_id,
                'status' => $from,
                'comment' => $comment,
                'allowSelfReview' => (bool) config('ivoirepedia.allow_self_review', true),
            ]);

            if ($to === ArticleStatus::PUBLISHED && $from !== ArticleStatus::PUBLISHED) {
                $this->assertPublishable($fresh);
            }

            $fresh->status = $to;

            if ($to === ArticleStatus::PUBLISHED && $fresh->published_at === null) {
                $fresh->published_at = now();
            }

            if ($to === ArticleStatus::DELETED) {
                $fresh->deleted_at = now();
            }

            $fresh->lock_version = (int) $fresh->lock_version + 1;
            $fresh->save();

            // ADR-005 : un jalon (soumission, publication) crée une version ;
            // une sauvegarde automatique, non.
            if (in_array($action, ['submit', 'publish'], true)) {
                $this->snapshot($fresh, $actor, Workflow::label($action));
            }

            EditorialAction::create([
                'article_id' => $fresh->getKey(),
                'actor_id' => $actor->getKey(),
                'type' => EditorialActionType::forAction($action),
                'from_status' => $from,
                'to_status' => $to,
                'comment' => $comment !== null && trim($comment) !== '' ? trim($comment) : null,
            ]);

            return $fresh->refresh();
        });
    }

    /**
     * Garde de publication : on ne publie pas un article sans source, ni une
     * image sans texte alternatif (ENF-UX-04).
     *
     * @throws WorkflowException
     */
    public function assertPublishable(Article $article): void
    {
        if (trim((string) $article->title) === '' || trim((string) $article->summary) === '') {
            throw new WorkflowException(
                'INCOMPLETE',
                'Renseignez le titre et le résumé avant de publier.',
            );
        }

        if ($article->references()->count() === 0) {
            throw new WorkflowException(
                'SOURCES_REQUIRED',
                'Un article publié doit citer au moins une source.',
            );
        }

        if ($article->cover_image_url !== null && trim((string) $article->cover_image_alt) === '') {
            throw new WorkflowException(
                'ALT_REQUIRED',
                "L'image de couverture doit avoir un texte alternatif.",
            );
        }
    }

    /** Enregistre une version du jalon et avance le compteur courant. */
    private function snapshot(Article $article, User $actor, string $reason): void
    {
        $content = $article->content;

        $number = (int) $article->current_version + 1;

        ArticleVersion::create([
            'article_id' => $article->getKey(),
            'number' => $number,
            'title' => $article->title,
            'summary' => $article->summary,
            'content' => $content,
            'content_hash' => ArticleVersion::hashContent($content),
            'author_id' => $actor->getKey(),
            'reason' => $reason,
        ]);

        $article->current_version = $number;
        $article->save();
    }
}
