<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\TagRequest;
use App\Models\Tag;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Illuminate\View\View;

/**
 * Référentiel des étiquettes.
 *
 * Une étiquette n'a pas d'adresse publique propre : son slug peut donc suivre
 * le nom sans casser de lien, la lecture publique filtre par pivot.
 */
class TagController extends Controller
{
    public function index(): View
    {
        Gate::authorize('manage-references');

        $tags = Tag::query()
            ->withCount('articles')
            ->orderBy('name')
            ->get();

        return view('admin.tags.index', [
            'tags' => $tags,
        ]);
    }

    public function store(TagRequest $request): RedirectResponse
    {
        Gate::authorize('manage-references');

        $tag = new Tag(['name' => trim((string) $request->input('name'))]);
        $tag->slug = $this->uniqueSlug((string) $request->input('name'));
        $tag->save();

        return back()->with('status', "L’étiquette « {$tag->name} » est créée.");
    }

    public function update(TagRequest $request, Tag $tag): RedirectResponse
    {
        Gate::authorize('manage-references');

        $tag->name = trim((string) $request->input('name'));
        $tag->slug = $this->uniqueSlug($tag->name, $tag->getKey());
        $tag->save();

        return back()->with('status', 'Étiquette enregistrée.');
    }

    public function destroy(Tag $tag): RedirectResponse
    {
        Gate::authorize('manage-references');

        // Le pivot `article_tag` tombe avec l'étiquette (clé étrangère en
        // cascade) : aucun article n'est supprimé.
        $tag->delete();

        return back()->with('status', 'Étiquette supprimée.');
    }

    /** Slug lisible et unique, dérivé du nom. */
    private function uniqueSlug(string $name, ?string $ignoreId = null): string
    {
        $base = Str::slug($name) ?: 'etiquette';
        $slug = $base;
        $suffix = 1;

        while (Tag::query()
            ->where('slug', $slug)
            ->when($ignoreId !== null, fn ($query) => $query->whereKeyNot($ignoreId))
            ->exists()) {
            $slug = $base.'-'.(++$suffix);
        }

        return $slug;
    }
}
