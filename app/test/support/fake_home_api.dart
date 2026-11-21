import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/statistics.dart';
import 'package:ivoirepedia/src/models/timeline.dart';

import 'fake_api.dart';
import 'history_fixture.dart';
import 'statistics_fixture.dart';

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
    List<String>? slugs,
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
  Future<PagedArticles> search(
    String query, {
    int page = 1,
    int limit = 12,
  }) async {
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
  Future<ArticleSummary> fetchRandomArticle() async => const ArticleSummary(
    slug: 'attieke',
    title: 'L’attiéké',
    summary: 'Semoule de manioc fermentée.',
    typeLabel: 'Sujet',
    categoryName: 'Culture',
    categorySlug: 'culture',
  );

  @override
  Future<List<HistoryStory>> fetchHistory() async => historyFixture();
}
