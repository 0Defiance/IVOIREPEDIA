<?php

namespace App\Http\Controllers\Admin;

use App\Enums\EditorialActionType;
use App\Http\Controllers\Controller;
use App\Models\EditorialAction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * Journal éditorial — lecture seule, table append-only.
 *
 * Un contributeur ne voit que les actions de ses propres articles ; un éditeur
 * voit toute la rédaction et peut filtrer par acteur. Aucun bouton de
 * modification : l'histoire ne se réécrit pas.
 */
class JournalController extends Controller
{
    public function __invoke(Request $request): View
    {
        /** @var User $user */
        $user = $request->user();

        $type = EditorialActionType::tryFrom((string) $request->query('type', ''));
        $articleId = trim((string) $request->query('article', ''));
        $actorId = trim((string) $request->query('acteur', ''));
        $canReview = $user->role->canReview();

        $actions = EditorialAction::query()
            ->with(['actor', 'article'])
            ->when(
                ! $canReview,
                fn ($query) => $query->whereHas(
                    'article',
                    fn ($inner) => $inner->where('author_id', $user->getKey()),
                ),
            )
            ->when($type !== null, fn ($query) => $query->where('type', $type))
            ->when($articleId !== '', fn ($query) => $query->where('article_id', $articleId))
            ->when($canReview && $actorId !== '', fn ($query) => $query->where('actor_id', $actorId))
            ->latest('created_at')
            ->paginate(30)
            ->withQueryString();

        return view('admin.journal', [
            'actions' => $actions,
            'type' => $type,
            'articleId' => $articleId,
            'actorId' => $actorId,
            'types' => EditorialActionType::cases(),
            'actors' => $canReview
                ? User::query()->orderBy('name')->get(['id', 'name'])
                : collect(),
        ]);
    }
}
