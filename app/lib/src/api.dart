import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'models/article.dart';
import 'models/category.dart';
import 'models/history.dart';
import 'models/place.dart';
import 'models/sources.dart';
import 'models/statistics.dart';
import 'models/suggestion.dart';
import 'models/timeline.dart';

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

  /// Un article publié tiré au hasard par le serveur : le tirage porte sur
  /// toute la base, pas seulement sur la page déjà chargée.
  Future<ArticleSummary> fetchRandomArticle();

  Future<PagedArticles> search(String query, {int page = 1, int limit = 12});

  Future<StatisticsSnapshot> fetchStatistics();

  Future<List<HistoryStory>> fetchHistory();

  Future<List<TimelineEvent>> fetchTimeline();

  Future<PlaceDirectory> fetchPlaces();

  Future<PlaceDetail> fetchPlace(String slug);

  Future<List<SearchSuggestion>> suggest(String query);

  Future<SourceLibrary> fetchSources();

  /// Envoie un message depuis la page « Contact ».
  ///
  /// [website] est le piège à robots : le champ reste vide pour un humain.
  Future<void> sendContactMessage({
    required String message,
    String? name,
    String? email,
    String? website,
  });
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
  Future<ArticleSummary> fetchRandomArticle() async {
    final payload = await _get('/articles/random');
    final data = payload['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw const ApiException('Aucun article à tirer pour le moment.');
    }

    return ArticleSummary.fromJson(data);
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
  Future<List<TimelineEvent>> fetchTimeline() async {
    final payload = await _get('/timeline');
    final data = (payload['data'] as List<dynamic>?) ?? const <dynamic>[];

    return data
        .map((item) => TimelineEvent.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<PlaceDirectory> fetchPlaces() async {
    return PlaceDirectory.fromJson(await _get('/places'));
  }

  @override
  Future<PlaceDetail> fetchPlace(String slug) async {
    final payload = await _get('/places/$slug');
    final data = payload['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw const ApiException('Réponse inattendue du serveur.');
    }

    return PlaceDetail.fromJson(data);
  }

  @override
  Future<List<SearchSuggestion>> suggest(String query) async {
    final payload = await _get('/search/suggest', {'q': query});
    final data = (payload['data'] as List<dynamic>?) ?? const <dynamic>[];

    return data
        .map((item) => SearchSuggestion.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<SourceLibrary> fetchSources() async {
    return SourceLibrary.fromJson(await _get('/sources'));
  }

  @override
  Future<void> sendContactMessage({
    required String message,
    String? name,
    String? email,
    String? website,
  }) async {
    await _post('/contact', {
      'message': message,
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (website != null && website.isNotEmpty) 'website': website,
    });
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

  /// Envoi JSON : 201 pour une création, 422 pour un champ invalide.
  Future<void> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');

    late final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
    } on Exception {
      throw const ApiException(
        'Impossible de joindre IVOIREPEDIA. Vérifiez votre connexion.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 429) {
      throw const ApiException(
        'Trop de messages envoyés. Réessayez dans quelques minutes.',
        statusCode: 429,
      );
    }

    if (response.statusCode == 422) {
      throw ApiException(_validationMessage(response), statusCode: 422);
    }

    throw ApiException(
      'Le serveur a répondu ${response.statusCode}.',
      statusCode: response.statusCode,
    );
  }

  /// Message lisible tiré d'une réponse de validation Laravel.
  String _validationMessage(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data is Map<String, dynamic>) {
        final errors = data['errors'];

        if (errors is Map && errors['message'] is List && (errors['message'] as List).isNotEmpty) {
          return '${(errors['message'] as List).first}';
        }

        final message = data['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      // Corps illisible : on retombe sur le message générique.
    }

    return 'Le message n’a pas pu être envoyé : vérifiez les champs.';
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
