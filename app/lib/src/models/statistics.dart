/// Modèles de la page « La Côte d'Ivoire en chiffres ».
///
/// Les valeurs arrivent déjà mises en forme par l'API (`display`) : l'écran les
/// affiche telles quelles, sans redéfinir les règles de formatage français ni
/// les arrondis. `value` et `series` restent disponibles pour les courbes.
library;

class StatisticSource {
  const StatisticSource({this.name, this.url, this.licence});

  final String? name;
  final String? url;
  final String? licence;

  factory StatisticSource.fromJson(Map<String, dynamic> json) {
    return StatisticSource(
      name: json['name'] as String?,
      url: json['url'] as String?,
      licence: json['licence'] as String?,
    );
  }
}

class StatisticPoint {
  const StatisticPoint({required this.year, required this.value});

  final int year;
  final double value;

  factory StatisticPoint.fromJson(Map<String, dynamic> json) {
    return StatisticPoint(
      year: (json['year'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StatisticIndicator {
  const StatisticIndicator({
    required this.code,
    required this.label,
    required this.display,
    required this.year,
    required this.series,
    this.unit,
    this.source,
  });

  final String code;
  final String label;
  final String? display;
  final String? unit;
  final int? year;
  final StatisticSource? source;
  final List<StatisticPoint> series;

  factory StatisticIndicator.fromJson(Map<String, dynamic> json) {
    final series = (json['series'] as List<dynamic>?) ?? const <dynamic>[];

    return StatisticIndicator(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      display: json['display'] as String?,
      unit: json['unit'] as String?,
      year: (json['year'] as num?)?.toInt(),
      source: json['source'] is Map<String, dynamic>
          ? StatisticSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      series: series
          .map((item) => StatisticPoint.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class StatisticTheme {
  const StatisticTheme({
    required this.code,
    required this.label,
    required this.indicators,
  });

  final String code;
  final String label;
  final List<StatisticIndicator> indicators;

  factory StatisticTheme.fromJson(Map<String, dynamic> json) {
    final indicators = (json['indicators'] as List<dynamic>?) ?? const <dynamic>[];

    return StatisticTheme(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      indicators: indicators
          .map((item) => StatisticIndicator.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class StatisticDivision {
  const StatisticDivision({
    required this.name,
    required this.population,
    this.parent,
    this.households,
    this.averageSize,
  });

  final String name;
  final String? parent;
  final int population;
  final int? households;
  final double? averageSize;

  factory StatisticDivision.fromJson(Map<String, dynamic> json) {
    return StatisticDivision(
      name: json['name'] as String? ?? '',
      parent: json['parent'] as String?,
      population: (json['population'] as num?)?.toInt() ?? 0,
      households: (json['households'] as num?)?.toInt(),
      averageSize: (json['average_size'] as num?)?.toDouble(),
    );
  }
}

class CensusSummary {
  const CensusSummary({
    required this.year,
    required this.population,
    required this.households,
    required this.averageSize,
    required this.womenShare,
    this.source,
  });

  final int year;
  final int population;
  final int households;
  final double averageSize;
  final double womenShare;
  final StatisticSource? source;

  factory CensusSummary.fromJson(Map<String, dynamic> json) {
    return CensusSummary(
      year: (json['year'] as num?)?.toInt() ?? 0,
      population: (json['population'] as num?)?.toInt() ?? 0,
      households: (json['households'] as num?)?.toInt() ?? 0,
      averageSize: (json['average_size'] as num?)?.toDouble() ?? 0,
      womenShare: (json['women_share'] as num?)?.toDouble() ?? 0,
      source: json['source'] is Map<String, dynamic>
          ? StatisticSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.census,
    required this.headline,
    required this.themes,
    required this.districts,
    required this.regions,
    required this.cities,
    this.updatedAt,
    this.sources = const <String>[],
  });

  final CensusSummary census;
  final List<StatisticIndicator> headline;
  final List<StatisticTheme> themes;
  final List<StatisticDivision> districts;
  final List<StatisticDivision> regions;
  final List<StatisticDivision> cities;
  final DateTime? updatedAt;
  final List<String> sources;

  factory StatisticsSnapshot.fromJson(Map<String, dynamic> payload) {
    final data = (payload['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final divisions = (data['divisions'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final meta = (payload['meta'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    List<StatisticDivision> read(String key) {
      final rows = (divisions[key] as List<dynamic>?) ?? const <dynamic>[];
      return rows
          .map((item) => StatisticDivision.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    }

    return StatisticsSnapshot(
      census: CensusSummary.fromJson(
        (data['census'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      headline: ((data['headline'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => StatisticIndicator.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      themes: ((data['themes'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => StatisticTheme.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      districts: read('districts'),
      regions: read('regions'),
      cities: read('cities'),
      updatedAt: DateTime.tryParse(meta['updated_at'] as String? ?? ''),
      sources: ((meta['sources'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}
