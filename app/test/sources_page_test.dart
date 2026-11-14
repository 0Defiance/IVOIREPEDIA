import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/sources.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/fake_api.dart';

/// API minimale : la page des sources est le seul endpoint réellement utilisé.
class _SourcesApi extends FakeIvoirepediaApi {
  int calls = 0;

  @override
  Future<SourceLibrary> fetchSources() async {
    calls += 1;

    return SourceLibrary.fromJson({
      'data': [
        {
          'name': 'ANStat (ex-INS)',
          'count': 2,
          'references': [
            {
              'title': 'Chiffres clés de la Côte d’Ivoire 2025',
              'year': 2025,
              'url': 'https://www.anstat.ci',
              'articles': [
                {'slug': 'abidjan', 'title': 'Abidjan'},
                {'slug': 'le-cacao-en-cote-d-ivoire', 'title': 'Le cacao en Côte d’Ivoire'},
              ],
            },
            {
              'title': 'Recensement général de la population et de l’habitat 2021',
              'year': 2022,
              'url': null,
              'articles': [
                {'slug': 'bouake', 'title': 'Bouaké'},
              ],
            },
          ],
        },
        {
          'name': 'UNESCO',
          'count': 1,
          'references': [
            {
              'title': 'Liste du patrimoine mondial — Côte d’Ivoire',
              'year': null,
              'url': 'https://whc.unesco.org/fr/etatsparties/ci',
              'articles': [
                {'slug': 'parc-national-de-tai', 'title': 'Parc national de Taï'},
              ],
            },
          ],
        },
      ],
      'meta': {
        'institutions': 2,
        'references': 3,
        'mentions': 4,
        'articles': 4,
      },
    });
  }

  @override
  Future<List<Category>> fetchCategories() async => const [];

  @override
  Future<List<HistoryStory>> fetchHistory() async => const [];
}

void main() {
  setUp(() => ivoireMotionEnabled = false);

  Future<void> openSources(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _SourcesApi()));
    await tester.pumpAndSettle();

    // Entrée de menu « Charte et sources », dans la colonne de navigation.
    await tester.tap(find.text('Charte et sources').first);
    await tester.pumpAndSettle();
  }

  testWidgets('la page liste les sources par institution', (tester) async {
    await openSources(tester);

    expect(find.text('D’où viennent nos informations'), findsOneWidget);
    expect(find.text('ANStat (ex-INS)'), findsOneWidget);
    expect(find.text('UNESCO'), findsOneWidget);
    expect(find.text('Chiffres clés de la Côte d’Ivoire 2025 (2025)'), findsOneWidget);
    expect(find.text('2 références'), findsOneWidget);
    expect(find.text('1 référence'), findsOneWidget);
    expect(find.textContaining('Cité par :'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('les compteurs résument la bibliothèque', (tester) async {
    await openSources(tester);

    expect(find.text('2'), findsWidgets);
    expect(find.text('3'), findsWidgets);
    expect(find.text('INSTITUTIONS'), findsOneWidget);
    expect(find.text('RÉFÉRENCES DISTINCTES'), findsOneWidget);
    expect(find.text('ARTICLES SOURCÉS'), findsOneWidget);
  });

  testWidgets('une source cite ses articles et mène à l’article', (tester) async {
    await openSources(tester);

    await tester.tap(find.text('Bouaké').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
