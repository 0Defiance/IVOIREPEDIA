<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CategoryRequest;
use App\Models\Category;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Illuminate\View\View;

/**
 * Référentiel des catégories — CONTEXT §10 : gérer catégories et étiquettes
 * suit le droit de relecture (EDITOR et ADMIN).
 *
 * Une catégorie utilisée garde son slug : renommer changerait les adresses
 * publiques (`/categories/{slug}`), donc les liens déjà partagés.
 */
class CategoryController extends Controller
{
    public function index(): View
    {
        Gate::authorize('manage-references');

        $categories = Category::query()
            ->withCount('articles')
            ->with('parent')
            ->orderBy('position')
            ->orderBy('name')
            ->get();

        return view('admin.categories.index', [
            'categories' => $categories,
        ]);
    }

    public function store(CategoryRequest $request): RedirectResponse
    {
        Gate::authorize('manage-references');

        $category = new Category($request->attributes());
        $category->slug = $this->uniqueSlug((string) $request->input('name'));
        $category->save();

        return back()->with('status', "La catégorie « {$category->name} » est créée.");
    }

    public function update(CategoryRequest $request, Category $category): RedirectResponse
    {
        Gate::authorize('manage-references');

        $category->fill($request->attributes());

        // Tant qu'aucun article ne s'y rattache, le slug suit le nom.
        if (! $category->articles()->exists()) {
            $category->slug = $this->uniqueSlug((string) $request->input('name'), $category->getKey());
        }

        $category->save();

        return back()->with('status', "La catégorie « {$category->name} » est enregistrée.");
    }

    public function destroy(Category $category): RedirectResponse
    {
        Gate::authorize('manage-references');

        if ($category->articles()->exists()) {
            return back()->with(
                'error',
                'Cette catégorie porte des articles : déplacez-les avant de la supprimer.',
            );
        }

        $category->delete();

        return back()->with('status', 'Catégorie supprimée.');
    }

    /** Slug lisible et unique, dérivé du nom. */
    private function uniqueSlug(string $name, ?string $ignoreId = null): string
    {
        $base = Str::slug($name) ?: 'categorie';
        $slug = $base;
        $suffix = 1;

        while (Category::query()
            ->where('slug', $slug)
            ->when($ignoreId !== null, fn ($query) => $query->whereKeyNot($ignoreId))
            ->exists()) {
            $slug = $base.'-'.(++$suffix);
        }

        return $slug;
    }
}
