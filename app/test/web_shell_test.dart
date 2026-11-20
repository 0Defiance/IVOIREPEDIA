import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// La coquille `web/index.html` est servie telle quelle en production : ces
// indices de préchargement font partir le JavaScript critique un aller-retour
// plus tôt sur les connexions lentes.
void main() {
  test('la coquille web précharge le JavaScript critique', () {
    final shell = File('web/index.html').readAsStringSync();

    expect(
      shell,
      contains('<link rel="preload" href="flutter_bootstrap.js" as="script">'),
    );
    expect(
      shell,
      contains('<link rel="preload" href="main.dart.js" as="script">'),
    );
    // L'API est servie par la même origine : un preconnect serait sans effet.
    expect(shell, isNot(contains('rel="preconnect"')));

    // La page de chargement explique les étapes et reste interactive :
    // pastilles d'étapes, phrase de statut, compteur et bouton de rechargement.
    expect(shell, contains('data-step="connect"'));
    expect(shell, contains('data-step="engine"'));
    expect(shell, contains('data-step="ready"'));
    expect(shell, contains('id="status"'));
    expect(shell, contains('id="elapsed"'));
    expect(shell, contains('id="retry"'));
    // Le chargeur signale son arrivée et son échec au lieu d'attendre en silence.
    expect(shell, contains('onload='));
    expect(shell, contains('onerror='));
  });
}
