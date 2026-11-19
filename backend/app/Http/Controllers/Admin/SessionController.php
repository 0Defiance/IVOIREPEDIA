<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\LoginRequest;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

/**
 * Session du panneau éditorial.
 *
 * Authentification par cookie de session, distincte des jetons porteurs de
 * l'API : le panneau est un outil de bureau, protégé par CSRF, qui ne doit
 * jamais dépendre du stockage du navigateur d'un lecteur.
 */
class SessionController extends Controller
{
    public function create(): View
    {
        return view('admin.auth.login');
    }

    /**
     * @throws ValidationException
     */
    public function store(LoginRequest $request): RedirectResponse
    {
        $credentials = $request->validated();
        $key = 'admin-login:'.mb_strtolower((string) $credentials['email']);

        if (RateLimiter::tooManyAttempts($key, 5)) {
            throw ValidationException::withMessages([
                'email' => 'Trop de tentatives. Réessayez dans une minute.',
            ]);
        }

        $user = User::query()->where('email', $credentials['email'])->first();

        if ($user !== null && $user->isSuspended()) {
            throw ValidationException::withMessages([
                'email' => 'Ce compte est suspendu. Écrivez à l’administrateur.',
            ]);
        }

        if (! Auth::attempt(['email' => $credentials['email'], 'password' => $credentials['password']])) {
            RateLimiter::hit($key, 60);

            // Message identique pour une adresse inconnue et un mot de passe
            // faux : on n'indique pas quels comptes existent.
            throw ValidationException::withMessages([
                'email' => 'Adresse ou mot de passe incorrect.',
            ]);
        }

        RateLimiter::clear($key);
        $request->session()->regenerate();

        /** @var User $authenticated */
        $authenticated = Auth::user();

        if (! $authenticated->role->canContribute()) {
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            throw ValidationException::withMessages([
                'email' => 'Ce panneau est réservé à l’équipe éditoriale.',
            ]);
        }

        return redirect()->intended(route('admin.dashboard'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')->with('status', 'Vous êtes déconnecté.');
    }
}
