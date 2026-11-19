<?php

namespace App\Services;

use App\Enums\ArticleStatus;
use App\Enums\UserRole;
use App\Exceptions\WorkflowException;

/**
 * Machine à états du workflow éditorial — classe pure, aucun accès BDD.
 *
 * Les règles sont celles de CONTEXT §9.2, sans exception : la table des
 * transitions est la source de vérité, et toute évolution commence ici.
 */
final class Workflow
{
    /**
     * Table des transitions (§9.2).
     *
     * `authorOnly` : seul l'auteur peut agir.
     * `notAuthor`   : l'auteur ne peut pas agir sur son propre article.
     * `commentRequired` : un commentaire non vide est obligatoire.
     *
     * @var array<string, array{from: list<ArticleStatus>, to: ArticleStatus, roles: list<UserRole>}>
     */
    public const RULES = [
        'submit' => [
            'from' => [ArticleStatus::DRAFT, ArticleStatus::REVISION_REQUESTED],
            'to' => ArticleStatus::SUBMITTED,
            'roles' => [UserRole::CONTRIBUTOR, UserRole::EDITOR, UserRole::ADMIN],
            'authorOnly' => true,
        ],
        'start_review' => [
            'from' => [ArticleStatus::SUBMITTED],
            'to' => ArticleStatus::IN_REVIEW,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
            'notAuthor' => true,
        ],
        'request_revision' => [
            'from' => [ArticleStatus::IN_REVIEW],
            'to' => ArticleStatus::REVISION_REQUESTED,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
            'commentRequired' => true,
        ],
        'approve' => [
            'from' => [ArticleStatus::IN_REVIEW],
            'to' => ArticleStatus::APPROVED,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
        ],
        'publish' => [
            'from' => [ArticleStatus::APPROVED],
            'to' => ArticleStatus::PUBLISHED,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
        ],
        'archive' => [
            'from' => [ArticleStatus::PUBLISHED],
            'to' => ArticleStatus::ARCHIVED,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
        ],
        'restore' => [
            'from' => [ArticleStatus::ARCHIVED],
            'to' => ArticleStatus::PUBLISHED,
            'roles' => [UserRole::EDITOR, UserRole::ADMIN],
        ],
        'delete' => [
            'from' => [
                ArticleStatus::DRAFT, ArticleStatus::SUBMITTED, ArticleStatus::IN_REVIEW,
                ArticleStatus::REVISION_REQUESTED, ArticleStatus::APPROVED,
                ArticleStatus::PUBLISHED, ArticleStatus::ARCHIVED,
            ],
            'to' => ArticleStatus::DELETED,
            'roles' => [UserRole::ADMIN],
        ],
    ];

    /**
     * Règle typée d'une action — la table des transitions reste la source de
     * vérité, cette lecture donne simplement un type exploitable à PHPStan.
     *
     * @return array{from: list<ArticleStatus>, to: ArticleStatus, roles: list<UserRole>, authorOnly?: bool, notAuthor?: bool, commentRequired?: bool}
     */
    private static function rule(string $action): array
    {
        return self::RULES[$action];
    }

    /** Une action existe-t-elle dans la table ? */
    public static function has(string $action): bool
    {
        return array_key_exists($action, self::RULES);
    }

    /**
     * Vérifie une transition et renvoie le statut d'arrivée.
     *
     * @param  array{
     *     action: string,
     *     actorRole: UserRole,
     *     actorId: string,
     *     authorId: string,
     *     status: ArticleStatus,
     *     comment?: string|null,
     *     allowSelfReview?: bool
     * }  $args
     *
     * @throws WorkflowException FORBIDDEN | INVALID_TRANSITION | COMMENT_REQUIRED
     */
    public static function assertTransition(array $args): ArticleStatus
    {
        if (! self::has($args['action'])) {
            throw new WorkflowException(
                'INVALID_TRANSITION',
                "Action inconnue : « {$args['action']} ».",
            );
        }

        $rule = self::rule($args['action']);

        if (! in_array($args['actorRole'], $rule['roles'], true)) {
            throw new WorkflowException('FORBIDDEN', 'Votre rôle ne permet pas cette action.');
        }

        if (! in_array($args['status'], $rule['from'], true)) {
            throw new WorkflowException(
                'INVALID_TRANSITION',
                sprintf(
                    'Impossible de faire « %s » depuis le statut « %s ».',
                    $args['action'],
                    $args['status']->value,
                ),
            );
        }

        if (($rule['authorOnly'] ?? false) && $args['actorId'] !== $args['authorId']) {
            throw new WorkflowException('FORBIDDEN', "Seul l'auteur peut effectuer cette action.");
        }

        if (($rule['notAuthor'] ?? false)
            && $args['actorId'] === $args['authorId']
            && ! ($args['allowSelfReview'] ?? false)) {
            throw new WorkflowException('FORBIDDEN', 'Vous ne pouvez pas réviser votre propre article.');
        }

        if (($rule['commentRequired'] ?? false) && trim((string) ($args['comment'] ?? '')) === '') {
            throw new WorkflowException('COMMENT_REQUIRED', 'Un commentaire est obligatoire.');
        }

        return $rule['to'];
    }

    /**
     * Actions proposées à un rôle depuis un statut donné.
     *
     * Sert à construire les boutons du panneau : l'affichage suit la règle,
     * il ne la remplace pas — chaque action est revérifiée à l'exécution.
     *
     * @return list<string>
     */
    public static function actionsFor(ArticleStatus $status, UserRole $role): array
    {
        $actions = [];

        foreach (self::RULES as $action => $rule) {
            if (in_array($role, $rule['roles'], true) && in_array($status, $rule['from'], true)) {
                $actions[] = $action;
            }
        }

        return $actions;
    }

    /** Sièges d'une action, pour les messages et les tests. */
    public static function label(string $action): string
    {
        return match ($action) {
            'submit' => 'Soumettre à la relecture',
            'start_review' => 'Prendre en relecture',
            'request_revision' => 'Demander une révision',
            'approve' => 'Approuver',
            'publish' => 'Publier',
            'archive' => 'Archiver',
            'restore' => 'Restaurer',
            'delete' => 'Supprimer',
            default => $action,
        };
    }
}
