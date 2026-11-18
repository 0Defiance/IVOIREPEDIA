<?php

namespace App\Http\Middleware;

use App\Models\ApiToken;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

/**
 * Authentifie une requête d'API par en-tête `Authorization: Bearer …`.
 *
 * L'utilisateur résolu est posé sur la requête et dans le garde `Auth`, ce qui
 * permet aux contrôleurs d'appeler `$request->user()` comme avec n'importe
 * quel autre mécanisme d'authentification Laravel.
 */
class AuthenticateApiToken
{
    /**
     * @param  Closure(Request): Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $plain = $request->bearerToken();

        if ($plain === null || $plain === '') {
            return $this->unauthorized();
        }

        $token = ApiToken::findValid($plain);

        if ($token === null || $token->user === null) {
            return $this->unauthorized();
        }

        if ($token->user->suspended_at !== null) {
            return response()->json([
                'error' => [
                    'code' => 'ACCOUNT_SUSPENDED',
                    'message' => 'Ce compte est suspendu. Écrivez à la rédaction.',
                ],
            ], 403);
        }

        $token->forceFill(['last_used_at' => now()])->save();

        Auth::setUser($token->user);
        $request->setUserResolver(fn () => $token->user);
        $request->attributes->set('api_token', $token);

        return $next($request);
    }

    private function unauthorized(): Response
    {
        return response()->json([
            'error' => [
                'code' => 'UNAUTHENTICATED',
                'message' => 'Connectez-vous pour accéder à cet espace.',
            ],
        ], 401);
    }
}
