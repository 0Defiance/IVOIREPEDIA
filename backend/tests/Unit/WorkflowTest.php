<?php

use App\Enums\ArticleStatus;
use App\Enums\UserRole;
use App\Exceptions\WorkflowException;
use App\Services\Workflow;

/**
 * Machine à états du workflow — CONTEXT §9.2.
 *
 * Un test par ligne du tableau des transitions, puis les cas d'échec :
 * rôle insuffisant, statut de départ interdit, auteur obligatoire, auteur
 * interdit, commentaire manquant.
 */
function workflowArgs(array $overrides = []): array
{
    return array_merge([
        'action' => 'submit',
        'actorRole' => UserRole::CONTRIBUTOR,
        'actorId' => 'auteur-1',
        'authorId' => 'auteur-1',
        'status' => ArticleStatus::DRAFT,
        'comment' => null,
        'allowSelfReview' => false,
    ], $overrides);
}

it('soumet un brouillon ou une révision demandée', function () {
    expect(Workflow::assertTransition(workflowArgs()))->toBe(ArticleStatus::SUBMITTED)
        ->and(Workflow::assertTransition(workflowArgs([
            'status' => ArticleStatus::REVISION_REQUESTED,
        ])))->toBe(ArticleStatus::SUBMITTED);
});

it('refuse une soumission par un lecteur', function () {
    Workflow::assertTransition(workflowArgs(['actorRole' => UserRole::READER]));
})->throws(WorkflowException::class, 'Votre rôle ne permet pas cette action.');

it('refuse la soumission de l’article d’un autre', function () {
    Workflow::assertTransition(workflowArgs(['actorId' => 'autre-auteur']));
})->throws(WorkflowException::class, "Seul l'auteur peut effectuer cette action.");

it('refuse une soumission depuis un statut qui ne le permet pas', function () {
    Workflow::assertTransition(workflowArgs(['status' => ArticleStatus::PUBLISHED]));
})->throws(WorkflowException::class, 'Impossible de faire « submit »');

it('ouvre la relecture à un éditeur', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'start_review',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::SUBMITTED,
    ])))->toBe(ArticleStatus::IN_REVIEW);
});

it('refuse la relecture de son propre article, sauf autorisation explicite', function () {
    $args = workflowArgs([
        'action' => 'start_review',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'auteur-1',
        'status' => ArticleStatus::SUBMITTED,
    ]);

    Workflow::assertTransition($args);
})->throws(WorkflowException::class, 'Vous ne pouvez pas réviser votre propre article.');

it('autorise la relecture de son propre article quand la phase solo l’ouvre', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'start_review',
        'actorRole' => UserRole::ADMIN,
        'status' => ArticleStatus::SUBMITTED,
        'allowSelfReview' => true,
    ])))->toBe(ArticleStatus::IN_REVIEW);
});

it('refuse la relecture à un contributeur', function () {
    Workflow::assertTransition(workflowArgs([
        'action' => 'start_review',
        'status' => ArticleStatus::SUBMITTED,
        'actorId' => 'autre',
    ]));
})->throws(WorkflowException::class, 'Votre rôle ne permet pas cette action.');

it('exige un commentaire pour demander une révision', function () {
    Workflow::assertTransition(workflowArgs([
        'action' => 'request_revision',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::IN_REVIEW,
        'comment' => '   ',
    ]));
})->throws(WorkflowException::class, 'Un commentaire est obligatoire.');

it('demande une révision avec son commentaire', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'request_revision',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::IN_REVIEW,
        'comment' => 'Ajoutez la source du recensement.',
    ])))->toBe(ArticleStatus::REVISION_REQUESTED);
});

it('approuve un article en relecture', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'approve',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::IN_REVIEW,
    ])))->toBe(ArticleStatus::APPROVED);
});

it('publie un article approuvé', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'publish',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::APPROVED,
    ])))->toBe(ArticleStatus::PUBLISHED);
});

it('archive un article publié et le restaure', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'archive',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::PUBLISHED,
    ])))->toBe(ArticleStatus::ARCHIVED)
        ->and(Workflow::assertTransition(workflowArgs([
            'action' => 'restore',
            'actorRole' => UserRole::EDITOR,
            'actorId' => 'editeur-1',
            'status' => ArticleStatus::ARCHIVED,
        ])))->toBe(ArticleStatus::PUBLISHED);
});

it('réserve la suppression à l’administrateur', function () {
    expect(Workflow::assertTransition(workflowArgs([
        'action' => 'delete',
        'actorRole' => UserRole::ADMIN,
        'actorId' => 'admin-1',
        'status' => ArticleStatus::PUBLISHED,
    ])))->toBe(ArticleStatus::DELETED);

    Workflow::assertTransition(workflowArgs([
        'action' => 'delete',
        'actorRole' => UserRole::EDITOR,
        'actorId' => 'editeur-1',
        'status' => ArticleStatus::PUBLISHED,
    ]));
})->throws(WorkflowException::class, 'Votre rôle ne permet pas cette action.');

it('refuse une action inconnue', function () {
    Workflow::assertTransition(workflowArgs(['action' => 'publier-nimporte-quoi']));
})->throws(WorkflowException::class, 'Action inconnue');

it('liste les actions ouvertes à chaque rôle', function () {
    expect(Workflow::actionsFor(ArticleStatus::DRAFT, UserRole::CONTRIBUTOR))->toBe(['submit'])
        ->and(Workflow::actionsFor(ArticleStatus::DRAFT, UserRole::READER))->toBe([])
        ->and(Workflow::actionsFor(ArticleStatus::SUBMITTED, UserRole::EDITOR))->toBe(['start_review'])
        ->and(Workflow::actionsFor(ArticleStatus::IN_REVIEW, UserRole::EDITOR))
        ->toBe(['request_revision', 'approve'])
        ->and(Workflow::actionsFor(ArticleStatus::PUBLISHED, UserRole::ADMIN))
        ->toBe(['archive', 'delete']);
});

it('donne un statut final à chaque action connue', function () {
    foreach (Workflow::RULES as $action => $rule) {
        expect($rule['to'])->toBeInstanceOf(ArticleStatus::class);
        expect(Workflow::label($action))->not->toBe('');
    }
});
