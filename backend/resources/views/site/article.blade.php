@extends('site.layout')

@section('title', $title.' — IVOIREPEDIA')
@section('description', $description)
@section('canonical', $canonical)

@section('social')
    @include('site.partials.social')
    @include('site.partials.json-ld')
@endsection

@section('content')
    <article class="article">
        <p class="kicker">
            @if ($article->category)
                {{ $article->category->name }} · 
            @endif
            {{ $article->type->label() }}
        </p>

        <h1>{{ $article->title }}</h1>

        <p class="summary">{{ $article->summary }}</p>

        <p class="meta">
            @if ($article->published_at)
                Publié le {{ $article->published_at->format('d/m/Y') }} ·
            @endif
            {{ $article->readingMinutes() }} min de lecture
            @if ($article->author)
                · {{ $article->author->name }}
            @endif
        </p>

        @if ($coverUrl)
            <figure>
                <img src="{{ $coverUrl }}" alt="{{ $article->cover_image_alt ?? $article->title }}">
                @if ($article->cover_image_credit || $article->cover_image_license || $article->cover_image_source_url)
                    <figcaption>
                        @if ($article->cover_image_credit)
                            Image : {{ $article->cover_image_credit }}
                        @endif
                        @if ($article->cover_image_license)
                            · {{ $article->cover_image_license }}
                        @endif
                        @if ($article->cover_image_source_url)
                            · <a href="{{ $article->cover_image_source_url }}" rel="noopener noreferrer nofollow">source</a>
                        @endif
                    </figcaption>
                @endif
            </figure>
        @endif

        @if (count($sections) > 1)
            <nav class="toc" aria-label="Sommaire">
                <p>Sommaire</p>
                <ol>
                    @foreach ($sections as $section)
                        <li><a href="#{{ $section['anchor'] }}">{{ $section['title'] }}</a></li>
                    @endforeach
                </ol>
            </nav>
        @endif

        <div class="prose">
            {!! $content !!}
        </div>

        @if ($article->references->isNotEmpty())
            <section class="references" aria-labelledby="references-title">
                <h2 id="references-title">Notes et références</h2>
                <ol>
                    @foreach ($article->references as $reference)
                        <li id="reference-{{ $reference->position }}">
                            <span class="ref-number">[{{ $reference->position }}]</span>
                            @if ($reference->authors)
                                <strong>{{ $reference->authors }}</strong>,
                            @endif
                            {{ $reference->title }}
                            @if ($reference->publisher)
                                , {{ $reference->publisher }}
                            @endif
                            @if ($reference->year)
                                , {{ $reference->year }}
                            @endif
                            @if ($reference->url)
                                — <a href="{{ $reference->url }}" rel="noopener noreferrer nofollow">{{ $reference->url }}</a>
                            @endif
                        </li>
                    @endforeach
                </ol>
            </section>
        @endif

        @php($labels = collect([$article->category?->name])->merge($article->tags->pluck('name'))->filter()->unique())
        @if ($labels->isNotEmpty())
            <p class="tags">
                Catégories :
                @foreach ($labels as $label)
                    <span>{{ $label }}</span>
                @endforeach
            </p>
        @endif

        <p class="license">
            Texte disponible sous licence
            <a href="https://creativecommons.org/licenses/by-sa/4.0/deed.fr" rel="license noopener">CC BY-SA 4.0</a>.
            Les règles éditoriales sont décrites dans la
            <a href="{{ $siteUrl }}/charte">charte</a>.
        </p>
    </article>
@endsection
