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
