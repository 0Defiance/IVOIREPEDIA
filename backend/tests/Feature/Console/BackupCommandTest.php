<?php

/**
 * `backup:run` sans mysqldump : le plan, la base, le dossier.
 *
 * L'exécution réelle du dump est vérifiée sur le serveur (docs/DEPLOIEMENT.md
 * §8.2) ; ici on teste ce que la commande décide — quelle base, quels noms de
 * fichiers, et le refus de travailler sans base — sans toucher au disque.
 */
it('affiche le plan d’une sauvegarde sans rien écrire', function () {
    // Les chemins annoncés par la commande sont toujours écrits avec des `/`.
    $dir = str_replace('\\', '/', sys_get_temp_dir()).'/ivp-backup-'.bin2hex(random_bytes(4));

    $this->artisan('backup:run', [
        '--database' => 'ivoirepedia_dev',
        '--dir' => $dir,
        '--dry-run' => true,
    ])
        ->assertExitCode(0)
        ->expectsOutputToContain('dump='.$dir.'/db-ivoirepedia_dev-')
        ->expectsOutputToContain('media='.$dir.'/media-ivoirepedia_dev-');

    expect(is_dir($dir))->toBeFalse();
});

it('refuse de sauvegarder sans base', function () {
    config(['database.connections.mysql.database' => '']);

    $this->artisan('backup:run', ['--dry-run' => true])
        ->assertExitCode(1)
        ->expectsOutputToContain('Aucune base à sauvegarder');
});
