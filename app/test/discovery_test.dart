import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/article_export.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/place.dart';
import 'package:ivoirepedia/src/models/suggestion.dart';
import 'package:ivoirepedia/src/models/timeline.dart';
import 'package:ivoirepedia/src/storage.dart';
import 'package:ivoirepedia/src/theme.dart';
import 'package:ivoirepedia/src/ui/article_page.dart';
import 'package:ivoirepedia/src/ui/search_page.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';
import 'package:ivoirepedia/src/ui/widgets/share_bar.dart';

import 'support/fake_api.dart';

const _article = ArticleDetail(
  slug: 'abidjan',
  title: 'Abidjan',
  summary: 'La capitale économique, posée sur une lagune.',
  typeLabel: 'Ville',
  categoryName: 'Villes',
  categorySlug: 'villes',
  readingMinutes: 5,
  contentOps: [
    {'insert': 'Abidjan s’étend sur plusieurs communes.\n'},
    {'insert': 'Une population publiée au recensement.[1]\n'},
    {'insert': 'Histoire\n', 'attributes': {'header': 2}},
    {'insert': 'La ville devient capitale en 1934.\n'},
  ],
  references: [
    ArticleReference(
      position: 1,
      title: 'RGPH 2021, résultats globaux',
      authors: 'ANStat',
      year: 2022,
    ),
  ],
);

class _DiscoveryApi extends FakeIvoirepediaApi {
  _DiscoveryApi() {
    _storage.load();
  }

  final AppStorage _storage = AppStorage.instance;

  @override
  Future<List<TimelineEvent>> fetchTimeline() async => const [
        TimelineEvent(
          slug: 'indenie-abengourou',
          year: 1701,
          era: 'Avant 1800',
          title: 'Abengourou, fondée par un chef qui cherchait la paix',
          teaser: 'Les Agni Ndénian viennent du royaume d’Aowin.',
          period: '1701-1870',
        ),
        TimelineEvent(
          slug: 'samory-guelemou-1898',
          year: 1898,
          era: 'XIXe siècle',
          title: 'La capture sans un coup de feu',
          teaser: 'Samory Touré est pris à Guélémou.',
          period: '29 septembre 1898',
        ),
      ];

  @override
  Future<PlaceDirectory> fetchPlaces() async => const PlaceDirectory(
        districts: [PlaceChild(name: 'Abidjan', slug: 'abidjan', population: 6321017)],
        regions: [PlaceChild(name: 'Lagunes', slug: 'lagunes', population: 2042623)],
        cities: [PlaceChild(name: 'Bouaké', slug: 'bouake', population: 832371)],
      );

  @override
  Future<PlaceDetail> fetchPlace(String slug) async => const PlaceDetail(
        slug: 'abidjan',
        name: 'Abidjan',
        level: 'district',
        entries: [
          PlaceEntry(
            level: 'district',
            label: 'District',
            population: 6321017,
            households: 1414136,
            averageSize: 4.5,
          ),
        ],
        climate: PlaceClimate(
          annualRainMm: 1851.5,
          wettestMonth: 6,
          wettestMonthRainMm: 253.2,
          averageTemperatureC: 26.4,
          periodStart: 1991,
          periodEnd: 2020,
          sourceLicence: 'CC BY 4.0',
        ),
        articles: [
          ArticleSummary(
            slug: 'abidjan',
            title: 'Abidjan',
            summary: 'La capitale économique.',
            typeLabel: 'Ville',
          ),
        ],
      );

  @override
  Future<ArticleDetail> fetchArticle(String slug) async => _article;

  @override
  Future<List<SearchSuggestion>> suggest(String query) async => const [
        SearchSuggestion(slug: 'abidjan', title: 'Abidjan', category: 'Villes'),
      ];
}

void main() {
  setUp(() {
    ivoireMotionEnabled = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('la frise affiche les jalons et ouvre le récit choisi', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _DiscoveryApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('La frise du temps').first);
    await tester.pumpAndSettle();

    expect(find.text('La frise du temps'), findsWidgets);
    expect(find.text('1701'), findsOneWidget);
    expect(find.text('XIXe siècle'.toUpperCase()), findsOneWidget);
    expect(
      find.text('La capture sans un coup de feu'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('l’annuaire mène à une fiche de lieu avec son climat', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _DiscoveryApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Villes et régions').first);
    await tester.pumpAndSettle();

    expect(find.text('Les 14 districts'), findsOneWidget);
    expect(find.text('Bouaké'), findsOneWidget);

    await tester.tap(find.text('Abidjan').first);
    await tester.pumpAndSettle();

    expect(find.text('POPULATION RÉSIDENTE — RGPH 2021'), findsOneWidget);
    expect(find.textContaining('1'), findsWidgets);
    expect(find.textContaining('mm'), findsWidgets);
    expect(find.text('Climat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la recherche propose des suggestions et garde l’historique', (tester) async {
    await tester.pumpWidget(
      ApiScope(
        api: _DiscoveryApi(),
        child: MaterialApp(theme: buildIvoireTheme(), home: const SearchPage()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).last, 'abi');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('SUGGESTIONS'), findsOneWidget);
    expect(find.text('Abidjan'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un appel de note renvoie vers la référence, et l’article se garde', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ApiScope(
        api: _DiscoveryApi(),
        child: MaterialApp(
          theme: buildIvoireTheme(),
          home: const ArticlePage(slug: 'abidjan'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notes et références'), findsOneWidget);
    expect(find.text('RGPH 2021, résultats globaux'), findsNothing);
    expect(find.textContaining('RGPH 2021, résultats globaux'), findsOneWidget);

    await tester.tap(find.text('Garder').first);
    await tester.pumpAndSettle();

    expect(AppStorage.instance.favorites.value.map((e) => e.slug), contains('abidjan'));
    expect(find.text('Gardé'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('les URL de partage sont propres et pointent la section', () {
    expect(articleUrl('abidjan'), '$kSiteUrl/articles/abidjan');
    expect(shareUrl(articleUrl('abidjan'), section: 'Le café et le cacao'),
        '$kSiteUrl/articles/abidjan#le-cafe-et-le-cacao');

    final links = shareLinks(articleUrl('abidjan'), 'Abidjan');

    expect(links.keys, containsAll(['WhatsApp', 'X', 'Facebook', 'LinkedIn']));
    expect(links['WhatsApp'], contains('wa.me'));
    expect(links['WhatsApp'], contains(Uri.encodeComponent(articleUrl('abidjan'))));
  });
}
