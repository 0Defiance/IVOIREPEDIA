import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'models/article.dart';
import 'models/category.dart';
import 'models/history.dart';
import 'models/statistics.dart';

/// Racine de l'API. En développement : `php artisan serve` sur le port 8000 ;
/// en production : même origine (`--dart-define=API_BASE_URL=/api/v1`).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

/// Erreur d'API exposée aux écrans (message déjà lisible par un humain).
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Contrat de lecture utilisé par les écrans. Les tests fournissent une
/// implémentation en mémoire : aucun réseau n'est nécessaire.
abstract interface class IvoirepediaApi {
  Future<List<Category>> fetchCategories();

  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    int page = 1,
    int limit = 12,
  });

  Future<ArticleDetail> fetchArticle(String slug);

  Future<PagedArticles> search(String query, {int page = 1, int limit = 12});

  Future<StatisticsSnapshot> fetchStatistics();

  Future<List<HistoryStory>> fetchHistory();
}

/// Client HTTP de l'API publique.
class HttpIvoirepediaApi implements IvoirepediaApi {
  HttpIvoirepediaApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<List<Category>> fetchCategories() async {
    final payload = await _get('/categories');
    final data = (payload['data'] as List<dynamic>?) ?? const <dynamic>[];

    return data
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<PagedArticles> fetchArticles({
    String? category,
    String? tag,
    String? query,
    int page = 1,
    int limit = 12,
  }) async {
    final payload = await _get('/articles', {
      if (category != null && category.isNotEmpty) 'category': category,
      if (tag != null && tag.isNotEmpty) 'tag': tag,
      if (query != null && query.isNotEmpty) 'q': query,
      'page': '$page',
      'limit': '$limit',
    });

    return PagedArticles.fromJson(payload);
  }

  @override
  Future<PagedArticles> search(String query, {int page = 1, int limit = 12}) async {
    final payload = await _get('/search', {
      'q': query,
      'page': '$page',
      'limit': '$limit',
    });

    return PagedArticles.fromJson(payload);
  }

  @override
  Future<StatisticsSnapshot> fetchStatistics() async {
    final payload = await _get('/statistics');

    return StatisticsSnapshot.fromJson(payload);
  }

  @override
  Future<List<HistoryStory>> fetchHistory() async {
    final payload = await _get('/history');
    final data = (payload['data'] as List<dynamic>?) ?? const <dynamic>[];

    return data
        .map((item) => HistoryStory.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ArticleDetail> fetchArticle(String slug) async {
    final payload = await _get('/articles/$slug');
    final data = payload['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw const ApiException('Réponse inattendue du serveur.');
    }

    return ArticleDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    late final http.Response response;
    try {
      response = await _client.get(uri, headers: {'Accept': 'application/json'});
    } on Exception {
      throw const ApiException(
        "Impossible de joindre IVOIREPEDIA. Vérifiez votre connexion.",
      );
    }

    if (response.statusCode == 404) {
      throw const ApiException("Cette page n'existe pas ou n'est pas publiée.",
          statusCode: 404);
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Le serveur a répondu ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}

/// Rend l'API accessible à tout l'arbre de widgets (et remplaçable en test).
class ApiScope extends InheritedWidget {
  const ApiScope({required this.api, required super.child, super.key});

  final IvoirepediaApi api;

  static IvoirepediaApi of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ApiScope>();
    assert(scope != null, 'ApiScope manquant au-dessus de ce widget.');
    return scope!.api;
  }

  @override
  bool updateShouldNotify(ApiScope oldWidget) => oldWidget.api != api;
}
