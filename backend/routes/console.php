<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

/*
 * Sauvegarde quotidienne de la base et des médias (docs/DEPLOIEMENT.md §8).
 *
 * La tâche planifiée du compte exécute `php artisan schedule:run` chaque
 * minute ; c'est cette entrée qui déclenche le dump. 3 h 30 : le creux de
 * fréquentation, et un horaire où le panneau n'est pas utilisé.
 * `withoutOverlapping` évite deux dumps simultanés si un passage traîne.
 */
Schedule::command('backup:run --keep=7')->dailyAt('03:30')->withoutOverlapping();
