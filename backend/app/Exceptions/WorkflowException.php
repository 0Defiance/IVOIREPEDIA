<?php

namespace App\Exceptions;

use RuntimeException;

/**
 * Refus du workflow éditorial, déjà lisible par un humain.
 *
 * Le code (`FORBIDDEN`, `INVALID_TRANSITION`, `COMMENT_REQUIRED`,
 * `SOURCES_REQUIRED`, `ALT_REQUIRED`, `CONFLICT`) permet au panneau comme à
 * l'API de choisir le statut HTTP sans analyser le message.
 */
class WorkflowException extends RuntimeException
{
    public function __construct(
        public readonly string $errorCode,
        string $message,
    ) {
        parent::__construct($message);
    }

    /** Statut HTTP correspondant au refus. */
    public function status(): int
    {
        return match ($this->errorCode) {
            'FORBIDDEN' => 403,
            'INVALID_TRANSITION', 'COMMENT_REQUIRED', 'SOURCES_REQUIRED', 'ALT_REQUIRED', 'INCOMPLETE' => 422,
            'CONFLICT' => 409,
            default => 400,
        };
    }
}
