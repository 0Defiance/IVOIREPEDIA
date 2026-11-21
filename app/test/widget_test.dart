import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

    // La manchette du jour porte la signature complète : l'en-tête du site
    // s'efface au sommet de l'accueil.
    expect(find.byKey(const ValueKey('brand-lockup')), findsOneWidget);
    expect(
      find.textContaining('L’encyclopédie de la Côte d’Ivoire'),
      findsWidgets,
    );
    // Le sommaire reprend les libellés des rubriques : chacune apparaît deux
    // fois, une fois dans le plan et une fois comme titre.
    expect(find.text('La une'), findsNWidgets(2));
    expect(find.text('LE SAVIEZ-VOUS ?'), findsOneWidget);
    expect(find.text('Tous les portails'), findsOneWidget);
    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Abidjan'), findsWidgets);

    // La manchette porte la devise et les repères du pays.
    expect(find.text(kTagline), findsWidgets);
    expect(find.text('32 711 547 habitants'), findsOneWidget);
    expect(find.textContaining('+2,5 % par an'), findsOneWidget);
    expect(find.text('Aujourd’hui dans l’histoire'), findsNWidgets(2));
    expect(find.text('Voir la frise complète'), findsOneWidget);
    expect(find.text('Le royaume d’Indénié'), findsWidgets);
  });

  testWidgets('« Tirer un article » ouvre l’article tiré par le serveur', (
    tester,
  ) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    final button = find.text('Au hasard');
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

  testWidgets('une entrée du sommaire fait défiler jusqu’à sa rubrique', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    // Le libellé vaut deux fois : l'entrée du sommaire, puis le titre de la
    // rubrique, qui commence sous la ligne de flottaison.
    final heading = find.text('Explorer les régions').last;
    final before = tester.getTopLeft(heading).dy;
    expect(before, greaterThan(800));

    await tester.tap(find.text('Explorer les régions').first);
    await tester.pumpAndSettle();

    // Le sommaire ne quitte pas la page : la rubrique remonte en haut de
    // l'écran, à la marge près.
    final after = tester.getTopLeft(heading).dy;
    expect(after, lessThan(before));
    expect(after, lessThan(300));
  });

  testWidgets('une carte de région ouvre sa fiche, ou l’annuaire à défaut', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.text('Folon')));
    String location() =>
        router.routerDelegate.currentConfiguration.uri.toString();

    // Une région que le recensement relie à une fiche : la carte y conduit.
    await tester.ensureVisible(find.text('Haut-Sassandra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haut-Sassandra'));
    await tester.pumpAndSettle();
    expect(location(), '/lieux/haut-sassandra');

    // Une région sans fiche : la carte ouvre l'annuaire des lieux.
    router.go('/');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Folon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Folon'));
    await tester.pumpAndSettle();
    expect(location(), '/lieux');
  });

  testWidgets('l’accueil se rend sur téléphone sans débordement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    // Le plan des domaines de la manchette et le menu de la couverture.
    expect(find.text('Portails'), findsNWidgets(2));
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
    expect(find.byKey(const ValueKey('brand-lockup')), findsOneWidget);
    expect(find.byKey(const ValueKey('backdrop-emblem')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la page d’accueil se rend aussi en grand écran', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('La une'), findsNWidgets(2));
    expect(find.text('Tous les portails'), findsOneWidget);
    expect(find.text('Voir la frise complète'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
