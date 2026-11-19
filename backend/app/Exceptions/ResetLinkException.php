<?php

namespace App\Exceptions;

use RuntimeException;

/**
 * Lien de réinitialisation inutilisable : jeton inconnu, déjà utilisé ou
 * expiré. Le message est volontairement le même dans les trois cas — un
 * visiteur n'a pas à savoir lequel s'applique.
 */
class ResetLinkException extends RuntimeException
{
    public function __construct()
    {
        parent::__construct(
            'Ce lien de réinitialisation n’est plus valable. Demandez-en un nouveau.',
        );
    }
}
