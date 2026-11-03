import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';

/// API en mémoire : les parcours d'interface sont testés sans réseau.
class FakeApi implements IvoirepediaApi {
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
}

void main() {
  testWidgets('l’accueil affiche la marque, les catégories et les articles',
      (tester) async {
    await tester.pumpWidget(IvoirepediaApp(api: FakeApi()));
    await tester.pumpAndSettle();

    expect(find.text('IVOIREPEDIA'), findsWidgets);
    expect(find.textContaining('un savoir ivoirien'), findsOneWidget);
    expect(find.text('Histoire · 2'), findsOneWidget);
    expect(find.text('Abidjan'), findsWidgets);
    expect(find.text('L’attiéké'), findsOneWidget);
  });
}
