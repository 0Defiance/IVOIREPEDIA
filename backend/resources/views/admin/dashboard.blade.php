@extends('admin.layout')

@use('App\Enums\ArticleStatus')

@section('title', 'Tableau de bord')
@section('eyebrow', 'Rédaction')
@section('lead', 'Ce qui demande une décision aujourd’hui : la file de relecture, vos brouillons, et les articles publiés qui manquent encore de quelque chose.')

@section('actions')
    <a class="btn primary" href="{{ route('admin.articles.create') }}">Écrire un article</a>
@endsection

@section('content')
    <div class="stats">
        <div class="stat">
            <div class="n">{{ $counts[ArticleStatus::DRAFT->value] }}</div>
            <div class="k">Brouillons</div>
        </div>
        <div class="stat hl">
            <div class="n">{{ $counts[ArticleStatus::SUBMITTED->value] + $counts[ArticleStatus::IN_REVIEW->value] }}</div>
            <div class="k">En relecture</div>
        </div>
        <div class="stat">
            <div class="n">{{ $counts[ArticleStatus::REVISION_REQUESTED->value] }}</div>
            <div class="k">Révisions demandées</div>
        </div>
        <div class="stat">
            <div class="n">{{ $counts[ArticleStatus::APPROVED->value] }}</div>
            <div class="k">Approuvés</div>
        </div>
        <div class="stat">
            <div class="n">{{ $totalPublished }}</div>
            <div class="k">Publiés</div>
        </div>
    </div>

    <div class="cols">
        <div>
            @if (auth()->user()->role->canReview())
            <div class="card">
                <h2>File de relecture</h2>
                @if ($queue->isEmpty())
                    <div class="empty">
                        <strong>Rien à relire</strong>
                        Aucun article n’attend de décision.
                    </div>
                @else
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Article</th>
                            <th>Statut</th>
                            <th>Auteur</th>
                            <th>Attente</th>
                        </tr>
                        </thead>
                        <tbody>
                        @foreach ($queue as $article)
                            <tr>
                                <td>
                                    <a class="t" href="{{ route('admin.articles.show', $article) }}">{{ $article->title }}</a>
                                    <div class="meta">{{ $article->category?->name }}</div>
                                </td>
                                <td>
                                    <span class="pill {{ $article->status->tone() }}">{{ $article->status->label() }}</span>
                                </td>
                                <td class="meta">{{ $article->author?->name }}</td>
                                <td class="meta">
                                    {{ $article->updated_at?->diffForHumans(short: true) }}
                                    @if ($article->updated_at !== null && $article->updated_at->lt(now()->subDays(7)))
                                        <div class="error">plus de 7 jours</div>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                @endif
            </div>
            @endif

            <div class="card">
                <h2>Mes brouillons</h2>
                @if ($drafts->isEmpty())
                    <div class="empty">
                        <strong>Aucun brouillon</strong>
                        Commencez un article quand vous voulez.
                    </div>
                @else
                    <table class="table">
                        <tbody>
                        @foreach ($drafts as $article)
                            <tr>
                                <td>
                                    <a class="t" href="{{ route('admin.articles.show', $article) }}">{{ $article->title }}</a>
                                    <div class="meta">{{ $article->category?->name }}</div>
                                </td>
                                <td><span class="pill {{ $article->status->tone() }}">{{ $article->status->label() }}</span></td>
                                <td class="meta">{{ $article->updated_at?->diffForHumans(short: true) }}</td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                @endif
            </div>
        </div>

        <div>
            <div class="card">
                <h2>Qualité des articles publiés</h2>
                <ul class="quality">
                    @foreach ($quality as $label => $total)
                        <li class="{{ $total === 0 ? 'good' : 'bad' }}">
                            <span>{{ $label }}</span>
                            <span class="n">{{ $total }}</span>
                        </li>
                    @endforeach
                </ul>
                <p class="meta" style="margin:10px 0 0">
                    Un article sans source ne devrait pas rester publié : chaque fait doit pouvoir être vérifié.
                </p>
            </div>

            <div class="card">
                <h2>Dernières actions</h2>
                @if ($activity->isEmpty())
                    <div class="empty">
                        <strong>Journal vide</strong>
                        Les transitions apparaîtront ici.
                    </div>
                @else
                    <ul class="activity">
                        @foreach ($activity as $action)
                            <li>
                                <div class="what">
                                    {{ $action->type->label() }}
                                    — {{ $action->article?->title ?? 'article supprimé' }}
                                </div>
                                <div class="when">
                                    {{ $action->actor?->name }} · {{ $action->created_at?->diffForHumans(short: true) }}
                                </div>
                            </li>
                        @endforeach
                    </ul>
                @endif
            </div>
        </div>
    </div>
@endsection
