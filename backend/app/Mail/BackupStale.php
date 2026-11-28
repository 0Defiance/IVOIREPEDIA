<?php

namespace App\Mail;

use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/**
 * Alerte envoyée quand plus aucune sauvegarde n'arrive depuis le délai prévu.
 *
 * Un Mailable plutôt qu'un `Mail::raw` : il se teste (`Mail::fake()` enregistre
 * les Mailable, pas les envois bruts) et son texte vit dans une vue, pas dans
 * une chaîne construite à la main.
 */
class BackupStale extends Mailable
{
    public function __construct(
        public readonly string $database,
        public readonly ?int $age,
        public readonly ?int $lastAt,
        public readonly int $after,
        public readonly string $directory,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: sprintf('IVOIREPEDIA — aucune sauvegarde depuis %d h', intdiv($this->after, 3600)),
        );
    }

    public function content(): Content
    {
        return new Content(text: 'mail.backup-stale');
    }
}
