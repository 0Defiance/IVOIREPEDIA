@extends('admin.layout')

@use('App\Enums\ArticleType')

@php
    $editing = $article->exists;
@endphp

@section('eyebrow', $editing ? 'Modifier' : 'Nouvel article')
@section('title', $editing ? $article->title : 'Écrire un article')

@section('actions')
    @if ($editing)
        <a class="btn ghost" href="{{ route('admin.articles.show', $article) }}">Retour à la fiche</a>
    @endif
@endsection

@section('content')
    <form method="post"
          action="{{ $editing ? route('admin.articles.update', $article) : route('admin.articles.store') }}">
        @csrf
        @if ($editing)
            @method('put')
        @endif

        <div class="card">
            <div class="form-row">
                <label for="title">Titre</label>
                <input id="title" name="title" type="text" value="{{ old('title', $article->title) }}" required maxlength="255">
            </div>

            <div class="form-row">
                <label for="summary">Résumé</label>
                <textarea id="summary" name="summary" style="min-height:96px;font-family:inherit;font-size:14px"
                          required maxlength="500" placeholder="Deux phrases qui disent de quoi parle l’article.">{{ old('summary', $article->summary) }}</textarea>
                <span class="hint">Il sert de chapô sur le site et de description pour les moteurs de recherche.</span>
            </div>

            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="category_id">Catégorie</label>
                    <select id="category_id" name="category_id" required>
                        @foreach ($categories as $category)
                            <option value="{{ $category->id }}"
                                @selected(old('category_id', $article->category_id) === $category->id)>
                                {{ $category->name }}
                            </option>
                        @endforeach
                    </select>
                </div>
                <div class="form-row" style="margin:0">
                    <label for="type">Type</label>
                    <select id="type" name="type" required>
                        @foreach (ArticleType::cases() as $type)
                            <option value="{{ $type->value }}"
                                @selected(old('type', $article->type?->value) === $type->value)>
                                {{ $type->label() }}
                            </option>
                        @endforeach
                    </select>
                </div>
            </div>

            <div class="form-row" style="margin-top:16px">
                <label for="body">Corps de l’article</label>
                <textarea id="body" name="body" required>{{ old('body', $article->plainText()) }}</textarea>
                <span class="hint">
                    Un paragraphe par bloc, séparés par une ligne vide. Une ligne commençant par « ## » devient un titre de section.
                </span>
            </div>
        </div>

        <div class="card">
            <h2>Image de couverture</h2>
            <div class="form-row">
                <label for="cover_image_url">Adresse de l’image</label>
                <input id="cover_image_url" name="cover_image_url" type="url"
                       value="{{ old('cover_image_url', $article->cover_image_url) }}" placeholder="https://…">
            </div>
            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="cover_image_alt">Texte alternatif</label>
                    <input id="cover_image_alt" name="cover_image_alt" type="text"
                           value="{{ old('cover_image_alt', $article->cover_image_alt) }}"
                           placeholder="Décrire l’image pour qui ne la voit pas">
                </div>
                <div class="form-row" style="margin:0">
                    <label for="cover_image_credit">Crédit</label>
                    <input id="cover_image_credit" name="cover_image_credit" type="text"
                           value="{{ old('cover_image_credit', $article->cover_image_credit) }}"
                           placeholder="Photographe, agence, licence">
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Première source</h2>
            <p class="meta" style="margin-top:-6px">Un article ne peut pas être publié sans au moins une source.</p>
            <div class="form-row">
                <label for="reference_title">Titre de la source</label>
                <input id="reference_title" name="reference_title" type="text"
                       value="{{ old('reference_title') }}" placeholder="Rapport, ouvrage, article de presse…">
            </div>
            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="reference_publisher">Éditeur ou institution</label>
                    <input id="reference_publisher" name="reference_publisher" type="text"
                           value="{{ old('reference_publisher') }}" placeholder="INS, UNESCO…">
                </div>
                <div class="form-row" style="margin:0">
                    <label for="reference_url">Adresse en ligne</label>
                    <input id="reference_url" name="reference_url" type="url"
                           value="{{ old('reference_url') }}" placeholder="https://…">
                </div>
            </div>
        </div>

        <div class="actions">
            <button class="btn primary" type="submit">{{ $editing ? 'Enregistrer' : 'Créer le brouillon' }}</button>
            <a class="btn ghost" href="{{ route('admin.articles.index') }}">Annuler</a>
        </div>
    </form>
@endsection
