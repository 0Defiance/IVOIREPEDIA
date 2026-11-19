<?php

namespace App\Policies;

use App\Enums\ArticleStatus;
use App\Enums\UserRole;
use App\Exceptions\WorkflowException;
use App\Models\Article;
use App\Models\User;
use App\Services\Workflow;

/**
 * Droits sur les articles — CONTEXT §9.2 et §10.
 *
 * Les policies doublent volontairement la machine à états : elles décident de
 * ce qu'un écran montre, `Workflow` reste seul juge de ce qui s'exécute.
 */
class ArticlePolicy
{
    /** Le panneau éditorial est ouvert aux contributeurs et au-dessus. */
    public function viewAny(User $user): bool
    {
        return $user->role->canContribute();
    }

    /** Un brouillon n'est visible que par son auteur, les éditeurs et les admins. */
    public function view(User $user, Article $article): bool
    {
        return $user->role->canReview() || $article->author_id === $user->getKey();
    }

    public function create(User $user): bool
    {
        return $user->role->canContribute();
    }

    /**
     * Édition du contenu, par statut (§9.2).
     *
     * DRAFT et REVISION_REQUESTED : l'auteur ; IN_REVIEW : éditeur et admin
     * (corrections mineures tracées) ; SUBMITTED : personne ; PUBLISHED et
     * au-delà : éditeur et admin.
     */
    public function update(User $user, Article $article): bool
    {
        if ($article->status === ArticleStatus::SUBMITTED) {
            return false;
        }

        if ($user->role->canReview()) {
            return true;
        }

        return $article->author_id === $user->getKey()
            && in_array($article->status, [ArticleStatus::DRAFT, ArticleStatus::REVISION_REQUESTED], true);
    }

    /** Suppression douce : ADMIN seulement. */
    public function delete(User $user, Article $article): bool
    {
        return $user->role === UserRole::ADMIN;
    }

    /** Une action précise est-elle permise à cet utilisateur ? */
    public function transition(User $user, Article $article, string $action): bool
    {
        try {
            Workflow::assertTransition([
                'action' => $action,
                'actorRole' => $user->role,
                'actorId' => (string) $user->getKey(),
                'authorId' => (string) $article->author_id,
                'status' => $article->status,
                'comment' => 'policy',
                'allowSelfReview' => (bool) config('ivoirepedia.allow_self_review', true),
            ]);

            return true;
        } catch (WorkflowException) {
            return false;
        }
    }
}
