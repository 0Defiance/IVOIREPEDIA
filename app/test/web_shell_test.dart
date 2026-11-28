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
    // La CSP bloquante refuse les scripts en ligne et les gestionnaires
    // d'attributs (`onload`, `onerror`) : la couverture est un fichier de la
    // même origine, qui crée lui-même la balise du chargeur et s'abonne à son
    // arrivée comme à son échec.
    expect(shell, contains('<script src="loading.js" defer></script>'));
    expect(shell, isNot(contains('onload=')));
    expect(shell, isNot(contains('onerror=')));

    final cover = File('web/loading.js').readAsStringSync();
    expect(cover, contains('flutter_bootstrap.js'));
    expect(cover, contains("addEventListener('load'"));
    expect(cover, contains("addEventListener('error'"));
  });

  // Le logo de l'écran de chargement part avant tout le reste : il est
  // aplati sur le papier du thème (fond uni, l'alpha ne sert à rien) et doit
  // rester sous les 60 ko, sinon le premier affichage en pâtit.
  test('le logo de chargement reste léger', () {
    final logo = File('web/logo.webp');
    expect(logo.existsSync(), isTrue);
    expect(logo.lengthSync(), lessThan(60000));
    // Le repli PNG existe pour les navigateurs sans WebP.
    expect(File('web/logo.png').existsSync(), isTrue);
  });
}
