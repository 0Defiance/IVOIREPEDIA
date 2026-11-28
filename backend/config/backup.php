<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Sauvegardes (docs/DEPLOIEMENT.md §8)
    |--------------------------------------------------------------------------
    |
    | `backup:run` écrit un dump et l'archive des médias dans ce dossier, avec
    | une rétention par base (`App\Support\BackupRetention`). Le défaut est
    | `~/backups` : hors du dépôt, donc jamais emporté par un déploiement.
    |
    */

    'directory' => rtrim((string) env('BACKUP_DIR', (getenv('HOME') ?: storage_path()).'/backups'), '/'),

    // Paires conservées sur le serveur, par base.
    'keep' => (int) env('BACKUP_KEEP', 7),

    // Secondes entre deux sauvegardes automatiques (24 h).
    'interval' => (int) env('BACKUP_INTERVAL', 86400),

    /*
    | Copie hors-site (docs/DEPLOIEMENT.md §8.5).
    |
    | Un dump qui ne quitte pas l'hébergeur ne protège pas de la perte du
    | compte (risque R-04). `disk` nomme un disque de `config/filesystems.php` ;
    | vide, la copie est désactivée et le dump local reste la seule copie.
    */

    'offsite' => [
        'disk' => env('BACKUP_OFFSITE_DISK'),
        'prefix' => trim((string) env('BACKUP_OFFSITE_PREFIX', 'ivoirepedia'), '/'),
        'keep' => (int) env('BACKUP_OFFSITE_KEEP', 30),
    ],

    /*
    | Alerte « aucune sauvegarde depuis N secondes » (§8.6).
    |
    | Sans destinataire, l'alerte ne part pas : elle reste dans les journaux.
    */

    'alert' => [
        'to' => env('BACKUP_ALERT_EMAIL'),
        'after' => (int) env('BACKUP_ALERT_AFTER', 129600), // 36 h
        'cooldown' => (int) env('BACKUP_ALERT_COOLDOWN', 86400),
    ],

];
