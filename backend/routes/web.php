<?php

use App\Http\Controllers\Admin\ArticleController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\SessionController;
use App\Http\Controllers\Admin\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Panneau éditorial — /admin
|--------------------------------------------------------------------------
|
| Session par cookie, distincte des jetons porteurs de l'API. Le middleware
| `editorial` ouvre le panneau aux CONTRIBUTOR et au-dessus ; les policies
| décident ensuite de chaque action.
|
*/

Route::redirect('/', '/admin');

Route::prefix('admin')->name('admin.')->group(function (): void {
    Route::middleware('guest')->group(function (): void {
        Route::get('/connexion', [SessionController::class, 'create'])->name('login');
        Route::post('/connexion', [SessionController::class, 'store'])->name('login.store');
    });

    Route::middleware(['auth', 'editorial'])->group(function (): void {
        Route::get('/', DashboardController::class)->name('dashboard');
        Route::post('/deconnexion', [SessionController::class, 'destroy'])->name('logout');

        Route::get('/articles', [ArticleController::class, 'index'])->name('articles.index');
        Route::get('/articles/nouveau', [ArticleController::class, 'create'])->name('articles.create');
        Route::post('/articles', [ArticleController::class, 'store'])->name('articles.store');
        Route::get('/articles/{article}', [ArticleController::class, 'show'])->name('articles.show');
        Route::get('/articles/{article}/modifier', [ArticleController::class, 'edit'])->name('articles.edit');
        Route::put('/articles/{article}', [ArticleController::class, 'update'])->name('articles.update');
        Route::post('/articles/{article}/transition', [ArticleController::class, 'transition'])
            ->name('articles.transition');

        Route::get('/utilisateurs', [UserController::class, 'index'])->name('users.index');
        Route::patch('/utilisateurs/{user}/role', [UserController::class, 'updateRole'])->name('users.role');
        Route::post('/utilisateurs/{user}/suspendre', [UserController::class, 'suspend'])->name('users.suspend');
        Route::post('/utilisateurs/{user}/reactiver', [UserController::class, 'reinstate'])->name('users.reinstate');
    });
});
