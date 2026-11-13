import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/statistics.dart';

import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/timeline.dart';

import 'support/history_fixture.dart';
import 'support/statistics_fixture.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';
import 'support/fake_api.dart';

/// API en mémoire : les parcours d'interface sont testés sans réseau.
class FakeApi extends FakeIvoirepediaApi {
  @override
  Future<List<Category>> fetchCategories() async => const [
        Category(name: 'Histoire', slug: 'histoire', articleCount: 2),
        Category(name: 'Géographie', slug: 'geographie', articleCount: 1),
      ];

  @override
  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    int page = 1,
    int limit = 12,
  }) async {
    return PagedArticles(
      items: [
        ArticleSummary(
          slug: 'abidjan',
          title: 'Abidjan',
          summary: 'Capitale économique de la Côte d’Ivoire.',
          typeLabel: 'Territoire',
          categoryName: 'Géographie',
          categorySlug: 'geographie',
          authorName: 'La rédaction',
          publishedAt: DateTime(2026, 11, 1),
          readingMinutes: 4,
        ),
        ArticleSummary(
          slug: 'attieke',
          title: 'L’attiéké',
          summary: 'Semoule de manioc fermentée.',
          typeLabel: 'Sujet',
          categoryName: 'Culture',
          categorySlug: 'culture',
          authorName: 'La rédaction',
          publishedAt: DateTime(2026, 10, 30),
          readingMinutes: 3,
        ),
      ],
      page: page,
      limit: limit,
      total: 2,
    );
  }

  @override
  Future<ArticleDetail> fetchArticle(String slug) async {
    return const ArticleDetail(
      slug: 'abidjan',
      title: 'Abidjan',
      summary: 'Capitale économique.',
      typeLabel: 'Territoire',
      contentOps: [
        {'insert': 'Premier paragraphe sur Abidjan.\n'},
      ],
    );
  }

  @override
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async {
    return PagedArticles(items: const [], page: page, limit: limit, total: 0);
  }

  @override
  Future<StatisticsSnapshot> fetchStatistics() async => statisticsFixture();

  @override
  Future<List<TimelineEvent>> fetchTimeline() async => const [
        TimelineEvent(
          slug: 'indenie-abengourou',
          year: 1701,
          era: 'XVIIIe siècle',
          title: 'Le royaume d’Indénié',
          teaser: 'Un royaume akan sur la route de l’or.',
        ),
        TimelineEvent(
          slug: 'abidjan-capitale',
          year: 1934,
          era: 'XXe siècle',
          title: 'Abidjan, capitale',
          teaser: 'La ville devient le centre administratif de la colonie.',
        ),
      ];

  @override
  Future<List<HistoryStory>> fetchHistory() async => historyFixture();
}

void main() {
  // Pas d'animation de fond : `pumpAndSettle` doit pouvoir se stabiliser.
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('la page d’accueil affiche l’article du jour et les domaines',
      (tester) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('IVOIREPEDIA'), findsWidgets);
    expect(find.textContaining('encyclopédie libre consacrée'), findsOneWidget);
    expect(find.text('Article du jour'), findsOneWidget);
    expect(find.text('Le saviez-vous ?'), findsOneWidget);
    expect(find.text('Explorer par domaine'), findsOneWidget);
    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Abidjan'), findsWidgets);

    // La une s'ouvre sur les repères du pays, pas sur une page vide.
    expect(find.text('La Côte d’Ivoire, documentée.'), findsOneWidget);
    expect(find.text('32 711 547 habitants'), findsOneWidget);
    expect(find.text('+2,5 % par an (2020-2025)'), findsOneWidget);
    expect(find.text('Aujourd’hui dans l’histoire'), findsOneWidget);
    expect(find.text('La frise en un coup d’œil'), findsOneWidget);
    expect(find.text('Le royaume d’Indénié'), findsWidgets);
  });

  testWidgets('la page d’accueil se rend aussi en grand écran', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('Article du jour'), findsOneWidget);
    expect(find.text('Explorer par domaine'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
