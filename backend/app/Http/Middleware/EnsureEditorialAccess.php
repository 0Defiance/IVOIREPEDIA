<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

/**
 * Réserve le panneau aux rôles éditoriaux (CONTRIBUTOR et au-dessus).
 *
 * Un lecteur connecté n'a rien à y faire : on lui répond explicitement, plutôt
 * que de le renvoyer au site comme si la page n'existait pas.
 */
class EnsureEditorialAccess
{
    /**
     * @param  Closure(Request): Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user instanceof User || ! $user->role->canContribute()) {
            if ($user instanceof User) {
                Auth::guard('web')->logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();
            }

            abort(403, "Ce panneau est réservé à l'équipe éditoriale.");
        }

        if ($user->isSuspended()) {
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            abort(403, 'Ce compte est suspendu.');
        }

        return $next($request);
    }
}
