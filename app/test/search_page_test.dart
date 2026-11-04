import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/theme.dart';
import 'package:ivoirepedia/src/ui/search_page.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

/// API de recherche en mémoire : elle note chaque terme reçu, ce qui permet
/// de vérifier que la page interroge bien le service.
class _SearchApi implements IvoirepediaApi {
  final List<String> queries = <String>[];

  @override
  Future<List<Category>> fetchCategories() async => const [];

  @override
  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    int page = 1,
    int limit = 12,
  }) async =>
      const PagedArticles(items: [], page: 1, limit: 12, total: 0);

  @override
  Future<ArticleDetail> fetchArticle(String slug) async =>
      throw const ApiException('non utilisé');

  @override
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async {
    queries.add(query);

    return PagedArticles(
      items: [
        ArticleSummary(
          slug: 'anacarde',
          title: 'L’anacarde',
          summary: 'Première culture de rente du nord ivoirien.',
          typeLabel: 'Sujet',
          categoryName: 'Économie',
          categorySlug: 'economie',
          publishedAt: DateTime(2026, 11, 3),
          readingMinutes: 4,
        ),
      ],
      page: page,
      limit: limit,
      total: 1,
    );
  }
}

Widget _wrap(SearchPage page, IvoirepediaApi api) {
  return ApiScope(
    api: api,
    child: MaterialApp(theme: buildIvoireTheme(), home: page),
  );
}

void main() {
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('une recherche passée dans l’URL est lancée à l’arrivée',
      (tester) async {
    final api = _SearchApi();

    await tester.pumpWidget(_wrap(const SearchPage(query: 'anacarde'), api));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.queries, ['anacarde']);
    expect(find.textContaining('Résultats 1 à 1 sur 1'), findsOneWidget);
    expect(find.text('L’anacarde'), findsWidgets);
  });

  testWidgets('la frappe relance la recherche après le délai', (tester) async {
    final api = _SearchApi();

    await tester.pumpWidget(_wrap(const SearchPage(), api));
    await tester.pump();

    await tester.enterText(find.byType(TextField).last, 'cacao');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(api.queries, contains('cacao'));
    expect(find.textContaining('pour « cacao »'), findsOneWidget);
  });
}
