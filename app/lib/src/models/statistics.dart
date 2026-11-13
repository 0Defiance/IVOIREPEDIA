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
    this.climate = ClimateSnapshot.empty,
    this.updatedAt,
    this.sources = const <String>[],
  });

  final CensusSummary census;
  final List<StatisticIndicator> headline;
  final List<StatisticTheme> themes;
  final List<StatisticDivision> districts;
  final List<StatisticDivision> regions;
  final List<StatisticDivision> cities;
  final ClimateSnapshot climate;
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
      climate: ClimateSnapshot.fromJson(
        (data['climate'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      updatedAt: DateTime.tryParse(meta['updated_at'] as String? ?? ''),

      sources: ((meta['sources'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

/// Normale d'un mois : cumul de pluie, nombre de jours de pluie et température.
class ClimateMonth {
  const ClimateMonth({
    required this.month,
    required this.rainMm,
    this.rainDays,
    this.temperatureC,
  });

  final int month;
  final double rainMm;
  final double? rainDays;
  final double? temperatureC;

  factory ClimateMonth.fromJson(Map<String, dynamic> json) {
    return ClimateMonth(
      month: (json['month'] as num?)?.toInt() ?? 1,
      rainMm: (json['rain_mm'] as num?)?.toDouble() ?? 0,
      rainDays: (json['rain_days'] as num?)?.toDouble(),
      temperatureC: (json['temperature_c'] as num?)?.toDouble(),
    );
  }
}

/// Cumul de pluie d'une année.
class ClimateYear {
  const ClimateYear({required this.year, required this.rainMm});

  final int year;
  final double rainMm;

  factory ClimateYear.fromJson(Map<String, dynamic> json) {
    return ClimateYear(
      year: (json['year'] as num?)?.toInt() ?? 0,
      rainMm: (json['rain_mm'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Climatologie d'une ville : moyennes mensuelles et années observées.
class ClimateCity {
  const ClimateCity({
    required this.slug,
    required this.name,
    required this.annualRainMm,
    required this.months,
    required this.years,
  });

  final String slug;
  final String name;
  final double annualRainMm;
  final List<ClimateMonth> months;
  final List<ClimateYear> years;

  /// Mois le plus arrosé — le repère qui décrit la saison des pluies.
  ClimateMonth? get wettest {
    if (months.isEmpty) {
      return null;
    }

    return months.reduce((a, b) => a.rainMm >= b.rainMm ? a : b);
  }

  /// Année la plus sèche et la plus arrosée de la période de référence.
  double? get driestYear => years.isEmpty
      ? null
      : years.map((year) => year.rainMm).reduce((a, b) => a < b ? a : b);

  double? get wettestYear => years.isEmpty
      ? null
      : years.map((year) => year.rainMm).reduce((a, b) => a > b ? a : b);

  factory ClimateCity.fromJson(Map<String, dynamic> json) {
    final months = (json['months'] as List<dynamic>?) ?? const <dynamic>[];
    final years = (json['years'] as List<dynamic>?) ?? const <dynamic>[];

    return ClimateCity(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      annualRainMm: (json['annual_rain_mm'] as num?)?.toDouble() ?? 0,
      months: months
          .map((item) => ClimateMonth.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      years: years
          .map((item) => ClimateYear.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Bloc climatologique complet, avec sa période de référence et sa licence.
class ClimateSnapshot {
  const ClimateSnapshot({
    this.periodStart,
    this.periodEnd,
    this.source,
    this.cities = const <ClimateCity>[],
  });

  static const ClimateSnapshot empty = ClimateSnapshot();

  final int? periodStart;
  final int? periodEnd;
  final StatisticSource? source;
  final List<ClimateCity> cities;

  bool get isEmpty => cities.isEmpty;

  factory ClimateSnapshot.fromJson(Map<String, dynamic> json) {
    final period = (json['period'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final cities = (json['cities'] as List<dynamic>?) ?? const <dynamic>[];

    return ClimateSnapshot(
      periodStart: (period['start'] as num?)?.toInt(),
      periodEnd: (period['end'] as num?)?.toInt(),
      source: json['source'] is Map<String, dynamic>
          ? StatisticSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      cities: cities
          .map((item) => ClimateCity.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
