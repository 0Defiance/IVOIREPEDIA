<?php

namespace App\Notifications;

use App\Services\PasswordResetService;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

/**
 * Courriel de réinitialisation.
 *
 * Le lien mène à l'application Flutter, qui recueille le nouveau mot de passe
 * et appelle `POST /api/v1/auth/reset-password`. Aucun mot de passe ne circule
 * par courriel.
 */
class ResetPasswordNotification extends Notification
{
    use Queueable;

    public function __construct(public readonly string $token) {}

    /**
     * @return list<string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $email = (string) ($notifiable->email ?? '');
        $url = rtrim((string) config('ivoirepedia.site_url'), '/')
            .'/mot-de-passe-oublie?token='.urlencode($this->token)
            .'&email='.urlencode($email);

        return (new MailMessage)
            ->subject('Choisir un nouveau mot de passe — Ivoirepedia')
            ->greeting('Bonjour,')
            ->line('Vous avez demandé à réinitialiser le mot de passe de votre compte Ivoirepedia.')
            ->action('Choisir un nouveau mot de passe', $url)
            ->line('Ce lien est valable '.PasswordResetService::TTL_MINUTES.' minutes et ne peut servir qu’une fois.')
            ->line('Si vous n’êtes pas à l’origine de cette demande, ignorez ce message : votre mot de passe reste inchangé.');
    }
}
