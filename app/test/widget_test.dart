import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/brand.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/fake_home_api.dart';

void main() {
  // Pas d'animation de fond : `pumpAndSettle` doit pouvoir se stabiliser.
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('la page d’accueil affiche l’article du jour et les domaines', (
    tester,
  ) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('brand-wordmark')), findsWidgets);
    expect(find.textContaining('encyclopédie libre consacrée'), findsOneWidget);
    expect(find.text('Article du jour'), findsOneWidget);
    expect(find.text('Le saviez-vous ?'), findsOneWidget);
    expect(find.text('Portails thématiques'), findsOneWidget);
    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Abidjan'), findsWidgets);

    // La manchette porte la devise et les repères du pays.
    expect(find.text(kTagline), findsWidgets);
    expect(find.text('32 711 547 habitants'), findsOneWidget);
    expect(find.text('+2,5 % par an (2020-2025)'), findsOneWidget);
    expect(find.text('Aujourd’hui dans l’histoire'), findsOneWidget);
    expect(find.text('La frise en un coup d’œil'), findsOneWidget);
    expect(find.text('Le royaume d’Indénié'), findsWidgets);
  });

  testWidgets('« Tirer un article » ouvre l’article tiré par le serveur', (
    tester,
  ) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    final button = find.text('Tirer un article');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Les onglets de la page de lecture n'existent que sur un article.
    expect(find.text('Voir l’historique'), findsOneWidget);
  });

  testWidgets('un jalon de la frise ouvre le récit dont il est tiré', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    // La frise de l'accueil pose ses jalons sur un axe, avec leur année.
    expect(find.text('1934'), findsWidgets);

    // Le même jalon peut aussi être la « une » historique : on prend la
    // dernière occurrence, celle de la frise.
    final event = find.text('Abidjan, capitale').last;
    await tester.ensureVisible(event);
    await tester.pumpAndSettle();
    await tester.tap(event);
    await tester.pumpAndSettle();

    expect(find.text('Histoires incroyables'), findsOneWidget);
  });

  testWidgets('l’article au hasard de la navigation ouvre un article', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    // Le titre est aussi celui de l'encart de la colonne de droite : on
    // déclenche l'entrée de navigation, la première dans l'arbre.
    await tester.tap(find.text('Article au hasard').first);
    await tester.pumpAndSettle();

    expect(find.text('Voir l’historique'), findsOneWidget);
  });

  testWidgets('l’accueil se rend sur téléphone sans débordement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('Portails'), findsOneWidget);
    expect(find.text('32 711 547 habitants'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la marque, la devise et l’emblème remplacent l’ancien logo', (
    tester,
  ) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    // Le titre de l'onglet est la devise officielle du site.
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, kTagline);
    expect(find.text(kTagline), findsWidgets);

    // L'emblème, le mot-symbole et la signature complète sont des images
    // fournies, et l'emblème veille aussi dans le fond du site.
    expect(find.byKey(const ValueKey('brand-emblem')), findsWidgets);
    expect(find.byKey(const ValueKey('brand-wordmark')), findsWidgets);
    expect(find.byKey(const ValueKey('backdrop-emblem')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la page d’accueil se rend aussi en grand écran', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('Article du jour'), findsOneWidget);
    expect(find.text('Portails thématiques'), findsOneWidget);
    expect(find.text('La frise en un coup d’œil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
