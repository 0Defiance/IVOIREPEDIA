/// Article tel qu'affiché dans une liste (`GET /api/v1/articles`).
class ArticleSummary {
  const ArticleSummary({
    required this.slug,
    required this.title,
    required this.summary,
    required this.typeLabel,
    this.categoryName,
    this.categorySlug,
    this.authorName,
    this.publishedAt,
    this.readingMinutes = 1,
    this.coverImageUrl,
    this.coverImageAlt,
  });

  final String slug;
  final String title;
  final String summary;
  final String typeLabel;
  final String? categoryName;
  final String? categorySlug;
  final String? authorName;
  final DateTime? publishedAt;
  final int readingMinutes;
  final String? coverImageUrl;
  final String? coverImageAlt;

  factory ArticleSummary.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final author = json['author'] as Map<String, dynamic>?;
    final published = json['published_at'] as String?;

    return ArticleSummary(
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      typeLabel: (json['type_label'] as String?) ?? 'Sujet',
      categoryName: category?['name'] as String?,
      categorySlug: category?['slug'] as String?,
      authorName: author?['name'] as String?,
      publishedAt: published == null ? null : DateTime.tryParse(published),
      readingMinutes: (json['reading_minutes'] as num?)?.toInt() ?? 1,
      coverImageUrl: json['cover_image_url'] as String?,
      coverImageAlt: json['cover_image_alt'] as String?,
    );
  }
}

/// Référence bibliographique numérotée d'un article.
class ArticleReference {
  const ArticleReference({
    required this.position,
    required this.title,
    this.authors,
    this.publisher,
    this.year,
    this.url,
  });

  final int position;
  final String title;
  final String? authors;
  final String? publisher;
  final int? year;
  final String? url;

  factory ArticleReference.fromJson(Map<String, dynamic> json) {
    return ArticleReference(
      position: (json['position'] as num).toInt(),
      title: json['title'] as String,
      authors: json['authors'] as String?,
      publisher: json['publisher'] as String?,
      year: (json['year'] as num?)?.toInt(),
      url: json['url'] as String?,
    );
  }
}

/// Article complet (`GET /api/v1/articles/{slug}`).
class ArticleDetail extends ArticleSummary {
  const ArticleDetail({
    required super.slug,
    required super.title,
    required super.summary,
    required super.typeLabel,
    required this.contentOps,
    this.infobox,
    this.references = const <ArticleReference>[],
    this.tags = const <String>[],
    super.categoryName,
    super.categorySlug,
    super.authorName,
    super.publishedAt,
    super.readingMinutes,
    super.coverImageUrl,
    super.coverImageAlt,
  });

  /// Opérations Delta Quill (`content.ops`) : source de vérité du texte.
  final List<Map<String, dynamic>> contentOps;
  final Map<String, dynamic>? infobox;
  final List<ArticleReference> references;
  final List<String> tags;

  factory ArticleDetail.fromJson(Map<String, dynamic> json) {
    final base = ArticleSummary.fromJson(json);
    final content = json['content'] as Map<String, dynamic>?;
    final ops = (content?['ops'] as List<dynamic>?) ?? const <dynamic>[];
    final tags = (json['tags'] as List<dynamic>?) ?? const <dynamic>[];
    final references = (json['references'] as List<dynamic>?) ?? const <dynamic>[];

    return ArticleDetail(
      slug: base.slug,
      title: base.title,
      summary: base.summary,
      typeLabel: base.typeLabel,
      categoryName: base.categoryName,
      categorySlug: base.categorySlug,
      authorName: base.authorName,
      publishedAt: base.publishedAt,
      readingMinutes: base.readingMinutes,
      coverImageUrl: base.coverImageUrl,
      coverImageAlt: base.coverImageAlt,
      contentOps: ops
          .whereType<Map<String, dynamic>>()
          .toList(growable: false),
      infobox: json['infobox'] as Map<String, dynamic>?,
      tags: tags
          .map((tag) => (tag as Map<String, dynamic>)['name'] as String)
          .toList(growable: false),
      references: references
          .map((ref) => ArticleReference.fromJson(ref as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Page de résultats : `{ data, meta: { page, limit, total } }`.
class PagedArticles {
  const PagedArticles({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<ArticleSummary> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;

  factory PagedArticles.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final data = (json['data'] as List<dynamic>?) ?? const <dynamic>[];

    return PagedArticles(
      items: data
          .map((item) => ArticleSummary.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? data.length,
      total: (meta['total'] as num?)?.toInt() ?? data.length,
    );
  }
}
