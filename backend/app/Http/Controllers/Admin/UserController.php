<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

/**
 * Comptes du panneau — ADMIN seulement.
 *
 * La suspension coupe aussi les jetons porteurs déjà émis : sans cela, une
 * application resterait connectée jusqu'à l'expiration du jeton (60 jours).
 */
class UserController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('viewAny', User::class);

        $search = trim((string) $request->query('q', ''));

        $users = User::query()
            ->withCount('articles')
            ->when($search !== '', fn ($query) => $query->where(
                fn ($inner) => $inner->where('name', 'like', '%'.$search.'%')
                    ->orWhere('email', 'like', '%'.$search.'%'),
            ))
            ->orderByRaw("FIELD(role, 'ADMIN', 'EDITOR', 'CONTRIBUTOR', 'READER')")
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.users.index', [
            'users' => $users,
            'search' => $search,
            'roles' => UserRole::assignable(),
        ]);
    }

    public function updateRole(Request $request, User $user): RedirectResponse
    {
        Gate::authorize('changeRole', $user);

        $data = $request->validate([
            'role' => ['required', Rule::enum(UserRole::class)],
        ]);

        $role = UserRole::from((string) $data['role']);

        if ($role === $user->role) {
            return back()->with('status', 'Le rôle est inchangé.');
        }

        $user->update(['role' => $role]);

        return back()->with('status', "{$user->name} est désormais {$role->label()}.");
    }

    public function suspend(User $user): RedirectResponse
    {
        Gate::authorize('suspend', $user);

        $user->update(['suspended_at' => now()]);

        // Les jetons déjà émis tombent immédiatement avec le compte.
        $user->apiTokens()->delete();

        return back()->with('status', "{$user->name} est suspendu.");
    }

    public function reinstate(User $user): RedirectResponse
    {
        Gate::authorize('reinstate', $user);

        $user->update(['suspended_at' => null]);

        return back()->with('status', "{$user->name} peut de nouveau se connecter.");
    }
}
