import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/place.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/interactive.dart';

/// Fiche d'un lieu : population du recensement, climat, articles liés.
class PlacePage extends StatefulWidget {
  const PlacePage({required this.slug, super.key});

  final String slug;

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  Future<PlaceDetail>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchPlace(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return SiteShell(
      child: FutureBuilder<PlaceDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final notFound = snapshot.error is ApiException &&
                (snapshot.error as ApiException).statusCode == 404;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notFound ? 'Lieu inconnu' : 'Service indisponible',
                    style: titleStyle(size: 24, weight: FontWeight.w700, color: tone.ink),
                  ),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}',
                      style: TextStyle(fontSize: 14, color: tone.muted)),
                  const SizedBox(height: 18),
                  OutlinedButton(
                    onPressed: () => context.go('/lieux'),
                    child: const Text('Voir tous les lieux'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 180, height: 12),
                  SizedBox(height: 12),
                  Skeleton(width: 320, height: 30),
                  SizedBox(height: 22),
                  SkeletonParagraph(lines: 3),
                ],
              ),
            );
          }

          return _PlaceBody(place: snapshot.data!);
        },
      ),
    );
  }
}

class _PlaceBody extends StatelessWidget {
  const _PlaceBody({required this.place});

  final PlaceDetail place;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final levelLabel = switch (place.level) {
      'district' => 'District',
      'region' => 'Région',
      _ => 'Ville',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HoverLink(
                  label: 'Accueil',
                  onTap: () => context.go('/'),
                  style: TextStyle(fontSize: 12, color: tone.muted),
                ),
                Text('›', style: TextStyle(fontSize: 12, color: tone.faint)),
                HoverLink(
                  label: 'Villes et régions',
                  onTap: () => context.go('/lieux'),
                  style: TextStyle(fontSize: 12, color: tone.muted),
                ),
                Text('›', style: TextStyle(fontSize: 12, color: tone.faint)),
                Text(place.name, style: TextStyle(fontSize: 12, color: tone.faint)),
              ],
            ),
            const SizedBox(height: 12),
            Text(levelLabel.toUpperCase(), style: kickerStyle()),
            const SizedBox(height: 4),
            Text(
              place.name,
              style: titleStyle(size: 32, weight: FontWeight.w600, color: tone.ink),
            ),
            if (place.parent != null && place.parent != place.name) ...[
              const SizedBox(height: 4),
              Text(
                'Département de ${place.parent}',
                style: TextStyle(fontSize: 13, color: tone.muted),
              ),
            ],
            const SizedBox(height: 12),
            Container(height: 1, color: tone.line),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 780;

                final left = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PopulationBlock(place: place),
                    const SizedBox(height: 22),
                    _EntriesTable(entries: place.entries),
                  ],
                );

                final right = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (place.climate != null) _ClimateCard(climate: place.climate!),
                    if (place.articles.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _RelatedArticles(place: place),
                    ],
                  ],
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [left, const SizedBox(height: 24), right],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    const SizedBox(width: 28),
                    Expanded(flex: 2, child: right),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            Text(
              'Population : ${place.sourceName ?? 'ANStat — RGPH 2021'}.',
              style: TextStyle(fontSize: 12, color: tone.faint),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopulationBlock extends StatelessWidget {
  const _PopulationBlock({required this.place});

  final PlaceDetail place;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: tone.subtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POPULATION RÉSIDENTE — RGPH 2021',
            style: kickerStyle(color: tone.faint),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatNumber(place.population),
                style: titleStyle(size: 34, weight: FontWeight.w700, color: tone.ink),
              ),
              const SizedBox(width: 6),
              Text('habitants', style: TextStyle(fontSize: 13, color: tone.muted)),
            ],
          ),
          if (place.estimate != null) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: tone.lineSoft),
            const SizedBox(height: 12),
            Text(
              '≈ ${formatNumber(place.estimate!.population)} habitants en '
              '${place.estimate!.year}',
              style: titleStyle(size: 17, weight: FontWeight.w600, color: tone.ink),
            ),
            const SizedBox(height: 4),
            if (place.estimate!.basis != null)
              Text(
                place.estimate!.basis!,
                style: TextStyle(fontSize: 12, height: 1.5, color: tone.muted),
              ),
            if (place.estimate!.note != null) ...[
              const SizedBox(height: 2),
              Text(
                place.estimate!.note!,
                style: TextStyle(fontSize: 11.5, height: 1.5, color: tone.faint),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _EntriesTable extends StatelessWidget {
  const _EntriesTable({required this.entries});

  final List<PlaceEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Détail du recensement',
            style: titleStyle(size: 17, weight: FontWeight.w600, color: tone.ink)),
        const SizedBox(height: 8),
        for (final entry in entries)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tone.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tone.lineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: IvoireColors.terracotta,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 26,
                  runSpacing: 8,
                  children: [
                    _figure('Population', formatNumber(entry.population)),
                    if (entry.men != null) _figure('Hommes', formatNumber(entry.men!)),
                    if (entry.women != null) _figure('Femmes', formatNumber(entry.women!)),
                    if (entry.households != null)
                      _figure('Ménages', formatNumber(entry.households!)),
                    if (entry.averageSize != null)
                      _figure('Taille moyenne',
                          '${entry.averageSize!.toStringAsFixed(1)} pers.'),
                  ],
                ),
              ],
            ),
          ),
        Text(
          'Ces effectifs proviennent du tableau officiel du recensement ; '
          'ils ne sont ni estimés ni extrapolés.',
          style: TextStyle(fontSize: 11.5, height: 1.5, color: tone.faint),
        ),
      ],
    );
  }

  Widget _figure(String label, String value) {
    return Builder(
      builder: (context) {
        final tone = ToneColors.from(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: tone.faint)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: tone.ink)),
          ],
        );
      },
    );
  }
}

