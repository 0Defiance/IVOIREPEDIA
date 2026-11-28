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

];
