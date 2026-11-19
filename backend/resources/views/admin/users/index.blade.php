@extends('admin.layout')

@section('title', 'Comptes')
@section('eyebrow', 'Administration')
@section('lead', 'Les rôles ouvrent des droits : un contributeur écrit et soumet, un éditeur révise et publie, un administrateur gère les comptes et supprime.')

@section('content')
    <div class="toolbar">
        <form method="get" action="{{ route('admin.users.index') }}">
            <input type="text" name="q" value="{{ $search }}" placeholder="Nom ou adresse…" aria-label="Rechercher un compte">
            <button class="btn ghost small" type="submit">Rechercher</button>
        </form>
        <span class="meta">{{ $users->total() }} compte{{ $users->total() > 1 ? 's' : '' }}</span>
    </div>

    <div class="card">
        <table class="table">
            <thead>
            <tr>
                <th>Compte</th>
                <th>Articles</th>
                <th>Rôle</th>
                <th>État</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            @foreach ($users as $user)
                <tr>
                    <td>
                        <span class="t">{{ $user->name }}</span>
                        @if (auth()->id() === $user->id)
                            <span class="meta">(vous)</span>
                        @endif
                        <div class="meta">{{ $user->email }}</div>
                    </td>
                    <td class="meta">{{ $user->articles_count }}</td>
                    <td>
                        @can('changeRole', $user)
                            <form method="post" action="{{ route('admin.users.role', $user) }}" style="display:flex;gap:6px">
                                @csrf
                                @method('patch')
                                <select name="role" style="width:auto" aria-label="Rôle de {{ $user->name }}">
                                    @foreach ($roles as $role)
                                        <option value="{{ $role->value }}" @selected($user->role === $role)>
                                            {{ $role->label() }}
                                        </option>
                                    @endforeach
                                </select>
                                <button class="btn ghost small" type="submit">Changer</button>
                            </form>
                        @else
                            <span class="pill {{ $user->role->value === 'ADMIN' ? 'published' : 'draft' }}">
                                {{ $user->role->label() }}
                            </span>
                        @endcan
                    </td>
                    <td>
                        @if ($user->isSuspended())
                            <span class="pill revision_requested">Suspendu</span>
                        @else
                            <span class="pill published">Actif</span>
                        @endif
                    </td>
                    <td>
                        @if ($user->isSuspended())
                            @can('reinstate', $user)
                                <form method="post" action="{{ route('admin.users.reinstate', $user) }}">
                                    @csrf
                                    <button class="btn ghost small" type="submit">Réactiver</button>
                                </form>
                            @endcan
                        @else
                            @can('suspend', $user)
                                <form method="post" action="{{ route('admin.users.suspend', $user) }}">
                                    @csrf
                                    <button class="btn danger small" type="submit">Suspendre</button>
                                </form>
                            @endcan
                        @endif
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </div>

    <p class="meta" style="margin-top:12px">
        Suspendre un compte coupe aussi ses jetons : l’application de la personne est déconnectée immédiatement.
        Le dernier administrateur ne peut être ni suspendu ni rétrogradé.
    </p>
@endsection
