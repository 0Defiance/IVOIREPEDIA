@extends('admin.layout')

@section('title', 'Messages')
@section('eyebrow', 'Relation lecteurs')
@section('lead', 'Messages envoyés depuis la page « Contact » du site. Un message traité quitte la file de travail ; rien n’est supprimé.')

@section('content')
    <div class="card">
        <div class="actions" style="margin-bottom:14px">
            <a class="btn ghost small" href="{{ route('admin.messages.index') }}">
                À traiter ({{ $newCount }})
            </a>
            <a class="btn ghost small" href="{{ route('admin.messages.index', ['traites' => 1]) }}">
                Traités ({{ $handledCount }})
            </a>
        </div>

        @if ($messages->isEmpty())
            <div class="empty">
                <strong>{{ $showHandled ? 'Aucun message traité' : 'Aucun message en attente' }}</strong>
                Les corrections et demandes envoyées depuis le site apparaissent ici.
            </div>
        @else
            <table class="table">
                <thead>
                <tr>
                    <th>Reçu le</th>
                    <th>De</th>
                    <th>Message</th>
                    <th>État</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                @foreach ($messages as $message)
                    <tr>
                        <td class="meta">
                            {{ $message->created_at?->translatedFormat('j M Y · H:i') }}
                        </td>
                        <td>
                            @if ($message->name !== null || $message->email !== null)
                                <div>{{ $message->name ?? 'Sans nom' }}</div>
                                @if ($message->email !== null)
                                    <a class="meta" href="mailto:{{ $message->email }}">{{ $message->email }}</a>
                                @endif
                            @else
                                <span class="meta">Anonyme — pas de réponse possible</span>
                            @endif
                        </td>
                        <td style="max-width:52ch">
                            {!! nl2br(e($message->message)) !!}
                        </td>
                        <td>
                            <span class="badge {{ $message->status->tone() }}">{{ $message->status->label() }}</span>
                            @if ($message->handled_at !== null)
                                <div class="meta">{{ $message->handled_at->translatedFormat('j M Y') }}</div>
                            @endif
                        </td>
                        <td>
                            @if ($message->status === \App\Enums\ContactMessageStatus::NEW)
                                <form method="post"
                                      action="{{ route('admin.messages.handle', ['contactMessage' => $message]) }}">
                                    @csrf
                                    <button class="btn primary small" type="submit">Marquer comme traité</button>
                                </form>
                            @endif
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>

            <div class="pager">
                {{ $messages->links() }}
            </div>
        @endif
    </div>
@endsection
