<?php

namespace App\Http\Middleware;

use App\Support\DailyBackup;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Déclenche la sauvegarde quotidienne **après** la réponse (cf. `DailyBackup`).
 *
 * Le callback `terminating` s'exécute une fois la réponse envoyée : la visite
 * n'attend rien. Les suites de tests ne lancent jamais `mysqldump` — le
 * déclencheur est ignoré sous PHPUnit — mais une instance injectée permet de
 * tester le câblage.
 */
class TriggerDailyBackup
{
    public function __construct(private readonly ?DailyBackup $backup = null) {}

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
        } else {
            $backup = $this->backup;
        }

        app()->terminating(static function () use ($backup): void {
            $backup->runIfDue();
        });

        return $response;
    }
}
