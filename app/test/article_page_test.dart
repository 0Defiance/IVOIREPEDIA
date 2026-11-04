import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/theme.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';
import 'package:ivoirepedia/src/ui/article_page.dart';

class _ArticleApi implements IvoirepediaApi {
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
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async =>
      const PagedArticles(items: [], page: 1, limit: 12, total: 0);

  @override
  Future<ArticleDetail> fetchArticle(String slug) async {
    return ArticleDetail(
      slug: 'felix-houphouet-boigny',
      title: 'Félix Houphouët-Boigny',
      summary: 'Médecin et homme d’État ivoirien.',
      typeLabel: 'Biographie',
      categoryName: 'Personnalités',
      categorySlug: 'personnalites',
      authorName: 'La rédaction',
      publishedAt: DateTime(2026, 11, 2),
      readingMinutes: 6,
      contentOps: const [
        {'insert': 'Il est né à N’Gokro, devenu Yamoussoukro.\n'},
        {'insert': 'La présidence\n', 'attributes': {'header': 2}},
        {'insert': 'Le RDA et la loi-cadre\n', 'attributes': {'header': 2}},
        {'insert': 'Il dirige le pays de 1960 à 1993.\n'},
      ],
      infobox: const {
        'fullName': 'Félix Houphouët-Boigny',
        'birthDate': '1905-10-18',
        'occupations': ['Médecin', 'Homme d’État'],
      },
      tags: const ['Indépendance'],
      references: const [
        ArticleReference(position: 1, title: 'RGPH 2021', year: 2022),
      ],
    );
  }
}

/// API qui répond 404 : vérifie l'écran d'erreur côté lecture.
class _MissingApi extends _ArticleApi {
  @override
  Future<ArticleDetail> fetchArticle(String slug) async =>
      throw const ApiException('Cette page n’existe pas ou n’est pas publiée.',
          statusCode: 404);
}

Widget _wrap(Widget child, {IvoirepediaApi? api}) {
  return ApiScope(
    api: api ?? _ArticleApi(),
    child: MaterialApp(theme: buildIvoireTheme(), home: child),
  );
}

void main() {
  // Pas d'animation de fond : `pumpAndSettle` doit pouvoir se stabiliser.
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('la page article affiche titre, infobox, contenu et références',
      (tester) async {
    await tester.pumpWidget(_wrap(const ArticlePage(slug: 'felix-houphouet-boigny')));
    await tester.pumpAndSettle();

    expect(find.text('Félix Houphouët-Boigny'), findsWidgets);
    expect(find.text('Article'), findsOneWidget);
    expect(find.text('Sommaire'), findsOneWidget);
    expect(find.text('La présidence'), findsWidgets);
    expect(find.textContaining('Il dirige le pays'), findsOneWidget);
    expect(find.text('Nom complet'), findsOneWidget);
    expect(find.text('18 octobre 1905'), findsOneWidget);
    expect(find.text('Notes et références'), findsOneWidget);
    expect(find.textContaining('RGPH 2021', findRichText: true), findsOneWidget);
    expect(find.text('Catégories :'), findsOneWidget);
  });

  testWidgets('seuls les titres de section sont mis en forme comme des titres',
      (tester) async {
    await tester.pumpWidget(_wrap(const ArticlePage(slug: 'felix-houphouet-boigny')));
    await tester.pumpAndSettle();

    // Le paragraphe qui suit un titre reste un paragraphe : il héritait
    // auparavant des attributs du titre précédent.
    final paragraph =
        tester.widget<Text>(find.text('Il dirige le pays de 1960 à 1993.'));
    expect(paragraph.style?.fontSize, 15.5);
    expect(paragraph.style?.fontWeight, FontWeight.w400);

    final heading = tester.widget<Text>(find.text('La présidence').last);
    expect(heading.style?.fontSize, 21);
    expect(heading.style?.fontWeight, FontWeight.w600);

    // Un lien « modifier » par titre seulement.
    expect(find.text('modifier'), findsNWidgets(2));
  });

  testWidgets('une erreur 404 affiche un message et un retour à l’accueil',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const ArticlePage(slug: 'inconnu'), api: _MissingApi()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('n’existe pas'), findsOneWidget);
    expect(find.text('Retour à la page d’accueil'), findsOneWidget);
  });
}
