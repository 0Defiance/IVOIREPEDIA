@extends('admin.layout')

@use('App\Enums\EditorialActionType')

@section('title', 'Journal éditorial')
@section('eyebrow', 'Traçabilité')
@section('lead', 'Qui a fait quoi, dans l’ordre. Les lignes ne se modifient pas : une décision passée reste lisible telle qu’elle a été prise.')

@section('content')
    <div class="toolbar">
        <form method="get" action="{{ route('admin.journal') }}">
            <select name="type" aria-label="Filtrer par type d’action">
                <option value="">Toutes les actions</option>
                @foreach ($types as $case)
                    <option value="{{ $case->value }}" @selected($type === $case)>{{ $case->label() }}</option>
                @endforeach
            </select>

            @if ($actors->isNotEmpty())
                <select name="acteur" aria-label="Filtrer par auteur">
                    <option value="">Toute la rédaction</option>
                    @foreach ($actors as $actor)
                        <option value="{{ $actor->id }}" @selected($actorId === $actor->id)>{{ $actor->name }}</option>
                    @endforeach
                </select>
            @endif

            <button class="btn ghost small" type="submit">Filtrer</button>
            @if ($type !== null || $actorId !== '' || $articleId !== '')
                <a class="btn ghost small" href="{{ route('admin.journal') }}">Réinitialiser</a>
            @endif
        </form>
        <span class="meta">{{ $actions->total() }} action{{ $actions->total() > 1 ? 's' : '' }}</span>
    </div>

    <div class="card">
        @if ($actions->isEmpty())
            <div class="empty">
                <strong>Journal vide</strong>
                Aucune action ne correspond à ce filtre.
            </div>
        @else
            <table class="table">
                <thead>
                <tr>
                    <th>Action</th>
                    <th>Article</th>
                    <th>Passage</th>
                    <th>Acteur</th>
                    <th>Quand</th>
                </tr>
                </thead>
                <tbody>
                @foreach ($actions as $action)
                    <tr>
                        <td>
                            <span class="t">{{ $action->type->label() }}</span>
                            @if ($action->comment)
                                <div class="meta">{{ $action->comment }}</div>
                            @endif
                        </td>
                        <td>
                            @if ($action->article !== null)
                                <a class="t" href="{{ route('admin.articles.show', $action->article) }}">
                                    {{ $action->article->title }}
                                </a>
                            @else
                                <span class="meta">article supprimé</span>
                            @endif
                        </td>
                        <td class="meta">
                            {{ $action->from_status?->label() ?? '—' }}
                            → {{ $action->to_status?->label() ?? '—' }}
                        </td>
                        <td class="meta">{{ $action->actor?->name ?? '—' }}</td>
                        <td class="meta" title="{{ $action->created_at?->toDateTimeString() }}">
                            {{ $action->created_at?->diffForHumans(short: true) }}
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @if ($actions->hasPages())
        <div class="pager">
            <nav>
                @if ($actions->onFirstPage())
                    <span>Précédent</span>
                @else
                    <a href="{{ $actions->previousPageUrl() }}">Précédent</a>
                @endif
                <span class="current">{{ $actions->currentPage() }} / {{ $actions->lastPage() }}</span>
                @if ($actions->hasMorePages())
                    <a href="{{ $actions->nextPageUrl() }}">Suivant</a>
                @else
                    <span>Suivant</span>
                @endif
            </nav>
        </div>
    @endif
@endsection
