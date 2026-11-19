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
use App\Models\ArticleVersion;
use App\Models\Category;
use App\Models\EditorialAction;
use App\Models\Tag;
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
        $categoryId = trim((string) $request->query('categorie', ''));
        $authorId = trim((string) $request->query('auteur', ''));
        $missingSource = $request->query('sans_source') === '1';
        $missingImage = $request->query('sans_image') === '1';

        $articles = Article::query()
            ->with(['author', 'category'])
            ->withCount('references')
            ->when(! $user->role->canReview(), fn ($query) => $query->where('author_id', $user->getKey()))
            ->when($status !== null, fn ($query) => $query->where('status', $status))
            ->when($search !== '', fn ($query) => $query->where('title', 'like', '%'.$search.'%'))
            ->when($categoryId !== '', fn ($query) => $query->where('category_id', $categoryId))
            ->when(
                $user->role->canReview() && $authorId !== '',
                fn ($query) => $query->where('author_id', $authorId),
            )
            ->when($missingSource, fn ($query) => $query->whereDoesntHave('references'))
            ->when($missingImage, fn ($query) => $query->whereNull('cover_image_url'))
            ->latest('updated_at')
            ->paginate(15)
            ->withQueryString();

        return view('admin.articles.index', [
            'articles' => $articles,
            'status' => $status,
            'search' => $search,
            'categories' => $this->categories(),
            'categoryId' => $categoryId,
            'authors' => $user->role->canReview()
                ? User::query()->whereIn('role', ['CONTRIBUTOR', 'EDITOR', 'ADMIN'])->orderBy('name')->get(['id', 'name'])
                : collect(),
            'authorId' => $authorId,
            'missingSource' => $missingSource,
            'missingImage' => $missingImage,
        ]);
    }

    public function create(): View
    {
        Gate::authorize('create', Article::class);

        return view('admin.articles.form', [
            'article' => new Article(['type' => ArticleType::TOPIC]),
            'categories' => $this->categories(),
            'tags' => $this->tags(),
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
            'infobox' => $request->infobox(),
            'type' => $request->input('type'),
            'status' => ArticleStatus::DRAFT,
            'category_id' => (string) $request->input('category_id'),
            'cover_image_url' => $request->input('cover_image_url') ?: null,
            'cover_image_alt' => $request->input('cover_image_alt') ?: null,
            'cover_image_credit' => $request->input('cover_image_credit') ?: null,
            'cover_image_license' => $request->input('cover_image_license') ?: null,
            'cover_image_source_url' => $request->input('cover_image_source_url') ?: null,
            'author_id' => $user->getKey(),
            'lock_version' => 0,
            'current_version' => 0,
        ]);

        $article->slug = $this->uniqueSlug((string) $request->input('title'));
        $article->save();

        $this->syncReferences($article, $request);
        $this->syncTags($article, $request);

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

        $article->load(['author', 'category', 'references', 'actions.actor', 'versions.author', 'tags']);

        /** @var User $user */
        $user = request()->user();

        $actions = array_values(array_filter(
            Workflow::actionsFor($article->status, $user->role),
            fn (string $action): bool => Gate::allows('transition', [$article, $action]),
        ));

        // Le dernier jalon est comparé au contenu courant : l'auteur voit ce
        // qui n'a pas encore été relu, sans lire deux JSON côte à côte.
        $previous = $article->versions->last();
        $changes = [];

        if ($previous instanceof ArticleVersion) {
            if ($previous->title !== $article->title) {
                $changes[] = 'titre';
            }

            if ($previous->summary !== $article->summary) {
                $changes[] = 'résumé';
            }

            if ($previous->content_hash !== ArticleVersion::hashContent($article->content)) {
                $changes[] = 'corps';
            }
        }

        return view('admin.articles.show', [
            'article' => $article,
            'actions' => $actions,
            'previousVersion' => $previous,
            'changes' => $changes,
        ]);
    }

    public function edit(Article $article): View
    {
        Gate::authorize('update', $article);

        return view('admin.articles.form', [
            'article' => $article,
            'categories' => $this->categories(),
            'tags' => $this->tags(),
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
            'infobox' => $request->infobox(),
            'type' => $request->input('type'),
            'category_id' => (string) $request->input('category_id'),
            'cover_image_url' => $request->input('cover_image_url') ?: null,
            'cover_image_alt' => $request->input('cover_image_alt') ?: null,
            'cover_image_credit' => $request->input('cover_image_credit') ?: null,
            'cover_image_license' => $request->input('cover_image_license') ?: null,
            'cover_image_source_url' => $request->input('cover_image_source_url') ?: null,
        ]);

        // Le slug reste stable une fois l'article sorti du brouillon : les
        // adresses publiées ne doivent pas changer dans le dos des lecteurs.
        if ($titleChanged && $article->status === ArticleStatus::DRAFT) {
            $article->slug = $this->uniqueSlug((string) $request->input('title'), $article->getKey());
        }

        $article->lock_version = (int) $article->lock_version + 1;
        $article->save();

        $this->syncReferences($article, $request);
        $this->syncTags($article, $request);

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

    /** @return Collection<int, Tag> */
    private function tags(): Collection
    {
        return Tag::query()->orderBy('name')->get();
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

    /**
     * Les sources du formulaire remplacent les précédentes, dans l'ordre saisi.
     *
     * Un article sans source reste possible en brouillon (la garde de
     * publication le refuse plus tard), mais l'ordre du formulaire devient
     * l'ordre des appels `[1]`, `[2]`… dans la fiche publique.
     */
    private function syncReferences(Article $article, ArticleRequest $request): void
    {
        $article->references()->delete();

        foreach ($request->references() as $index => $reference) {
            ArticleReference::create($reference + [
                'article_id' => $article->getKey(),
                'position' => $index + 1,
                'kind' => 'WEBSITE',
            ]);
        }
    }

    /** Les étiquettes cochées remplacent les précédentes. */
    private function syncTags(Article $article, ArticleRequest $request): void
    {
        $article->tags()->sync($request->tagIds());
    }
}
