<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserRole;
use App\Exceptions\ResetLinkException;
use App\Http\Controllers\Controller;
use App\Http\Requests\ForgotPasswordRequest;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\ResetPasswordRequest;
use App\Models\ApiToken;
use App\Models\User;
use App\Services\PasswordResetService;
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
            'role' => UserRole::READER,
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
     * `POST /api/v1/auth/forgot-password` — envoie un lien si le compte existe.
     *
     * La réponse est identique dans tous les cas : c'est ce qui empêche
     * d'utiliser ce formulaire pour découvrir quelles adresses sont inscrites.
     */
    public function forgotPassword(
        ForgotPasswordRequest $request,
        PasswordResetService $reset,
    ): JsonResponse {
        $reset->request((string) $request->validated()['email']);

        return response()->json([
            'data' => [
                'message' => 'Si un compte existe avec cette adresse, un lien vient de lui être envoyé.',
            ],
        ]);
    }

    /** `POST /api/v1/auth/reset-password` — choisit un nouveau mot de passe. */
    public function resetPassword(
        ResetPasswordRequest $request,
        PasswordResetService $reset,
    ): JsonResponse {
        $data = $request->validated();

        try {
            $reset->reset(
                (string) $data['email'],
                (string) $data['token'],
                (string) $data['password'],
            );
        } catch (ResetLinkException $exception) {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_RESET_TOKEN',
                    'message' => $exception->getMessage(),
                ],
            ], 422);
        }

        return response()->json([
            'data' => [
                'message' => 'Votre mot de passe est changé. Vous pouvez vous connecter.',
            ],
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
            'role' => $user->role->value,
            'email_verified' => $user->email_verified_at !== null,
            'created_at' => $user->created_at?->toIso8601String(),
        ];
    }
}
