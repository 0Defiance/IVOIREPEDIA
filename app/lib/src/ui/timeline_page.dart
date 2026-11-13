import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/timeline.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'shell.dart';
import 'widgets/interactive.dart';

/// Frise chronologique de l'histoire ivoirienne.
///
/// Chaque jalon vient d'un récit de « Histoire incroyable » : la frise et la
/// page des récits ne peuvent donc pas se contredire.
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  Future<List<TimelineEvent>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchTimeline();
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HISTOIRE DE LA CÔTE D’IVOIRE', style: kickerStyle()),
            const SizedBox(height: 6),
            Text(
              'La frise du temps',
              style: titleStyle(size: 30, weight: FontWeight.w600, color: tone.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Des royaumes akan à aujourd’hui : chaque date renvoie au récit '
              'qui la raconte, avec son document de référence.',
              style: TextStyle(fontSize: 14.5, height: 1.65, color: tone.muted),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: tone.line),
            const SizedBox(height: 20),
            FutureBuilder<List<TimelineEvent>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: tone.ink),
                  );
                }

                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Skeleton(width: 220, height: 14),
                      SizedBox(height: 18),
                      SkeletonParagraph(lines: 3),
                    ],
                  );
                }

                final events = snapshot.data!;

                if (events.isEmpty) {
                  return Text(
                    'Aucun jalon publié pour le moment.',
                    style: TextStyle(fontSize: 14, color: tone.muted),
                  );
                }

                final eras = <String, List<TimelineEvent>>{};
                for (final event in events) {
                  eras.putIfAbsent(event.era, () => []).add(event);
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in eras.entries) ...[
                        _EraHeader(label: entry.key, count: entry.value.length),
                        for (final event in entry.value) _TimelineRow(event: event),
                        const SizedBox(height: 26),
                      ],
                      Text(
                        'Source des dates : les récits citent chacun leur document '
                        '(UNESCO, revue académique, recensement).',
                        style: TextStyle(fontSize: 12, height: 1.5, color: tone.faint),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EraHeader extends StatelessWidget {
  const _EraHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: kickerStyle(color: IvoireColors.terracotta),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: tone.lineSoft)),
          const SizedBox(width: 10),
          Text(
            '$count jalon${count > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 11.5, color: tone.faint),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatefulWidget {
  const _TimelineRow({required this.event});

  final TimelineEvent event;

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final event = widget.event;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/histoires?recit=${event.slug}'),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(0, 10, 8, 12),
          decoration: BoxDecoration(
            color: _hovered ? tone.subtle : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  '${event.year}',
                  style: titleStyle(
                    size: 15,
                    weight: FontWeight.w700,
                    color: _hovered ? IvoireColors.green : tone.ink,
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: _hovered ? IvoireColors.orange : IvoireColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 46,
                    color: tone.lineSoft,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: titleStyle(
                        size: 16.5,
                        weight: FontWeight.w600,
                        color: _hovered ? IvoireColors.greenDeep : tone.ink,
                      ),
                    ),
                    if (event.period != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.period!,
                        style: TextStyle(fontSize: 12, color: tone.faint),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      event.teaser,
                      style: TextStyle(fontSize: 13.5, height: 1.6, color: tone.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: _hovered ? IvoireColors.green : tone.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
