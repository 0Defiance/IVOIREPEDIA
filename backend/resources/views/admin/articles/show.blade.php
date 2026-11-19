@extends('admin.layout')

@section('eyebrow', 'Article')
@section('title', $article->title)
@section('lead', $article->summary)

@section('actions')
    <div class="actions">
        @can('update', $article)
            <a class="btn ghost" href="{{ route('admin.articles.edit', $article) }}">Modifier</a>
        @endcan
        @if ($article->status->isPublic())
            <a class="btn ghost" target="_blank" rel="noopener"
               href="{{ config('ivoirepedia.site_url') }}/articles/{{ $article->slug }}">Voir sur le site</a>
        @endif
    </div>
@endsection

@section('content')
    <div class="cols">
        <div>
            <div class="card">
                <div class="article-head">
                    <div class="tags">
                        <span class="pill {{ $article->status->tone() }}">{{ $article->status->label() }}</span>
                        <span class="meta">{{ $article->category?->name }}</span>
                        <span class="meta">· {{ $article->type->label() }}</span>
                        <span class="meta">· version {{ $article->current_version }}</span>
                        @if ($article->published_at !== null)
                            <span class="meta">· publié le {{ $article->published_at->translatedFormat('j F Y') }}</span>
                        @endif
                    </div>
                    <div class="meta">
                        Par {{ $article->author?->name }} · modifié {{ $article->updated_at?->diffForHumans() }}
                    </div>
                </div>

                @if ($article->cover_image_url !== null)
                    <p class="meta">
                        Image de couverture : {{ $article->cover_image_alt ?: 'sans texte alternatif' }}
                        @if ($article->cover_image_credit)
                            · crédit {{ $article->cover_image_credit }}
                        @endif
                    </p>
                @endif

                <div class="prose">{{ $article->plainText() }}</div>

                @if (! empty($article->infobox))
                    <h2 style="margin-top:22px">Infobox</h2>
                    <ul class="refs">
                        @foreach ($article->infobox as $label => $value)
                            <li><strong>{{ $label }}</strong> : {{ is_scalar($value) ? $value : json_encode($value) }}</li>
                        @endforeach
                    </ul>
                @endif

                @if ($article->tags->isNotEmpty())
                    <div class="tags" style="margin-top:16px">
                        @foreach ($article->tags as $tag)
                            <span class="pill draft">{{ $tag->name }}</span>
                        @endforeach
                    </div>
                @endif
            </div>

            <div class="card">
                <h2>Sources ({{ $article->references->count() }})</h2>
                @if ($article->references->isEmpty())
                    <div class="empty">
                        <strong>Aucune source</strong>
                        Un article sans source ne peut pas être publié.
                    </div>
                @else
                    <ol class="refs">
                        @foreach ($article->references as $reference)
                            <li>
                                {{ $reference->authors ? $reference->authors.' — ' : '' }}{{ $reference->title }}
                                @if ($reference->publisher) · {{ $reference->publisher }} @endif
                                @if ($reference->year) ({{ $reference->year }}) @endif
                                @if ($reference->url)
                                    · <a href="{{ $reference->url }}" target="_blank" rel="noopener">source en ligne</a>
                                @endif
                            </li>
                        @endforeach
                    </ol>
                @endif
            </div>

            <div class="card">
                <h2>Versions</h2>

                @if ($previousVersion !== null)
                    <p class="meta">
                        Dernier jalon : version {{ $previousVersion->number }} ({{ $previousVersion->reason }}).
                        @if ($changes === [])
                            Le contenu est identique à celui de ce jalon.
                        @else
                            Modifié depuis : {{ implode(', ', $changes) }}.
                        @endif
                    </p>
                @endif

                @if ($article->versions->isEmpty())
                    <p class="meta">Aucun jalon enregistré : la première version naît à la soumission.</p>
                @else
                    <table class="table">
                        <thead>
                        <tr><th>N°</th><th>Jalon</th><th>Empreinte</th><th>Auteur</th><th>Date</th></tr>
                        </thead>
                        <tbody>
                        @foreach ($article->versions as $version)
                            <tr>
                                <td>{{ $version->number }}</td>
                                <td>{{ $version->reason }}</td>
                                <td class="meta" title="{{ $version->content_hash }}">{{ substr($version->content_hash, 0, 12) }}</td>
                                <td class="meta">{{ $version->author?->name }}</td>
                                <td class="meta">{{ $version->created_at?->translatedFormat('j M Y, H:i') }}</td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                @endif
            </div>
        </div>

        <div>
            <div class="card">
                <h2>Décision éditoriale</h2>

                @if ($actions === [])
                    <p class="meta">Aucune action ne vous est ouverte dans ce statut.</p>
                @else
                    <form method="post" action="{{ route('admin.articles.transition', $article) }}">
                        @csrf
                        <div class="form-row">
                            <label for="action">Action</label>
                            <select id="action" name="action">
                                @foreach ($actions as $action)
                                    <option value="{{ $action }}">{{ \App\Services\Workflow::label($action) }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="form-row">
                            <label for="comment">Commentaire</label>
                            <textarea id="comment" name="comment" class="comment-box"
                                      placeholder="Obligatoire pour demander une révision"></textarea>
                            <span class="hint">Ce commentaire est conservé dans le journal éditorial.</span>
                        </div>
                        <button class="btn primary" type="submit">Appliquer</button>
                    </form>
                @endif
            </div>

            <div class="card">
                <h2>Journal</h2>
                @if ($article->actions->isEmpty())
                    <p class="meta">Aucune action enregistrée.</p>
                @else
                    <ul class="activity">
                        @foreach ($article->actions as $action)
                            <li>
                                <div class="what">{{ $action->type->label() }}</div>
                                <div class="when">
                                    {{ $action->actor?->name }}
                                    · {{ $action->created_at?->diffForHumans(short: true) }}
                                    @if ($action->comment)
                                        <div>{{ $action->comment }}</div>
                                    @endif
                                </div>
                            </li>
                        @endforeach
                    </ul>
                @endif
            </div>
        </div>
    </div>
@endsection
