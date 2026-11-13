import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/app.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/statistics.dart';
import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

import 'support/history_fixture.dart';
import 'support/statistics_fixture.dart';
import 'support/fake_api.dart';

/// API minimale : la section n'a besoin que des récits et des catégories.
class _HistoryApi extends FakeIvoirepediaApi {
  @override
  Future<List<HistoryStory>> fetchHistory() async => historyFixture();

  @override
  Future<List<Category>> fetchCategories() async => const [];

  @override
  Future<StatisticsSnapshot> fetchStatistics() async => statisticsFixture();

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

void main() {
  setUp(() => ivoireMotionEnabled = false);

  testWidgets('on atteint les récits depuis la barre latérale', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _HistoryApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histoire incroyable').first);
    await tester.pumpAndSettle();

    expect(find.text('Histoires incroyables'), findsOneWidget);
    expect(
      find.text('La capitale abandonnée à cause des moustiques'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('un récit se déplie et affiche sa source', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(IvoirepediaApp(api: _HistoryApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histoire incroyable').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lire le récit').first);
    await tester.pumpAndSettle();

    expect(find.text('SOURCE'), findsWidgets);
    expect(
      find.textContaining('Ville historique de Grand-Bassam'),
      findsOneWidget,
    );
    expect(find.textContaining('whc.unesco.org/fr/list/1322'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
