/// Bibliothèque des sources : références regroupées par institution.
library;

/// Une référence citée par un ou plusieurs articles.
class SourceReference {
  const SourceReference({
    required this.title,
    this.year,
    this.url,
    this.articles = const [],
  });

  final String title;
  final int? year;
  final String? url;
  final List<SourceArticleLink> articles;

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    final articles = (json['articles'] as List<dynamic>?) ?? const <dynamic>[];

    return SourceReference(
      title: (json['title'] as String?) ?? '',
      year: json['year'] as int?,
      url: json['url'] as String?,
      articles: articles
          .whereType<Map<String, dynamic>>()
          .map(SourceArticleLink.fromJson)
          .toList(growable: false),
    );
  }
}

/// Article qui cite une référence.
class SourceArticleLink {
  const SourceArticleLink({required this.slug, required this.title});

  final String slug;
  final String title;

  factory SourceArticleLink.fromJson(Map<String, dynamic> json) {
    return SourceArticleLink(
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
    );
  }
}

/// Toutes les références d'une institution, avec leur nombre.
class SourceInstitution {
  const SourceInstitution({
    required this.name,
    required this.count,
    this.references = const [],
  });

  final String name;
  final int count;
  final List<SourceReference> references;

  factory SourceInstitution.fromJson(Map<String, dynamic> json) {
    final references = (json['references'] as List<dynamic>?) ?? const <dynamic>[];

    return SourceInstitution(
      name: (json['name'] as String?) ?? '',
      count: (json['count'] as int?) ?? references.length,
      references: references
          .whereType<Map<String, dynamic>>()
          .map(SourceReference.fromJson)
          .toList(growable: false),
    );
  }
}

/// Réponse complète de `GET /api/v1/sources`.
class SourceLibrary {
  const SourceLibrary({
    this.institutions = const [],
    this.institutionCount = 0,
    this.referenceCount = 0,
    this.mentionCount = 0,
    this.articleCount = 0,
  });

  final List<SourceInstitution> institutions;
  final int institutionCount;
  final int referenceCount;
  final int mentionCount;
  final int articleCount;

  bool get isEmpty => institutions.isEmpty;

  factory SourceLibrary.fromJson(Map<String, dynamic> payload) {
    final data = (payload['data'] as List<dynamic>?) ?? const <dynamic>[];
    final meta = (payload['meta'] as Map<String, dynamic>?) ?? const {};

    return SourceLibrary(
      institutions: data
          .whereType<Map<String, dynamic>>()
          .map(SourceInstitution.fromJson)
          .toList(growable: false),
      institutionCount: (meta['institutions'] as int?) ?? data.length,
      referenceCount: (meta['references'] as int?) ?? 0,
      mentionCount: (meta['mentions'] as int?) ?? 0,
      articleCount: (meta['articles'] as int?) ?? 0,
    );
  }
}
