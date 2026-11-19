@extends('admin.layout')

@section('title', 'Catégories')
@section('eyebrow', 'Référentiels')
@section('lead', 'L’arborescence du site. Une catégorie utilisée garde son adresse : renommer ne change pas son slug.')

@section('content')
    <div class="card">
        <h2>Nouvelle catégorie</h2>
        <form method="post" action="{{ route('admin.categories.store') }}">
            @csrf
            <div class="form-row two">
                <div class="form-row" style="margin:0">
                    <label for="new-name">Nom</label>
                    <input id="new-name" name="name" type="text" required maxlength="100"
                           value="{{ old('name') }}" placeholder="Régions">
                </div>
                <div class="form-row" style="margin:0">
                    <label for="new-position">Position</label>
                    <input id="new-position" name="position" type="number" min="0" max="999"
                           value="{{ old('position', 0) }}">
                </div>
            </div>
            <div class="form-row">
                <label for="new-description">Description</label>
                <textarea id="new-description" name="description" class="short-box"
                          maxlength="1000">{{ old('description') }}</textarea>
            </div>
            <div class="form-row">
                <label for="new-parent">Catégorie mère</label>
                <select id="new-parent" name="parent_id">
                    <option value="">Aucune (racine)</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" @selected(old('parent_id') === $category->id)>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <button class="btn primary" type="submit">Créer la catégorie</button>
        </form>
    </div>

    <div class="card">
        <h2>Catégories ({{ $categories->count() }})</h2>

        @if ($categories->isEmpty())
            <div class="empty">
                <strong>Aucune catégorie</strong>
                Créez la première : un article ne peut pas exister sans catégorie.
            </div>
        @else
            <table class="table">
                <thead>
                <tr>
                    <th>Nom</th>
                    <th>Description</th>
                    <th>Position</th>
                    <th>Mère</th>
                    <th>Articles</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                @foreach ($categories as $category)
                    <tr>
                        <td>
                            <form id="category-{{ $category->id }}" method="post"
                                  action="{{ route('admin.categories.update', $category) }}">
                                @csrf
                                @method('put')
                                <input name="name" type="text" required maxlength="100"
                                       value="{{ $category->name }}" aria-label="Nom de {{ $category->name }}">
                                <div class="meta">{{ $category->slug }}</div>
                            </form>
                        </td>
                        <td>
                            <input form="category-{{ $category->id }}" name="description" type="text"
                                   maxlength="1000" value="{{ $category->description }}"
                                   aria-label="Description de {{ $category->name }}">
                        </td>
                        <td style="width:96px">
                            <input form="category-{{ $category->id }}" name="position" type="number"
                                   min="0" max="999" value="{{ $category->position }}"
                                   aria-label="Position de {{ $category->name }}">
                        </td>
                        <td style="width:160px">
                            <select form="category-{{ $category->id }}" name="parent_id"
                                    aria-label="Catégorie mère de {{ $category->name }}">
                                <option value="">Aucune</option>
                                @foreach ($categories as $candidate)
                                    @continue($candidate->id === $category->id)
                                    <option value="{{ $candidate->id }}" @selected($category->parent_id === $candidate->id)>
                                        {{ $candidate->name }}
                                    </option>
                                @endforeach
                            </select>
                        </td>
                        <td class="meta">{{ $category->articles_count }}</td>
                        <td>
                            <div class="actions">
                                <button form="category-{{ $category->id }}" class="btn ghost small" type="submit">
                                    Enregistrer
                                </button>
                                <form method="post" action="{{ route('admin.categories.destroy', $category) }}"
                                      onsubmit="return confirm('Supprimer cette catégorie ?')">
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
