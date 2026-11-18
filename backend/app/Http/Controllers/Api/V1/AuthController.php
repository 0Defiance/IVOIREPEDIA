<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\ApiToken;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

/**
 * Comptes de lecteurs — Sprint 1 (EF-AUTH-01 à 03).
 *
 * L'inscription crée toujours un READER ; les rôles éditoriaux s'attribuent
 * depuis le back-office. La connexion renvoie un jeton porteur que
 * l'application conserve dans le stockage du navigateur.
 */
class AuthController extends Controller
{
    /** `POST /api/v1/auth/register` */
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::create([
            'name' => (string) $data['name'],
            'email' => (string) $data['email'],
            'password_hash' => Hash::make((string) $data['password']),
            'role' => 'READER',
        ]);

        return response()->json([
            'data' => [
                'user' => $this->payload($user),
                'token' => ApiToken::issue($user),
            ],
        ], 201);
    }

    /** `POST /api/v1/auth/login` */
    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::query()->where('email', (string) $data['email'])->first();

        if ($user === null || ! Hash::check((string) $data['password'], $user->password_hash)) {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_CREDENTIALS',
                    'message' => 'Adresse ou mot de passe incorrect.',
                ],
            ], 422);
        }

        if ($user->suspended_at !== null) {
            return response()->json([
                'error' => [
                    'code' => 'ACCOUNT_SUSPENDED',
                    'message' => 'Ce compte est suspendu. Écrivez à la rédaction.',
                ],
            ], 403);
        }

        return response()->json([
            'data' => [
                'user' => $this->payload($user),
                'token' => ApiToken::issue($user),
            ],
        ]);
    }

    /** `GET /api/v1/auth/me` */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user instanceof User) {
            return response()->json([
                'error' => [
                    'code' => 'UNAUTHENTICATED',
                    'message' => 'Connectez-vous pour accéder à cet espace.',
                ],
            ], 401);
        }

        return response()->json(['data' => $this->payload($user)]);
    }

    /** `POST /api/v1/auth/logout` — supprime le jeton utilisé. */
    public function logout(Request $request): JsonResponse
    {
        $token = $request->attributes->get('api_token');

        if ($token instanceof ApiToken) {
            $token->delete();
        }

        return response()->json([
            'data' => ['message' => 'Vous êtes déconnecté.'],
        ]);
    }

    /**
     * Forme publique d'un compte : jamais le hash ni les jetons.
     *
     * @return array<string, mixed>
     */
    private function payload(User $user): array
    {
        return [
            'id' => $user->getKey(),
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'email_verified' => $user->email_verified_at !== null,
            'created_at' => $user->created_at?->toIso8601String(),
        ];
    }
}
