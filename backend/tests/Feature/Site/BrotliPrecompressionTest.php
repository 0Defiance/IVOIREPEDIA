<?php

// Le brotli est précompressé au déploiement (`tools/precompress_web.py`) et
// négocié par Apache : ce test fige les règles qui servent les variantes
// `.br` du JS et du wasm avec le bon encodage, le bon type et la même
// politique de cache que les originaux.
it('négocie le brotli précompressé pour le JS et le wasm', function () {
    $htaccess = file_get_contents(public_path('.htaccess'));

    // Négociation : seulement si le navigateur annonce `br` et que la
    // variante existe à côté de l'original, pour le JS et le wasm.
    expect($htaccess)
        ->toContain('Accept-Encoding')
        ->toContain('.br')
        ->toContain('js|wasm');

    // La variante annonce son encodage et retrouve son type d'origine.
    expect($htaccess)
        ->toContain('Content-Encoding br')
        ->toContain('text/javascript')
        ->toContain('application/wasm');

    // Même politique de cache que les originaux : le code se revalide, le
    // moteur se garde un jour.
    expect($htaccess)->toContain('\.js\.br');
    expect($htaccess)->toContain('\.wasm\.br');
});
