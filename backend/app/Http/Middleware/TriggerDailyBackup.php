<?php

namespace App\Http\Middleware;

use App\Support\BackupWatch;
use App\Support\DailyBackup;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Déclenche la sauvegarde quotidienne **après** la réponse (cf. `DailyBackup`).
 *
 * Le callback `terminating` s'exécute une fois la réponse envoyée : la visite
 * n'attend rien. Il vérifie aussi qu'une sauvegarde récente existe
 * (`BackupWatch`) : deux `stat`, et un courriel au plus une fois par jour si
 * plus rien n'arrive depuis 36 h. Les suites de tests ne lancent jamais
 * `mysqldump` — le déclencheur est ignoré sous PHPUnit — mais une instance
 * injectée permet de tester le câblage, alerte comprise.
 */
class TriggerDailyBackup
{
    public function __construct(
        private readonly ?DailyBackup $backup = null,
        private readonly ?BackupWatch $watch = null,
    ) {}

    /**
     * @param  Closure(Request): Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        if ($this->backup === null) {
            if (app()->runningUnitTests()) {
                return $response;
            }

            $backup = DailyBackup::fromConfig();
            $watch = BackupWatch::fromConfig();
        } else {
            $backup = $this->backup;
            $watch = $this->watch;
        }

        app()->terminating(static function () use ($backup, $watch): void {
            $backup->runIfDue();
            $watch?->alertIfStale();
        });

        return $response;
    }
}
