<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * `GET /api/v1/categories` — arbre des catégories, avec le nombre d'articles
 * publiés par nœud (CONTEXT §11.1). La gestion des catégories reste dans
 * Filament au Sprint 5 : aucune écriture ici.
 */
class CategoryController extends Controller
{
    /**
     * @return AnonymousResourceCollection<int, CategoryResource>
     */
    public function __invoke(): AnonymousResourceCollection
    {
        $roots = Category::query()
            ->whereNull('parent_id')
            ->withCount(['articles' => fn ($query) => $query->published()])
            ->with(['children' => fn ($query) => $query
                ->withCount(['articles' => fn ($inner) => $inner->published()])
                ->orderBy('position')])
            ->orderBy('position')
            ->get();

        return CategoryResource::collection($roots);
    }
}
