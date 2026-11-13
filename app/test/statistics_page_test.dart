import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/statistics.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/statistics_fixture.dart';
import 'support/fake_api.dart';

/// API minimale : seules les statistiques et les catégories sont demandées au
/// premier écran ; le reste lève une erreur explicite si le parcours dérape.
class _StatisticsApi extends FakeIvoirepediaApi {
  int statisticsCalls = 0;

  @override
  Future<StatisticsSnapshot> fetchStatistics() async {
    statisticsCalls += 1;

    return statisticsFixture();
  }

  @override
  Future<List<HistoryStory>> fetchHistory() async => const [];

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
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async =>
      const PagedArticles(items: [], page: 1, limit: 12, total: 0);
}

/// Charge réellement renvoyée par `GET /api/v1/statistics` en production,
/// enregistrée telle quelle : elle vérifie que la page supporte la vraie
/// réponse de l'API, pas seulement un jeu écrit à la main.
class _PayloadApi extends _StatisticsApi {
  @override
  Future<StatisticsSnapshot> fetchStatistics() async {
    final payload = jsonDecode(
      File('test/support/statistics_payload.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    return StatisticsSnapshot.fromJson(payload);
  }
}

void main() {
  setUp(() => ivoireMotionEnabled = false);

  Future<void> openStatistics(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _StatisticsApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Statistiques').first);
    await tester.pumpAndSettle();
  }

  testWidgets('les chiffres du recensement et les indicateurs s’affichent',
      (tester) async {
    await openStatistics(tester);

    expect(find.text('La Côte d’Ivoire en chiffres'), findsOneWidget);
    // Population résidente du RGPH 2021, formatée avec des espaces fines.
    expect(find.text('29\u202f389\u202f150'), findsOneWidget);
    expect(find.textContaining('RGPH 2021'), findsWidgets);
    expect(find.text('32 711 547 habitants'), findsOneWidget);
    expect(find.text('Alphabétisation des adultes'), findsOneWidget);
    expect(find.text('47,2 %'), findsOneWidget);
    expect(find.text('Abidjan'), findsWidgets);
    expect(find.text('Bouaké'), findsWidgets);
    expect(find.textContaining('CC BY 4.0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chaque indicateur porte son évolution annuelle moyenne',
      (tester) async {
    await openStatistics(tester);

    // Année la plus récente publiée, affichée en tête de page.
    expect(find.textContaining('à jour jusqu’en 2025'), findsOneWidget);
    expect(find.text('+2,5 % par an (2020-2025)'), findsOneWidget);
    expect(find.text('CROISSANCE ANNUELLE'), findsOneWidget);
    // Le recensement est daté, et l'extrapolation 2026 annoncée comme telle.
    expect(
      find.textContaining('habitants en 2026 : une estimation'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('les vignettes de série portent leur année de début et de fin',
      (tester) async {
    await openStatistics(tester);

    // Espérance de vie : série 2000-2024, bornes affichées sous la courbe.
    expect(find.text('2000'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la pluviométrie affiche les mois et les cumuls annuels',
      (tester) async {
    await openStatistics(tester);

    expect(find.text('PLUVIOMÉTRIE'), findsOneWidget);
    expect(find.textContaining('Normales 1991–2020'), findsOneWidget);
    expect(find.text('Abidjan'), findsWidgets);
    expect(find.text('Korhogo'), findsWidgets);
    // Cumul annuel d'Abidjan et mois le plus arrosé (juin, 253 mm).
    expect(find.textContaining('1\u202f852'), findsWidgets);
    expect(find.textContaining('juin · 253 mm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la réponse réelle de l’API se rend sans erreur', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _PayloadApi()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Statistiques').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('La Côte d’Ivoire en chiffres'), findsOneWidget);
    expect(find.text('29\u202f389\u202f150'), findsOneWidget);
    expect(find.text('Abidjan'), findsWidgets);
  });
}