class _ClimateCard extends StatelessWidget {
  const _ClimateCard({required this.climate});

  final PlaceClimate climate;

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final period = climate.periodStart == null || climate.periodEnd == null
        ? 'Normales 1991-2020'
        : 'Normales ${climate.periodStart}-${climate.periodEnd}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, size: 16, color: IvoireColors.green),
              const SizedBox(width: 6),
              Text('Climat',
                  style: titleStyle(size: 16, weight: FontWeight.w600, color: tone.ink)),
            ],
          ),
          const SizedBox(height: 4),
          Text(period, style: TextStyle(fontSize: 11.5, color: tone.faint)),
          const SizedBox(height: 12),
          _row('Pluie par an', '${formatNumber(climate.annualRainMm.round())} mm', tone),
          if (climate.wettestMonth != null)
            _row(
              'Mois le plus arrosé',
              '${_months[climate.wettestMonth! - 1]} · '
                  '${formatNumber((climate.wettestMonthRainMm ?? 0).round())} mm',
              tone,
            ),
          if (climate.averageTemperatureC != null)
            _row('Température moyenne',
                '${climate.averageTemperatureC!.toStringAsFixed(1)} °C', tone),
          const SizedBox(height: 12),
          HoverLink(
            label: 'Voir la pluviométrie détaillée',
            onTap: () => context.go('/statistiques'),
            style: const TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Text(
            'Réanalyse ERA5 (Open-Meteo), licence ${climate.sourceLicence ?? 'CC BY 4.0'}.',
            style: TextStyle(fontSize: 10.5, height: 1.4, color: tone.faint),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, ToneColors tone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.5, color: tone.muted)),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: tone.ink),
          ),
        ],
      ),
    );
  }
}

class _RelatedArticles extends StatelessWidget {
  const _RelatedArticles({required this.place});

  final PlaceDetail place;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Articles liés',
            style: titleStyle(size: 17, weight: FontWeight.w600, color: tone.ink)),
        const SizedBox(height: 8),
        for (final article in place.articles)
          GestureDetector(
            onTap: () => context.go('/articles/${article.slug}'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: tone.lineSoft)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: IvoireColors.link,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, height: 1.5, color: tone.muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
