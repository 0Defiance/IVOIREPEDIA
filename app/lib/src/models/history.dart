/// Récits de la section « Histoire incroyable ».
///
/// Le contenu est servi par `GET /api/v1/history` : chaque récit porte sa
/// période, son texte et la source qui le documente.
library;

class HistoryFigure {
  const HistoryFigure({required this.label, required this.value});

  final String label;
  final String value;

  factory HistoryFigure.fromJson(Map<String, dynamic> json) {
    return HistoryFigure(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}

class HistorySource {
  const HistorySource({
    required this.title,
    this.publisher,
    this.year,
    this.url,
  });

  final String title;
  final String? publisher;
  final int? year;
  final String? url;

  factory HistorySource.fromJson(Map<String, dynamic> json) {
    return HistorySource(
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String?,
      year: (json['year'] as num?)?.toInt(),
      url: json['url'] as String?,
    );
  }
}

class HistoryStory {
  const HistoryStory({
    required this.slug,
    required this.title,
    required this.teaser,
    required this.paragraphs,
    required this.source,
    this.period,
    this.figures = const <HistoryFigure>[],
  });

  final String slug;
  final String title;
  final String? period;
  final String teaser;
  final List<String> paragraphs;
  final List<HistoryFigure> figures;
  final HistorySource source;

  factory HistoryStory.fromJson(Map<String, dynamic> json) {
    final paragraphs = (json['paragraphs'] as List<dynamic>?) ?? const <dynamic>[];
    final figures = (json['figures'] as List<dynamic>?) ?? const <dynamic>[];

    return HistoryStory(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      period: json['period'] as String?,
      teaser: json['teaser'] as String? ?? '',
      paragraphs: paragraphs.map((item) => item.toString()).toList(growable: false),
      figures: figures
          .map((item) => HistoryFigure.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      source: HistorySource.fromJson(
        (json['source'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
    );
  }
}
