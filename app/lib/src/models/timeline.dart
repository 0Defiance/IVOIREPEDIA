/// Un jalon de la frise chronologique (`GET /api/v1/timeline`).
///
/// Le jalon est construit à partir d'un récit : il renvoie vers lui plutôt que
/// de dupliquer son texte.
class TimelineEvent {
  const TimelineEvent({
    required this.slug,
    required this.year,
    required this.era,
    required this.title,
    required this.teaser,
    this.period,
    this.sourceTitle,
    this.sourcePublisher,
    this.sourceYear,
    this.sourceUrl,
  });

  final String slug;
  final int year;
  final String era;
  final String title;
  final String teaser;
  final String? period;
  final String? sourceTitle;
  final String? sourcePublisher;
  final int? sourceYear;
  final String? sourceUrl;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;

    return TimelineEvent(
      slug: json['slug'] as String,
      year: (json['year'] as num).toInt(),
      era: (json['era'] as String?) ?? '',
      title: json['title'] as String,
      teaser: (json['teaser'] as String?) ?? '',
      period: json['period'] as String?,
      sourceTitle: source?['title'] as String?,
      sourcePublisher: source?['publisher'] as String?,
      sourceYear: (source?['year'] as num?)?.toInt(),
      sourceUrl: source?['url'] as String?,
    );
  }
}
