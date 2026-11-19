<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ArticleStatus;
use App\Enums\ArticleType;
use App\Enums\EditorialActionType;
use App\Exceptions\WorkflowException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ArticleRequest;
use App\Http\Requests\Admin\TransitionRequest;
use App\Models\Article;
use App\Models\ArticleReference;
use App\Models\Category;
use App\Models\EditorialAction;
use App\Models\User;
use App\Services\ArticleService;
use App\Services\Workflow;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Illuminate\View\View;

/**
 * Articles du panneau éditorial.
 *
 * Les listes sont filtrées par rôle : un contributeur ne voit que ses
 * articles, un éditeur voit tout. Les transitions passent toutes par
 * `ArticleService` — aucun statut n'est écrit à la main ici.
 */
class ArticleController extends Controller
{
    public function index(Request $request): View
    {
        /** @var User $user */
        $user = $request->user();

        $status = ArticleStatus::tryFrom((string) $request->query('statut', ''));
        $search = trim((string) $request->query('q', ''));

        $articles = Article::query()
            ->with(['author', 'category'])
            ->when(! $user->role->canReview(), fn ($query) => $query->where('author_id', $user->getKey()))
            ->when($status !== null, fn ($query) => $query->where('status', $status))
            ->when($search !== '', fn ($query) => $query->where('title', 'like', '%'.$search.'%'))
            ->latest('updated_at')
            ->paginate(15)
            ->withQueryString();

        return view('admin.articles.index', [
            'articles' => $articles,
            'status' => $status,
            'search' => $search,
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', Article::class);

        return view('admin.articles.form', [
            'article' => new Article(['type' => ArticleType::TOPIC]),
            'categories' => $this->categories(),
        ]);
    }

    public function store(ArticleRequest $request): RedirectResponse
    {
        Gate::authorize('create', Article::class);

        /** @var User $user */
        $user = $request->user();

        $article = new Article([
            'title' => (string) $request->input('title'),
            'summary' => (string) $request->input('summary'),
            'content' => $request->content(),
            'type' => $request->input('type'),
            'status' => ArticleStatus::DRAFT,
            'category_id' => (string) $request->input('category_id'),
            'cover_image_url' => $request->input('cover_image_url') ?: null,
            'cover_image_alt' => $request->input('cover_image_alt') ?: null,
            'cover_image_credit' => $request->input('cover_image_credit') ?: null,
            'author_id' => $user->getKey(),
            'lock_version' => 0,
            'current_version' => 0,
        ]);

        $article->slug = $this->uniqueSlug((string) $request->input('title'));
        $article->save();

        $this->storeReference($article, $request);

        EditorialAction::create([
            'article_id' => $article->getKey(),
            'actor_id' => $user->getKey(),
            'type' => EditorialActionType::EDIT,
            'from_status' => ArticleStatus::DRAFT,
            'to_status' => ArticleStatus::DRAFT,
            'comment' => 'Création du brouillon',
        ]);

        return redirect()
            ->route('admin.articles.show', $article)
            ->with('status', 'Brouillon créé. Soumettez-le quand il est prêt.');
    }

    public function show(Article $article): View
    {
        Gate::authorize('view', $article);

        $article->load(['author', 'category', 'references', 'actions.actor', 'versions']);

        /** @var User $user */
        $user = request()->user();

        $actions = array_values(array_filter(
            Workflow::actionsFor($article->status, $user->role),
            fn (string $action): bool => Gate::allows('transition', [$article, $action]),
        ));

        return view('admin.articles.show', [
            'article' => $article,
            'actions' => $actions,
        ]);
    }

    public function edit(Article $article): View
    {
        Gate::authorize('update', $article);

        return view('admin.articles.form', [
            'article' => $article,
            'categories' => $this->categories(),
        ]);
    }

    public function update(ArticleRequest $request, Article $article): RedirectResponse
    {
        Gate::authorize('update', $article);

        /** @var User $user */
        $user = $request->user();

        $titleChanged = $article->title !== (string) $request->input('title');

        $article->fill([
            'title' => (string) $request->input('title'),
            'summary' => (string) $request->input('summary'),
            'content' => $request->content(),
            'type' => $request->input('type'),
            'category_id' => (string) $request->input('category_id'),
            'cover_image_url' => $request->input('cover_image_url') ?: null,
            'cover_image_alt' => $request->input('cover_image_alt') ?: null,
            'cover_image_credit' => $request->input('cover_image_credit') ?: null,
        ]);

        // Le slug reste stable une fois l'article sorti du brouillon : les
        // adresses publiées ne doivent pas changer dans le dos des lecteurs.
        if ($titleChanged && $article->status === ArticleStatus::DRAFT) {
            $article->slug = $this->uniqueSlug((string) $request->input('title'), $article->getKey());
        }

        $article->lock_version = (int) $article->lock_version + 1;
        $article->save();

        $this->storeReference($article, $request);

        EditorialAction::create([
            'article_id' => $article->getKey(),
            'actor_id' => $user->getKey(),
            'type' => EditorialActionType::EDIT,
            'from_status' => $article->status,
            'to_status' => $article->status,
            'comment' => 'Modification du contenu',
        ]);

        return redirect()
            ->route('admin.articles.show', $article)
            ->with('status', 'Article enregistré.');
    }

    /** Applique une action du workflow (soumettre, publier, archiver…). */
    public function transition(
        TransitionRequest $request,
        Article $article,
        ArticleService $service,
    ): RedirectResponse {
        $action = (string) $request->input('action');

        Gate::authorize('transition', [$article, $action]);

        try {
            $service->transition(
                $article,
                $action,
                $request->user(),
                $request->input('comment'),
            );
        } catch (WorkflowException $exception) {
            return back()
                ->withInput()
                ->with('error', $exception->getMessage());
        }

        return redirect()
            ->route('admin.articles.show', $article)
            ->with('status', Workflow::label($action).' : c’est fait.');
    }

    /** @return Collection<int, Category> */
    private function categories(): Collection
    {
        return Category::query()->orderBy('position')->orderBy('name')->get();
    }

    /** Slug lisible et unique, sans toucher à celui d'un article publié. */
    private function uniqueSlug(string $title, ?string $ignoreId = null): string
    {
        $base = Str::slug($title) ?: 'article';
        $slug = $base;
        $suffix = 1;

        while (Article::withTrashed()
            ->where('slug', $slug)
            ->when($ignoreId !== null, fn ($query) => $query->whereKeyNot($ignoreId))
            ->exists()) {
            $slug = $base.'-'.(++$suffix);
        }

        return $slug;
    }

    /** La première source saisie au formulaire devient la référence n° 1. */
    private function storeReference(Article $article, ArticleRequest $request): void
    {
        $title = trim((string) $request->input('reference_title'));

        if ($title === '') {
            return;
        }

        $existing = $article->references()->where('position', 1)->first();

        $attributes = [
            'title' => $title,
            'publisher' => $request->input('reference_publisher') ?: null,
            'url' => $request->input('reference_url') ?: null,
            'kind' => 'WEBSITE',
        ];

        if ($existing instanceof ArticleReference) {
            $existing->update($attributes);

            return;
        }

        ArticleReference::create($attributes + [
            'article_id' => $article->getKey(),
            'position' => 1,
        ]);
    }
}
