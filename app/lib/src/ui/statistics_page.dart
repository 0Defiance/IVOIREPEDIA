import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/statistics.dart';
import '../theme.dart';
import 'shell.dart';
import 'widgets/charts.dart';

/// Page des statistiques nationales : recensement, indicateurs annuels et
/// divisions administratives, avec la source et l'année de chaque chiffre.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<StatisticsSnapshot>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchStatistics();
  }

  void _retry() {
    setState(() => _future = ApiScope.of(context).fetchStatistics());
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: FutureBuilder<StatisticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(
              text: '${snapshot.error}',
              action: _retry,
            );
          }

          if (!snapshot.hasData) {
            return const _Message(text: 'Chargement des chiffres…');
          }

          return _StatisticsBody(data: snapshot.data!);
        },
      ),
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.data});

  final StatisticsSnapshot data;

  @override
  Widget build(BuildContext context) {
    final census = data.census;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DONNÉES · CÔTE D’IVOIRE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: IvoireColors.orangeDeep,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La Côte d’Ivoire en chiffres',
            style: TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: IvoireColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Population, économie, santé, éducation, environnement : chaque '
              'valeur porte son année et sa source. Le recensement fournit les '
              'effectifs datés, la Banque mondiale les séries annuelles.',
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: IvoireColors.muted.withValues(alpha: 0.95),
              ),
            ),
          ),
          if (data.dataThrough != null) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.update, size: 15, color: IvoireColors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Séries annuelles à jour jusqu’en ${data.dataThrough} · '
                    'recensement : RGPH ${data.census.year}.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: IvoireColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _CensusPanel(census: census),
          if (data.headline.isNotEmpty) ...[
            const SizedBox(height: 28),
            _HeadlineGrid(indicators: data.headline),
          ],
          if (!data.climate.isEmpty) ...[
            const SizedBox(height: 34),
            _ClimateSection(climate: data.climate),
          ],
          for (final theme in data.themes) ...[
            const SizedBox(height: 34),
            _ThemeSection(theme: theme),
          ],
          if (data.districts.isNotEmpty) ...[
            const SizedBox(height: 34),
            _DivisionsSection(
              title: 'Les districts',
              caption:
                  'Population résidente au 14 décembre 2021, par district. '
                  'Abidjan et Yamoussoukro sont des districts autonomes.',
              divisions: data.districts,
            ),
          ],
          if (data.regions.isNotEmpty) ...[
            const SizedBox(height: 30),
            _DivisionsSection(
              title: 'Les régions',
              caption: 'Effectifs du RGPH 2021, du plus peuplé au moins peuplé.',
              divisions: data.regions,
              dense: true,
            ),
          ],
          if (data.cities.isNotEmpty) ...[
            const SizedBox(height: 30),
            _DivisionsSection(
              title: 'Les grandes villes',
              caption:
                  'Population communale au RGPH 2021. Elle inclut les villages '
                  'rattachés à la commune, d’où des écarts avec les chiffres de '
                  'l’agglomération urbaine.',
              divisions: data.cities.take(20).toList(growable: false),
              dense: true,
            ),
          ],
          const SizedBox(height: 36),
          _SourcesFooter(data: data),
        ],
      ),
    );
  }
}

class _CensusPanel extends StatelessWidget {
  const _CensusPanel({required this.census});

  final CensusSummary census;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: IvoireColors.sand.withValues(alpha: 0.5),
        border: Border.all(color: IvoireColors.lineSoft),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POPULATION RÉSIDENTE · RGPH ${census.year}',
            style: const TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: IvoireColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _thousands(census.population),
            style: const TextStyle(
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: IvoireColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 30,
            runSpacing: 12,
            children: [
              _MiniFact(label: 'Ménages', value: _thousands(census.households)),
              _MiniFact(
                label: 'Taille moyenne',
                value: '${_decimal(census.averageSize)} personnes',
              ),
              _MiniFact(
                label: 'Part des femmes',
                value: '${_decimal(census.womenShare)} %',
              ),
              if (census.growthPercent != null)
                _MiniFact(
                  label: 'Croissance annuelle',
                  value: '${_decimal(census.growthPercent!)} % '
                      '(${census.growthYear ?? ''})',
                ),
            ],
          ),
          if (census.growthPercent != null) ...[
            const SizedBox(height: 12),
            Text(
              'Avec cette croissance, la population de 2021 correspond à environ '
              '${_thousands((census.population * math.pow(1 + census.growthPercent! / 100, 2026 - census.year)).round())} '
              'habitants en 2026 : une estimation, pas un recensement.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.55,
                color: IvoireColors.muted,
              ),
            ),
          ],
          if (census.source?.name != null) ...[
            const SizedBox(height: 14),
            _SourceLine(source: census.source),
          ],
        ],
      ),
    );
  }
}

/// Évolution annuelle moyenne : la flèche dit le sens, le texte la valeur.
class _TrendLabel extends StatelessWidget {
  const _TrendLabel({required this.trend, required this.fontSize});

