@extends('admin.layout')

@section('title', 'Étiquettes')
@section('eyebrow', 'Référentiels')
@section('lead', 'Les étiquettes traversent les catégories : elles servent à filtrer la lecture par thème, sans créer de nouvelle branche.')

@section('content')
    <div class="card">
        <h2>Nouvelle étiquette</h2>
        <form method="post" action="{{ route('admin.tags.store') }}">
            @csrf
            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="new-tag">Nom</label>
                    <input id="new-tag" name="name" type="text" required maxlength="100"
                           value="{{ old('name') }}" placeholder="Agriculture">
                </div>
                <div class="form-row" style="margin:0;align-self:end">
                    <button class="btn primary" type="submit">Créer l’étiquette</button>
                </div>
            </div>
        </form>
    </div>

    <div class="card">
        <h2>Étiquettes ({{ $tags->count() }})</h2>

        @if ($tags->isEmpty())
            <div class="empty">
                <strong>Aucune étiquette</strong>
                Une étiquette relie des articles de catégories différentes.
            </div>
        @else
            <table class="table">
                <thead>
                <tr>
                    <th>Nom</th>
                    <th>Adresse</th>
                    <th>Articles</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                @foreach ($tags as $tag)
                    <tr>
                        <td>
                            <form id="tag-{{ $tag->id }}" method="post"
                                  action="{{ route('admin.tags.update', $tag) }}">
                                @csrf
                                @method('put')
                                <input name="name" type="text" required maxlength="100"
                                       value="{{ $tag->name }}" aria-label="Nom de {{ $tag->name }}">
                            </form>
                        </td>
                        <td class="meta">{{ $tag->slug }}</td>
                        <td class="meta">{{ $tag->articles_count }}</td>
                        <td>
                            <div class="actions">
                                <button form="tag-{{ $tag->id }}" class="btn ghost small" type="submit">
                                    Enregistrer
                                </button>
                                <form method="post" action="{{ route('admin.tags.destroy', $tag) }}"
                                      onsubmit="return confirm('Supprimer cette étiquette ? Les articles sont conservés.')">
                                    @csrf
                                    @method('delete')
                                    <button class="btn danger small" type="submit">Supprimer</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        @endif
    </div>
@endsection
