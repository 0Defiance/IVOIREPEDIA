@extends('admin.layout')

@use('App\Enums\ArticleType')

@php
    $editing = $article->exists;

    $referenceRows = old('references');
    if ($referenceRows === null) {
        $referenceRows = $editing
            ? $article->references->map(fn ($reference) => [
                'title' => $reference->title,
                'authors' => $reference->authors,
                'publisher' => $reference->publisher,
                'year' => $reference->year,
                'url' => $reference->url,
            ])->values()->all()
            : [];
    }
    if ($referenceRows === []) {
        $referenceRows = [['title' => '', 'authors' => '', 'publisher' => '', 'year' => '', 'url' => '']];
    }

    $infoboxRows = old('infobox');
    if ($infoboxRows === null) {
        $infoboxRows = collect($article->infobox ?? [])
            ->map(fn ($value, $label) => ['label' => (string) $label, 'value' => (string) $value])
            ->values()
            ->all();
    }
    if ($infoboxRows === []) {
        $infoboxRows = [['label' => '', 'value' => '']];
    }

    $chosenTags = array_map('strval', (array) old('tags', $editing ? $article->tags->pluck('id')->all() : []));
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
            <h2>L’essentiel</h2>

            <div class="form-row">
                <label for="title">Titre</label>
                <input id="title" name="title" type="text" value="{{ old('title', $article->title) }}" required maxlength="255">
                @if ($editing)
                    <span class="hint">Adresse : /articles/{{ $article->slug }}</span>
                @endif
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
        </div>

        <div class="card">
            <h2>Corps de l’article</h2>
            <div class="form-row">
                <label for="body">Texte</label>
                <textarea id="body" name="body" required>{{ old('body', $article->plainText()) }}</textarea>
                <span class="hint">
                    Un paragraphe par bloc, séparés par une ligne vide. Une ligne commençant par « ## » devient un titre de section.
                </span>
            </div>
        </div>

        <div class="card">
            <h2>Infobox</h2>
            <p class="meta" style="margin-top:-6px">
                Les repères chiffrés de la fiche : population, superficie, altitude… Un libellé et une valeur par ligne.
            </p>

            <div id="infobox-rows">
                @foreach ($infoboxRows as $index => $row)
                    <div class="pair-row">
                        <input type="text" name="infobox[{{ $index }}][label]" maxlength="60"
                               value="{{ $row['label'] ?? '' }}" placeholder="Population" aria-label="Libellé">
                        <input type="text" name="infobox[{{ $index }}][value]" maxlength="255"
                               value="{{ $row['value'] ?? '' }}" placeholder="8 200 000 habitants" aria-label="Valeur">
                        <button type="button" class="btn ghost small" data-remove-row>Retirer</button>
                    </div>
                @endforeach
            </div>

            <button type="button" class="btn ghost small" data-add-row="infobox">Ajouter une ligne</button>
        </div>

        <div class="card">
            <h2>Sources</h2>
            <p class="meta" style="margin-top:-6px">
                Un article ne peut pas être publié sans au moins une source. Elles sont numérotées dans l’ordre saisi.
            </p>

            <div id="references-rows">
                @foreach ($referenceRows as $index => $row)
                    <div class="ref-row">
                        <input type="text" name="references[{{ $index }}][title]" maxlength="255"
                               value="{{ $row['title'] ?? '' }}" placeholder="Titre de la source" aria-label="Titre de la source">
                        <input type="text" name="references[{{ $index }}][authors]" maxlength="255"
                               value="{{ $row['authors'] ?? '' }}" placeholder="Auteurs" aria-label="Auteurs">
                        <input type="text" name="references[{{ $index }}][publisher]" maxlength="255"
                               value="{{ $row['publisher'] ?? '' }}" placeholder="Éditeur ou institution" aria-label="Éditeur">
                        <input type="number" name="references[{{ $index }}][year]" min="1800" max="2100"
                               value="{{ $row['year'] ?? '' }}" placeholder="Année" aria-label="Année">
                        <div class="ref-url">
                            <input type="url" name="references[{{ $index }}][url]" maxlength="500"
                                   value="{{ $row['url'] ?? '' }}" placeholder="https://…" aria-label="Adresse en ligne">
                            <span class="hint">Une page précise, pas l’accueil d’un site.</span>
                        </div>
                        <button type="button" class="btn ghost small" data-remove-row>Retirer</button>
                    </div>
                @endforeach
            </div>

            <button type="button" class="btn ghost small" data-add-row="references">Ajouter une source</button>
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
                           placeholder="Photographe, agence">
                </div>
            </div>
            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="cover_image_license">Licence</label>
                    <input id="cover_image_license" name="cover_image_license" type="text"
                           value="{{ old('cover_image_license', $article->cover_image_license) }}"
                           placeholder="CC BY-SA 4.0, CC0, domaine public…">
                </div>
                <div class="form-row" style="margin:0">
                    <label for="cover_image_source_url">Page source de l’image</label>
                    <input id="cover_image_source_url" name="cover_image_source_url" type="url"
                           value="{{ old('cover_image_source_url', $article->cover_image_source_url) }}"
                           placeholder="https://commons.wikimedia.org/wiki/File:…">
                    <span class="hint">Une page précise, pas l’accueil d’un site.</span>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Étiquettes</h2>
            @if ($tags->isEmpty())
                <p class="meta">
                    Aucune étiquette n’existe encore.
                    <a href="{{ route('admin.tags.index') }}">Créez-en une</a> si l’article en a besoin.
                </p>
            @else
                @foreach ($tags as $tag)
                    <label class="check">
                        <input type="checkbox" name="tags[]" value="{{ $tag->id }}"
                               @checked(in_array($tag->id, $chosenTags, true))>
                        {{ $tag->name }}
                    </label>
                @endforeach
            @endif
        </div>

        <div class="actions">
            <button class="btn primary" type="submit">{{ $editing ? 'Enregistrer' : 'Créer le brouillon' }}</button>
            <a class="btn ghost" href="{{ route('admin.articles.index') }}">Annuler</a>
        </div>
    </form>

    <template id="infobox-template">
        <div class="pair-row">
            <input type="text" name="infobox[__INDEX__][label]" maxlength="60" placeholder="Libellé" aria-label="Libellé">
            <input type="text" name="infobox[__INDEX__][value]" maxlength="255" placeholder="Valeur" aria-label="Valeur">
            <button type="button" class="btn ghost small" data-remove-row>Retirer</button>
        </div>
    </template>

    <template id="references-template">
        <div class="ref-row">
            <input type="text" name="references[__INDEX__][title]" maxlength="255" placeholder="Titre de la source" aria-label="Titre de la source">
            <input type="text" name="references[__INDEX__][authors]" maxlength="255" placeholder="Auteurs" aria-label="Auteurs">
            <input type="text" name="references[__INDEX__][publisher]" maxlength="255" placeholder="Éditeur ou institution" aria-label="Éditeur">
            <input type="number" name="references[__INDEX__][year]" min="1800" max="2100" placeholder="Année" aria-label="Année">
            <div class="ref-url">
                <input type="url" name="references[__INDEX__][url]" maxlength="500" placeholder="https://…" aria-label="Adresse en ligne">
                <span class="hint">Une page précise, pas l’accueil d’un site.</span>
            </div>
            <button type="button" class="btn ghost small" data-remove-row>Retirer</button>
        </div>
    </template>
@endsection

@push('scripts')
    <script>
        (function () {
            var counters = {
                infobox: {{ count($infoboxRows) }},
                references: {{ count($referenceRows) }}
            };

            document.querySelectorAll('[data-add-row]').forEach(function (button) {
                button.addEventListener('click', function () {
                    var kind = button.getAttribute('data-add-row');
                    var template = document.getElementById(kind + '-template');
                    var target = document.getElementById(kind + '-rows');

                    if (!template || !target) {
                        return;
                    }

                    target.insertAdjacentHTML(
                        'beforeend',
                        template.innerHTML.replace(/__INDEX__/g, String(counters[kind]++))
                    );
                });
            });

            document.addEventListener('click', function (event) {
                if (!(event.target instanceof Element)) {
                    return;
                }

                var button = event.target.closest('[data-remove-row]');

                if (!button) {
                    return;
                }

                var row = button.closest('.pair-row, .ref-row');

                if (row) {
                    row.remove();
                }
            });
        })();
    </script>
@endpush
