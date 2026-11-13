import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/place.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/interactive.dart';

/// Annuaire géographique : districts, régions et villes du RGPH 2021.
///
/// Chaque ligne mène à une fiche déjà remplie (population, climat, articles
/// liés), ce qui donne au site autant de pages utiles que de lieux.
class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  Future<PlaceDirectory>? _future;
  final TextEditingController _filter = TextEditingController();
  String _term = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchPlaces();
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  bool _matches(PlaceChild place) =>
      _term.isEmpty || place.name.toLowerCase().contains(_term.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GÉOGRAPHIE DE LA CÔTE D’IVOIRE', style: kickerStyle()),
            const SizedBox(height: 6),
            Text(
              'Villes, régions et districts',
              style: titleStyle(size: 30, weight: FontWeight.w600, color: tone.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Population résidente au 14 décembre 2021, telle que publiée par '
              'l’ANStat. Ouvrez une fiche pour le détail, le climat et les '
              'articles qui parlent du lieu.',
              style: TextStyle(fontSize: 14.5, height: 1.65, color: tone.muted),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                controller: _filter,
                onChanged: (value) => setState(() => _term = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Filtrer un district, une région, une ville…',
                  prefixIcon: const Icon(Icons.place_outlined, size: 19),
                  suffixIcon: _term.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer',
                          icon: const Icon(Icons.close, size: 17),
                          onPressed: () {
                            _filter.clear();
                            setState(() => _term = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<PlaceDirectory>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}',
                      style: TextStyle(fontSize: 14, color: tone.ink));
                }

                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Skeleton(width: 260, height: 14),
                      SizedBox(height: 16),
                      SkeletonParagraph(lines: 4),
                    ],
                  );
                }

                final directory = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;

                        final districts = _Section(
                          title: 'Les 14 districts',
                          places: directory.districts.where(_matches).toList(),
                        );
                        final regions = _Section(
                          title: 'Les ${directory.regions.length} régions',
                          places: directory.regions.where(_matches).toList(),
                        );
                        final cities = _Section(
                          title: 'Les ${directory.cities.length} villes chef-lieu',
                          places: directory.cities.where(_matches).toList(),
                        );

                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              districts,
                              const SizedBox(height: 22),
                              regions,
                              const SizedBox(height: 22),
                              cities,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  districts,
                                  const SizedBox(height: 26),
                                  cities,
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(child: regions),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Source : ${directory.sourceName ?? 'ANStat — RGPH 2021'}. '
                      'Les effectifs ne sont pas recalculés.',
                      style: TextStyle(fontSize: 12, height: 1.5, color: tone.faint),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.places});

  final String title;
  final List<PlaceChild> places;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle(size: 17, weight: FontWeight.w600, color: tone.ink),
              ),
            ),
            Text(
              '${places.length}',
              style: TextStyle(fontSize: 12, color: tone.faint),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: tone.lineSoft),
        if (places.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aucun lieu ne correspond à ce filtre.',
              style: TextStyle(fontSize: 13, color: tone.faint),
            ),
          ),
        for (final place in places) _PlaceRow(place: place),
      ],
    );
  }
}

class _PlaceRow extends StatefulWidget {
  const _PlaceRow({required this.place});

  final PlaceChild place;

  @override
  State<_PlaceRow> createState() => _PlaceRowState();
}

class _PlaceRowState extends State<_PlaceRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/lieux/${widget.place.slug}'),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? tone.subtle : Colors.transparent,
            border: Border(bottom: BorderSide(color: tone.lineSoft)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.place.name,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _hovered ? IvoireColors.greenDeep : tone.ink,
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                formatNumber(widget.place.population),
                style: TextStyle(fontSize: 13, color: tone.muted),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: tone.faint),
            ],
          ),
        ),
      ),
    );
  }
}
