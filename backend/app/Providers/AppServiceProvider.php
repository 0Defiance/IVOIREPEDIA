<?php

namespace App\Providers;

use App\Models\User;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Référentiels éditoriaux (catégories, étiquettes) : ils changent les
        // adresses publiques, donc ils suivent le droit de relecture — EDITOR
        // et ADMIN (DASHBOARD_ADMIN §3).
        Gate::define('manage-references', fn (User $user): bool => $user->role->canReview());
    }
}
