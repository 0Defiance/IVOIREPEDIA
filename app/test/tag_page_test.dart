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

/// API en mémoire : un article étiqueté, et la liste filtrée par étiquette.
class _TagApi extends FakeIvoirepediaApi {
  String? askedTag;
  int askedPage = 0;

  ArticleSummary get _article => ArticleSummary(
    slug: 'le-zaouli',
    title: 'Le Zaouli',
    summary: 'Danse masquée gouro, inscrite au patrimoine immatériel.',
    typeLabel: 'Sujet',
    categoryName: 'Culture',
    categorySlug: 'culture',
  );

  @override
  Future<List<Category>> fetchCategories() async => const [];

  @override
  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    List<String>? slugs,
    int page = 1,
    int limit = 12,
  }) async {
    askedTag = tag;
    askedPage = page;

    if (tag == null || tag.isEmpty) {
      return PagedArticles(
        items: [_article],
        page: page,
        limit: limit,
        total: 1,
      );
    }

    return PagedArticles(items: [_article], page: page, limit: limit, total: 1);
  }

  @override
  Future<ArticleDetail> fetchArticle(String slug) async {
    return ArticleDetail(
      slug: slug,
      title: 'Le Zaouli',
      summary: 'Danse masquée gouro, inscrite au patrimoine immatériel.',
      typeLabel: 'Sujet',
      categoryName: 'Culture',
      categorySlug: 'culture',
      contentOps: const [
        {'insert': 'Le zaouli est une danse masquée gouro.\n'},
      ],
      tags: const [ArticleTag(name: 'Indépendance', slug: 'independance')],
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

  testWidgets('la page d’étiquette liste les articles filtrés par le serveur', (
    tester,
  ) async {
    final api = _TagApi();

    await tester.pumpWidget(
      _app(
        api,
        buildRouter()..go('/etiquettes/independance?nom=Ind%C3%A9pendance'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.askedTag, 'independance');
    expect(api.askedPage, 1);
    expect(find.text('Étiquette : Indépendance'), findsOneWidget);
    expect(find.text('1 page avec cette étiquette.'), findsOneWidget);
    expect(find.text('Le Zaouli'), findsOneWidget);
  });

  testWidgets('sans nom dans l’adresse, le slug est mis en forme', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_TagApi(), buildRouter()..go('/etiquettes/culture-gouro')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Étiquette : Culture gouro'), findsOneWidget);
  });

  testWidgets('depuis un article, un clic sur l’étiquette ouvre sa page', (
    tester,
  ) async {
    final api = _TagApi();
    final router = buildRouter()..go('/articles/le-zaouli');

    await tester.pumpWidget(_app(api, router));
    await tester.pumpAndSettle();

    final link = find.text('Indépendance').last;
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(api.askedTag, 'independance');
    expect(find.text('Étiquette : Indépendance'), findsOneWidget);
    expect(find.text('Le Zaouli'), findsWidgets);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/etiquettes/independance?nom=Ind%C3%A9pendance',
    );
  });
}
