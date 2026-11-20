<?php

// Les visuels cités par le HTML servi (JSON-LD, favicons) doivent exister dans
// `public/` : un visiteur qui arrive sur un autre navigateur reçoit ces
// fichiers, pas ceux du poste de développement.

it('expose le logo cité par le JSON-LD du publisher', function () {
    $path = public_path('logo.png');

    expect(is_file($path))->toBeTrue();
    expect(filesize($path))->toBeGreaterThan(0);
    expect(mime_content_type($path))->toBe('image/png');
});

it('expose les favicons cités par la coquille du site', function () {
    foreach (['favicon.png' => 'image/png', 'favicon.ico' => 'image/vnd.microsoft.icon'] as $file => $mime) {
        $path = public_path($file);

        expect(is_file($path))->toBeTrue();
        expect(filesize($path))->toBeGreaterThan(0);
        expect(mime_content_type($path))->toBe($mime);
    }
});
