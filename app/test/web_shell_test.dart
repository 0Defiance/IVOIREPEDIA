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
  });
}
