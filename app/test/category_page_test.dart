import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/auth.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/statistics.dart';
import 'package:ivoirepedia/src/router.dart';
import 'package:ivoirepedia/src/theme.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/fake_api.dart';
import 'support/statistics_fixture.dart';

/// API en mémoire : une catégorie à sous-catégorie et 25 pages au total, pour
/// voir la liste partagée paginer par le serveur.
class _CategoryApi extends FakeIvoirepediaApi {
  final List<int> askedPages = <int>[];
  String? askedCategory;

  @override
  Future<List<Category>> fetchCategories() async => const [
    Category(
      name: 'Histoire',
      slug: 'histoire',
      description: 'Des premiers royaumes à la République.',
      articleCount: 25,
      children: [
        Category(name: 'Moyen Âge', slug: 'moyen-age', articleCount: 4),
      ],
    ),
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
    askedCategory = category;
    askedPages.add(page);

    return PagedArticles(
      items: [
        ArticleSummary(
          slug: 'page-$page',
          title: 'Page $page de la catégorie',
          summary: 'Résumé de la page $page.',
          typeLabel: 'Sujet',
        ),
      ],
      page: page,
      limit: limit,
      total: 25,
    );
  }

  @override
  Future<StatisticsSnapshot> fetchStatistics() async => statisticsFixture();
}

Widget _app(IvoirepediaApi api, RouterConfig<Object> router) {
  return AuthScope(
    store: AuthStore(),
    child: ApiScope(
      api: api,
      child: MaterialApp.router(
        theme: buildIvoireTheme(),
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('la page de catégorie liste ses pages et charge la suite', (
    tester,
  ) async {
    final api = _CategoryApi();

    await tester.pumpWidget(
      _app(api, buildRouter()..go('/categories/histoire')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catégorie : Histoire'), findsOneWidget);
    expect(find.text('Sous-catégories'), findsOneWidget);
    expect(find.text('Moyen Âge'), findsOneWidget);
    expect(find.text('25 pages dans cette catégorie.'), findsOneWidget);
    expect(api.askedCategory, 'histoire');
    expect(find.text('Page 1 de la catégorie'), findsOneWidget);
    // La ligne partagée écrit le type de page sous le titre.
    expect(find.textContaining('Sujet'), findsWidgets);

    // La liste partagée garde la pagination du serveur : un clic demande la
    // page suivante, sans découper ce qui est déjà chargé.
    final more = find.text('Charger la suite');
    await tester.ensureVisible(more);
    await tester.pumpAndSettle();
    await tester.tap(more);
    await tester.pumpAndSettle();

    expect(api.askedPages, [1, 2]);
    expect(find.text('Page 2 de la catégorie'), findsOneWidget);
  });
}
