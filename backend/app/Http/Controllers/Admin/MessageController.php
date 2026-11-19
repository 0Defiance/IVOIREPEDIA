<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ContactMessageStatus;
use App\Http\Controllers\Controller;
use App\Models\ContactMessage;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\View\View;

/**
 * Messages reçus par la page « Contact ».
 *
 * Rien n'est supprimé : un message non traité reste en tête de liste jusqu'à
 * ce qu'un éditeur le marque comme traité. Les messages sont visibles des
 * rôles qui peuvent réviser (EDITOR et ADMIN), pas des contributeurs.
 */
class MessageController extends Controller
{
    public function index(Request $request): View
    {
        Gate::authorize('manage-references');

        $showHandled = $request->boolean('traites');

        $query = ContactMessage::query()
            ->when(! $showHandled, fn ($builder) => $builder->where('status', ContactMessageStatus::NEW))
            ->latest();

        return view('admin.messages.index', [
            'messages' => $query->paginate(20)->withQueryString(),
            'newCount' => ContactMessage::query()->where('status', ContactMessageStatus::NEW)->count(),
            'handledCount' => ContactMessage::query()->where('status', ContactMessageStatus::HANDLED)->count(),
            'showHandled' => $showHandled,
        ]);
    }

    public function handle(ContactMessage $contactMessage): RedirectResponse
    {
        Gate::authorize('manage-references');

        $contactMessage->fill([
            'status' => ContactMessageStatus::HANDLED,
            'handled_at' => now(),
        ])->save();

        return back()->with('status', 'Message marqué comme traité.');
    }
}