  final StatisticTrend trend;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = trend.isUp
        ? IvoireColors.green
        : (trend.isDown ? IvoireColors.orangeDeep : IvoireColors.faint);
    final icon = trend.isUp
        ? Icons.trending_up
        : (trend.isDown ? Icons.trending_down : Icons.trending_flat);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: fontSize + 1, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            trend.display,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.4,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniFact extends StatelessWidget {
  const _MiniFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            color: IvoireColors.faint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: IvoireColors.ink,
          ),
        ),
      ],
    );
  }
}

class _HeadlineGrid extends StatelessWidget {
  const _HeadlineGrid({required this.indicators});

  final List<StatisticIndicator> indicators;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 560 ? 2 : 1);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final indicator in indicators)
              SizedBox(
                width: width,
                child: _HeadlineCard(indicator: indicator),
              ),
          ],
        );
      },
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.indicator});

  final StatisticIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indicator.label,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: IvoireColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          // Un PIB en unités s'écrit long : on réduit plutôt que de tronquer.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              indicator.display ?? '—',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: IvoireColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            indicator.year == null ? '' : 'Donnée ${indicator.year}',
            style: const TextStyle(fontSize: 11, color: IvoireColors.faint),
          ),
          if (indicator.trend != null) ...[
            const SizedBox(height: 4),
            _TrendLabel(trend: indicator.trend!, fontSize: 11.5),
          ],
          if (indicator.series.length > 2) ...[
            const SizedBox(height: 8),
            YearLineChart(points: indicator.series, height: 96),
          ],
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({required this.theme});

  final StatisticTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          theme.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
            color: IvoireColors.green,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: IvoireColors.lineSoft),
        const SizedBox(height: 6),
        for (final indicator in theme.indicators)
          _IndicatorRow(indicator: indicator),
      ],
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.indicator});

  final StatisticIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final hasSeries = indicator.series.length > 2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator.label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: IvoireColors.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (indicator.year != null) '${indicator.year}',
                    if (indicator.source?.name != null) indicator.source!.name!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 10.5, color: IvoireColors.faint),
                ),
                if (indicator.trend != null) ...[
                  const SizedBox(height: 3),
                  _TrendLabel(trend: indicator.trend!, fontSize: 11),
                ],
              ],
            ),
          ),
          if (hasSeries) ...[
            const SizedBox(width: 12),
            Sparkline(points: indicator.series, width: 84, height: 22),
          ],
          const SizedBox(width: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, maxWidth: 190),
            child: Text(
              indicator.display ?? '—',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: IvoireColors.ink,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionsSection extends StatelessWidget {
  const _DivisionsSection({
    required this.title,
    required this.caption,
    required this.divisions,
    this.dense = false,
  });

  final String title;
  final String caption;
  final List<StatisticDivision> divisions;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final max = divisions.fold<int>(1, (value, item) => math.max(value, item.population));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
            color: IvoireColors.green,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: IvoireColors.lineSoft),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            caption,
            style: const TextStyle(fontSize: 12, height: 1.6, color: IvoireColors.faint),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = dense && constraints.maxWidth > 760 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 24) / columns;

            return Wrap(
              spacing: 24,
              runSpacing: 4,
              children: [
                for (final division in divisions)
                  SizedBox(
                    width: width,
                    child: _DivisionRow(division: division, max: max),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DivisionRow extends StatelessWidget {
  const _DivisionRow({required this.division, required this.max});

  final StatisticDivision division;
  final int max;

  @override
  Widget build(BuildContext context) {
    final ratio = (division.population / max).clamp(0.02, 1.0);
    final slug = division.slug;

    return GestureDetector(
      onTap: slug == null || slug.isEmpty
          ? null
          : () => context.go('/lieux/$slug'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  division.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: IvoireColors.ink),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _thousands(division.population),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: IvoireColors.ink,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 3,
                    backgroundColor: IvoireColors.subtle,
                    valueColor: const AlwaysStoppedAnimation(IvoireColors.green),
                  ),
                ),
              ),
              if (division.households != null) ...[
                const SizedBox(width: 10),
                Text(
                  '${_thousands(division.households!)} ménages',
                  style: const TextStyle(fontSize: 10.5, color: IvoireColors.faint),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }
}

/// Pluviométrie : le régime des pluies mois par mois, et sa variabilité d'une
/// année à l'autre. Une moyenne annuelle seule ne dit rien de la saison.
class _ClimateSection extends StatefulWidget {
  const _ClimateSection({required this.climate});

  final ClimateSnapshot climate;

  @override
  State<_ClimateSection> createState() => _ClimateSectionState();
}

class _ClimateSectionState extends State<_ClimateSection> {
  int _selected = 0;

  static const List<String> _monthNames = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  @override
  Widget build(BuildContext context) {
    final climate = widget.climate;

    if (climate.cities.isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = climate.cities[_selected.clamp(0, climate.cities.length - 1)];
    final wettest = selected.wettest;
    final years = selected.years
        .map((year) => StatisticPoint(year: year.year, value: year.rainMm))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PLUVIOMÉTRIE',
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
                color: IvoireColors.green,
              ),
            ),
            if (climate.periodStart != null && climate.periodEnd != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: IvoireColors.subtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: IvoireColors.lineSoft),
                ),
                child: Text(
                  'Normales ${climate.periodStart}–${climate.periodEnd}',
                  style: const TextStyle(fontSize: 10.5, color: IvoireColors.muted),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: IvoireColors.lineSoft),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Cumuls mensuels moyens et température moyenne, calculés sur '
            '${climate.periodStart ?? 1991}–${climate.periodEnd ?? 2020} à partir de la '
            'réanalyse ERA5 (grille d’environ 9 km). Une année donnée s’écarte '
            'toujours de cette moyenne : la courbe du bas montre l’amplitude '
            'réelle des trente années observées.',
            style: const TextStyle(fontSize: 12, height: 1.7, color: IvoireColors.faint),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < climate.cities.length; index++)
              _CityChip(
                label: climate.cities[index].name,
                selected: index == _selected,
                onTap: () => setState(() => _selected = index),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: IvoireColors.paper,
            border: Border.all(color: IvoireColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 30,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLUIE PAR AN · ${selected.name.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                          color: IvoireColors.faint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _thousands(selected.annualRainMm.round()),
                              style: const TextStyle(
                                fontSize: 30,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: IvoireColors.ink,
                              ),
                            ),
                            const TextSpan(
                              text: ' mm',
                              style: TextStyle(fontSize: 13, color: IvoireColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (wettest != null)
                    _MiniFact(
                      label: 'Mois le plus arrosé',
                      value: '${_monthNames[wettest.month - 1]} · '
                          '${wettest.rainMm.round()} mm',
                    ),
                  if (selected.driestYear != null)
                    _MiniFact(
                      label: 'Année la plus sèche',
                      value: '${_thousands(selected.driestYear!.round())} mm',
                    ),
                  if (selected.wettestYear != null)
                    _MiniFact(
                      label: 'Année la plus arrosée',
                      value: '${_thousands(selected.wettestYear!.round())} mm',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              MonthlyRainChart(months: selected.months),
              if (years.length > 2) ...[
                const SizedBox(height: 18),
                const Text(
                  'CUMULS ANNUELS OBSERVÉS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: IvoireColors.faint,
                  ),
                ),
                const SizedBox(height: 6),
                YearLineChart(points: years, height: 140),
              ],
              if (climate.source?.name != null) ...[
                const SizedBox(height: 10),
                _SourceLine(source: climate.source),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? IvoireColors.green : IvoireColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? IvoireColors.green : IvoireColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : IvoireColors.muted,
          ),
        ),
      ),
    );
  }
}

class _SourcesFooter extends StatelessWidget {
  const _SourcesFooter({required this.data});

  final StatisticsSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: IvoireColors.lineSoft),
        const SizedBox(height: 14),
        const Text(
          'SOURCES ET LICENCES',
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: IvoireColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            [
              'Recensement général de la population et de l’habitat 2021 '
                  '(ANStat, ex-INS), Licence Ouverte.',
              if (data.sources.isNotEmpty) '${data.sources.join(', ')} (CC BY 4.0).',
              'Les chiffres sont publiés tels quels : une estimation annuelle et '
                  'un recensement ne mesurent pas la même chose et ne doivent pas '
                  'être additionnés ni comparés sans le dire.',
            ].join(' '),
            style: const TextStyle(fontSize: 11.5, height: 1.7, color: IvoireColors.faint),
          ),
        ),
        if (data.updatedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Dernière synchronisation : ${_date(data.updatedAt!)}',
            style: const TextStyle(fontSize: 11, color: IvoireColors.faint),
          ),
        ],
      ],
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source});

  final StatisticSource? source;

  @override
  Widget build(BuildContext context) {
    if (source?.name == null) {
      return const SizedBox.shrink();
    }

    return Text(
      'Source : ${source!.name!}'
      '${source!.licence == null ? '' : ' — ${source!.licence}'}',
      style: const TextStyle(fontSize: 11, color: IvoireColors.faint),
    );
  }
}

/// Courbe de tendance minimale : une ligne, sans axes ni libellés.
class Sparkline extends StatelessWidget {
  const Sparkline({
    required this.points,
    this.width = 80,
    this.height = 24,
    super.key,
  });

  final List<StatisticPoint> points;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparklinePainter(points)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points);

  final List<StatisticPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    var min = points.first.value;
    var max = points.first.value;

    for (final point in points) {
      min = math.min(min, point.value);
      max = math.max(max, point.value);
    }

    final span = max - min;
    final step = size.width / (points.length - 1);
    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final x = step * index;
      final ratio = span == 0 ? 0.5 : (points[index].value - min) / span;
      final y = size.height - 2 - ratio * (size.height - 4);

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = IvoireColors.green.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => oldDelegate.points != points;
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: IvoireColors.muted),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: action,
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}

/// « 29 389 150 » — espace insécable comme séparateur de milliers.
String _thousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('\u202f');
    }
    buffer.write(digits[index]);
  }

  return '${value < 0 ? '−' : ''}$buffer';
}

/// « 5,2 » — virgule décimale, une décimale.
String _decimal(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
