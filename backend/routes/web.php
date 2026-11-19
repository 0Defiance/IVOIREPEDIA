<?php

use App\Http\Controllers\Admin\ArticleController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\JournalController;
use App\Http\Controllers\Admin\MessageController;
use App\Http\Controllers\Admin\SessionController;
use App\Http\Controllers\Admin\TagController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Site\ArticlePageController;
use App\Http\Controllers\Site\SitemapController;
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

/*
|--------------------------------------------------------------------------
| Pages publiques pré-rendues
|--------------------------------------------------------------------------
|
| Apache envoie ces deux adresses à Laravel (voir public/.htaccess) : le
| HTML et le XML contiennent le contenu réel, ce que la coquille Flutter ne
| peut pas offrir aux moteurs de recherche ni aux cartes de partage.
|
*/

Route::get('/articles/{slug}', ArticlePageController::class)->name('site.article');
Route::get('/sitemap.xml', SitemapController::class)->name('site.sitemap');

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

        Route::get('/journal', JournalController::class)->name('journal');

        // Messages du formulaire de contact public.
        Route::get('/messages', [MessageController::class, 'index'])->name('messages.index');
        Route::post('/messages/{contactMessage}/traiter', [MessageController::class, 'handle'])
            ->name('messages.handle');

        Route::get('/categories', [CategoryController::class, 'index'])->name('categories.index');
        Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');
        Route::put('/categories/{category}', [CategoryController::class, 'update'])->name('categories.update');
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy'])->name('categories.destroy');

        Route::get('/etiquettes', [TagController::class, 'index'])->name('tags.index');
        Route::post('/etiquettes', [TagController::class, 'store'])->name('tags.store');
        Route::put('/etiquettes/{tag}', [TagController::class, 'update'])->name('tags.update');
        Route::delete('/etiquettes/{tag}', [TagController::class, 'destroy'])->name('tags.destroy');

        Route::get('/utilisateurs', [UserController::class, 'index'])->name('users.index');
        Route::patch('/utilisateurs/{user}/role', [UserController::class, 'updateRole'])->name('users.role');
        Route::post('/utilisateurs/{user}/suspendre', [UserController::class, 'suspend'])->name('users.suspend');
        Route::post('/utilisateurs/{user}/reactiver', [UserController::class, 'reinstate'])->name('users.reinstate');
    });
});
