<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ArticleStatus;
use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\EditorialAction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

/**
 * Accueil du panneau : ce sur quoi l'équipe doit agir aujourd'hui.
 *
 * Quatre blocs seulement — la file de relecture, les brouillons de la
 * personne connectée, les défauts de qualité des articles publiés et les
 * dernières actions. Un tableau de bord qui liste tout ne sert à rien.
 */
class DashboardController extends Controller
{
    public function __invoke(Request $request): View
    {
        /** @var User $user */
        $user = $request->user();

        $counts = [];

        foreach (ArticleStatus::cases() as $status) {
            $counts[$status->value] = Article::query()->where('status', $status)->count();
        }

        // La file de relecture ne concerne que les rôles qui peuvent trancher :
        // un contributeur n'a pas à voir les articles des autres.
        $queue = $user->role->canReview()
            ? Article::query()
                ->with(['author', 'category'])
                ->whereIn('status', [ArticleStatus::SUBMITTED, ArticleStatus::IN_REVIEW])
                ->oldest('updated_at')
                ->limit(10)
                ->get()
            : collect();

        $drafts = Article::query()
            ->with('category')
            ->where('author_id', $user->getKey())
            ->whereIn('status', [ArticleStatus::DRAFT, ArticleStatus::REVISION_REQUESTED])
            ->latest('updated_at')
            ->limit(5)
            ->get();

        $published = Article::query()->where('status', ArticleStatus::PUBLISHED);

        // SQLite compte les caractères avec LENGTH, MySQL avec CHAR_LENGTH :
        // la même métrique doit fonctionner en test et en production.
        $length = DB::connection()->getDriverName() === 'sqlite' ? 'LENGTH' : 'CHAR_LENGTH';

        $quality = [
            'sans source' => (clone $published)->whereDoesntHave('references')->count(),
            'sans image' => (clone $published)->whereNull('cover_image_url')->count(),
            'sans texte alternatif' => (clone $published)
                ->whereNotNull('cover_image_url')
                ->where(fn ($query) => $query->whereNull('cover_image_alt')->orWhere('cover_image_alt', ''))
                ->count(),
            'résumé trop court' => (clone $published)->whereRaw($length.'(summary) < 80')->count(),
        ];

        $activity = EditorialAction::query()
            ->with(['actor', 'article'])
            ->latest('created_at')
            ->limit(8)
            ->get();

        return view('admin.dashboard', [
            'counts' => $counts,
            'queue' => $queue,
            'drafts' => $drafts,
            'quality' => $quality,
            'activity' => $activity,
            'totalPublished' => (clone $published)->count(),
        ]);
    }
}
