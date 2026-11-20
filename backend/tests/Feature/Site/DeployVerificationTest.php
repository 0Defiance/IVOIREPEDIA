<?php

// Chaque déploiement rejoue le parcours réel d'un navigateur
// (`tools/verify_deploy.py`, documenté dans `docs/DEPLOIEMENT.md` §6) : en
// novembre 2026, `curl` avec `Accept-Encoding: br` seul était vert pendant
// que le site restait bloqué (brotli de brotli). Ce test fige le contrat du
// script, pas son exécution réseau.
it('vérifie chaque déploiement avec des en-têtes de navigateur réels', function () {
    $root = dirname(base_path());
    $script = file_get_contents($root.'/tools/verify_deploy.py');
    $deploy = file_get_contents($root.'/docs/DEPLOIEMENT.md');

    // Le script annonce exactement ce qu'envoie un navigateur moderne, et
    // compare le corps décompressé à la variante non compressée.
    expect($script)
        ->toContain('gzip, deflate, br, zstd')
        ->toContain('identity')
        ->toContain('main.dart.js')
        ->toContain('canvaskit.wasm');

    // Le guide de déploiement ordonne ce contrôle après chaque mise en ligne.
    expect($deploy)->toContain('python ../tools/verify_deploy.py');
});
