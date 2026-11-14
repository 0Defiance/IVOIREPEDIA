import 'package:ivoirepedia/src/api.dart';
import 'package:ivoirepedia/src/models/article.dart';
import 'package:ivoirepedia/src/models/category.dart';
import 'package:ivoirepedia/src/models/history.dart';
import 'package:ivoirepedia/src/models/place.dart';
import 'package:ivoirepedia/src/models/sources.dart';
import 'package:ivoirepedia/src/models/statistics.dart';
import 'package:ivoirepedia/src/models/suggestion.dart';
import 'package:ivoirepedia/src/models/timeline.dart';

/// API en mémoire : chaque test surcharge ce dont il a besoin.
///
/// Centraliser les valeurs par défaut évite de répéter la même dizaine de
/// méthodes vides dans les cinq fichiers de test, et un nouvel endpoint ne
/// casse plus tous les tests existants.
class FakeIvoirepediaApi implements IvoirepediaApi {
  @override
  Future<List<Category>> fetchCategories() async => const [];

  @override
  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    int page = 1,
    int limit = 12,
  }) async {
    return const PagedArticles(items: [], page: 1, limit: 12, total: 0);
  }

  @override
  Future<ArticleDetail> fetchArticle(String slug) async {
    throw const ApiException("Cet article n'existe pas.", statusCode: 404);
  }

  @override
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async {
    return const PagedArticles(items: [], page: 1, limit: 12, total: 0);
  }

  @override
  Future<StatisticsSnapshot> fetchStatistics() async {
    throw UnimplementedError('fetchStatistics non fourni par ce faux API');
  }

  @override
  Future<List<HistoryStory>> fetchHistory() async => const [];

  @override
  Future<List<TimelineEvent>> fetchTimeline() async => const [];

  @override
  Future<PlaceDirectory> fetchPlaces() async {
    return const PlaceDirectory(districts: [], regions: [], cities: []);
  }

  @override
  Future<PlaceDetail> fetchPlace(String slug) async {
    throw const ApiException("Ce lieu n'existe pas.", statusCode: 404);
  }

  @override
  Future<List<SearchSuggestion>> suggest(String query) async => const [];

  @override
  Future<SourceLibrary> fetchSources() async => const SourceLibrary();
}
