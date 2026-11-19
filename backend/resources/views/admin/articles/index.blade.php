@extends('admin.layout')

@use('App\Enums\ArticleStatus')

@section('title', 'Articles')
@section('eyebrow', 'Contenu')
@section('lead', 'Tous les articles que vous pouvez voir : un contributeur ne voit que les siens, un éditeur voit toute la rédaction.')

@section('actions')
    <a class="btn primary" href="{{ route('admin.articles.create') }}">Écrire un article</a>
@endsection

@section('content')
    <div class="toolbar">
        <form method="get" action="{{ route('admin.articles.index') }}">
            <input type="text" name="q" value="{{ $search }}" placeholder="Rechercher un titre…" aria-label="Rechercher un titre">
            <select name="statut" aria-label="Filtrer par statut">
                <option value="">Tous les statuts</option>
                @foreach (ArticleStatus::cases() as $case)
                    <option value="{{ $case->value }}" @selected($status === $case)>{{ $case->label() }}</option>
                @endforeach
            </select>
            <select name="categorie" aria-label="Filtrer par catégorie">
                <option value="">Toutes les catégories</option>
                @foreach ($categories as $category)
                    <option value="{{ $category->id }}" @selected($categoryId === $category->id)>{{ $category->name }}</option>
                @endforeach
            </select>
            @if ($authors->isNotEmpty())
                <select name="auteur" aria-label="Filtrer par auteur">
                    <option value="">Toute la rédaction</option>
                    @foreach ($authors as $author)
                        <option value="{{ $author->id }}" @selected($authorId === $author->id)>{{ $author->name }}</option>
                    @endforeach
                </select>
            @endif
            <label class="check">
                <input type="checkbox" name="sans_source" value="1" @checked($missingSource)> Sans source
            </label>
            <label class="check">
                <input type="checkbox" name="sans_image" value="1" @checked($missingImage)> Sans image
            </label>
            <button class="btn ghost small" type="submit">Filtrer</button>
        </form>
        <span class="meta">{{ $articles->total() }} article{{ $articles->total() > 1 ? 's' : '' }}</span>
    </div>

    <div class="card">
        @if ($articles->isEmpty())
            <div class="empty">
                <strong>Aucun article</strong>
                Aucun article ne correspond à ce filtre.
            </div>
        @else
            <table class="table">
                <thead>
                <tr>
                    <th>Article</th>
                    <th>Statut</th>
                    <th>Catégorie</th>
                    <th>Auteur</th>
                    <th>Sources</th>
                    <th>Image</th>
                    <th>Modifié</th>
                </tr>
                </thead>
                <tbody>
                @foreach ($articles as $article)
                    <tr>
                        <td>
                            <a class="t" href="{{ route('admin.articles.show', $article) }}">{{ $article->title }}</a>
                            <div class="meta">{{ $article->summary }}</div>
                        </td>
                        <td><span class="pill {{ $article->status->tone() }}">{{ $article->status->label() }}</span></td>
                        <td class="meta">{{ $article->category?->name ?? '—' }}</td>
                        <td class="meta">{{ $article->author?->name ?? '—' }}</td>
                        <td class="meta">{{ $article->references_count }}</td>
                        <td class="meta">{{ $article->cover_image_url !== null ? 'oui' : '—' }}</td>
                        <td class="meta">{{ $article->updated_at?->diffForHumans(short: true) }}</td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @if ($articles->hasPages())
        <div class="pager">
            <nav>
                @if ($articles->onFirstPage())
                    <span>Précédent</span>
                @else
                    <a href="{{ $articles->previousPageUrl() }}">Précédent</a>
                @endif
                <span class="current">{{ $articles->currentPage() }} / {{ $articles->lastPage() }}</span>
                @if ($articles->hasMorePages())
                    <a href="{{ $articles->nextPageUrl() }}">Suivant</a>
                @else
                    <span>Suivant</span>
                @endif
            </nav>
        </div>
    @endif
@endsection
