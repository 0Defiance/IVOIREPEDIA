<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ContactMessageStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\ContactRequest;
use App\Models\ContactMessage;
use Illuminate\Http\JsonResponse;

/**
 * `POST /api/v1/contact` — formulaire de contact du site.
 *
 * Le message est enregistré pour être traité dans le panneau : aucune donnée
 * n'est renvoyée au lecteur au-delà d'un accusé de réception. La route est
 * plafonnée et protégée par un piège à robots (cf. `ContactRequest`).
 */
class ContactController extends Controller
{
    public function __invoke(ContactRequest $request): JsonResponse
    {
        /** @var array{name?: string|null, email?: string|null, message: string} $data */
        $data = $request->validated();

        $name = trim((string) ($data['name'] ?? ''));
        $email = trim((string) ($data['email'] ?? ''));

        $message = ContactMessage::query()->create([
            'name' => $name === '' ? null : $name,
            'email' => $email === '' ? null : mb_strtolower($email),
            'message' => trim($data['message']),
            'status' => ContactMessageStatus::NEW,
        ]);

        return response()->json([
            'data' => [
                'id' => $message->getKey(),
                'status' => $message->status->value,
            ],
        ], 201);
    }
}
