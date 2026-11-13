import 'article.dart';

/// Une ligne du recensement pour un lieu (district, région ou ville).
class PlaceEntry {
  const PlaceEntry({
    required this.level,
    required this.label,
    required this.population,
    this.men,
    this.women,
    this.households,
    this.averageSize,
  });

  final String level;
  final String label;
  final int population;
  final int? men;
  final int? women;
  final int? households;
  final double? averageSize;

  factory PlaceEntry.fromJson(Map<String, dynamic> json) {
    return PlaceEntry(
      level: json['level'] as String,
      label: (json['label'] as String?) ?? json['level'] as String,
      population: (json['population'] as num?)?.toInt() ?? 0,
      men: (json['men'] as num?)?.toInt(),
      women: (json['women'] as num?)?.toInt(),
      households: (json['households'] as num?)?.toInt(),
      averageSize: (json['average_size'] as num?)?.toDouble(),
    );
  }
}

/// Résumé climatique d'un lieu, quand la ville est couverte par la climatologie.
class PlaceClimate {
  const PlaceClimate({
    required this.annualRainMm,
    this.slug,
    this.wettestMonth,
    this.wettestMonthRainMm,
    this.averageTemperatureC,
    this.periodStart,
    this.periodEnd,
    this.sourceName,
    this.sourceUrl,
    this.sourceLicence,
  });

  final double annualRainMm;
  final String? slug;
  final int? wettestMonth;
  final double? wettestMonthRainMm;
  final double? averageTemperatureC;
  final int? periodStart;
  final int? periodEnd;
  final String? sourceName;
  final String? sourceUrl;
  final String? sourceLicence;

  factory PlaceClimate.fromJson(Map<String, dynamic> json) {
    final wettest = json['wettest_month'] as Map<String, dynamic>?;
    final period = json['period'] as Map<String, dynamic>?;
    final source = json['source'] as Map<String, dynamic>?;

    return PlaceClimate(
      annualRainMm: (json['annual_rain_mm'] as num?)?.toDouble() ?? 0,
      slug: json['slug'] as String?,
      wettestMonth: (wettest?['month'] as num?)?.toInt(),
      wettestMonthRainMm: (wettest?['rain_mm'] as num?)?.toDouble(),
      averageTemperatureC: (json['average_temperature_c'] as num?)?.toDouble(),
      periodStart: (period?['start'] as num?)?.toInt(),
      periodEnd: (period?['end'] as num?)?.toInt(),
      sourceName: source?['name'] as String?,
      sourceUrl: source?['url'] as String?,
      sourceLicence: source?['licence'] as String?,
    );
  }
}

/// Une région rattachée à un district.
class PlaceChild {
  const PlaceChild({required this.name, required this.slug, required this.population});

  final String name;
  final String slug;
  final int population;

  factory PlaceChild.fromJson(Map<String, dynamic> json) {
    return PlaceChild(
      name: json['name'] as String,
      slug: json['slug'] as String,
      population: (json['population'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Fiche géographique complète (`GET /api/v1/places/{slug}`).
class PlaceDetail {
  const PlaceDetail({
    required this.slug,
    required this.name,
    required this.level,
    required this.entries,
    this.parent,
    this.climate,
    this.articles = const <ArticleSummary>[],
    this.sourceName,
    this.sourceUrl,
  });

  final String slug;
  final String name;
  final String level;
  final List<PlaceEntry> entries;

  /// Département de rattachement (le recensement ne fournit pas le district
  /// d'une région : `parent` est le département, et le champ le dit).
  final String? parent;
  final PlaceClimate? climate;
  final List<ArticleSummary> articles;
  final String? sourceName;
  final String? sourceUrl;

  int get population => entries.isEmpty ? 0 : entries.first.population;

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;

    return PlaceDetail(
      slug: json['slug'] as String,
      name: json['name'] as String,
      level: (json['level'] as String?) ?? '',
      parent: json['parent'] as String?,
      entries: ((json['entries'] as List<dynamic>?) ?? const [])
          .map((entry) => PlaceEntry.fromJson(entry as Map<String, dynamic>))
          .toList(growable: false),
      climate: json['climate'] == null
          ? null
          : PlaceClimate.fromJson(json['climate'] as Map<String, dynamic>),
      articles: ((json['articles'] as List<dynamic>?) ?? const [])
          .map((article) => ArticleSummary.fromJson(article as Map<String, dynamic>))
          .toList(growable: false),
      sourceName: source?['name'] as String?,
      sourceUrl: source?['url'] as String?,
    );
  }
}

/// Annuaire des lieux (`GET /api/v1/places`).
class PlaceDirectory {
  const PlaceDirectory({
    required this.districts,
    required this.regions,
    required this.cities,
    this.censusYear = 2021,
    this.sourceName,
    this.sourceUrl,
  });

  final List<PlaceChild> districts;
  final List<PlaceChild> regions;
  final List<PlaceChild> cities;
  final int censusYear;
  final String? sourceName;
  final String? sourceUrl;

  factory PlaceDirectory.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final source = meta['source'] as Map<String, dynamic>?;

    List<PlaceChild> parse(String key) {
      return ((data[key] as List<dynamic>?) ?? const [])
          .map((item) => PlaceChild.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    }

    return PlaceDirectory(
      districts: parse('districts'),
      regions: parse('regions'),
      cities: parse('cities'),
      censusYear: (meta['census_year'] as num?)?.toInt() ?? 2021,
      sourceName: source?['name'] as String?,
      sourceUrl: source?['url'] as String?,
    );
  }
}
