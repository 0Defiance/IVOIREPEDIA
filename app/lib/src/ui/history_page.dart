import 'package:flutter/material.dart';

import '../api.dart';
import '../models/history.dart';
import '../theme.dart';
import 'shell.dart';

/// Section « Histoire incroyable » : des récits courts, datés et sourcés.
///
/// Chaque récit se déplie sur place : le lecteur voit d'abord l'accroche, puis
/// le texte et la source. Rien n'est affirmé sans document, et le document est
/// affiché avec le récit — pas caché en bas de page.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<HistoryStory>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchHistory();
  }

  void _retry() {
    setState(() => _future = ApiScope.of(context).fetchHistory());
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: FutureBuilder<List<HistoryStory>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(text: '${snapshot.error}', action: _retry);
          }

          if (!snapshot.hasData) {
            return const _Message(text: 'Chargement des récits…');
          }

          final stories = snapshot.data!;

          if (stories.isEmpty) {
            return const _Message(text: 'Aucun récit publié pour le moment.');
          }

          return _HistoryBody(stories: stories);
        },
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.stories});

  final List<HistoryStory> stories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HISTOIRE · CÔTE D’IVOIRE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: IvoireColors.orangeDeep,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Histoires incroyables',
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
              'Des épisodes qui surprennent : une capitale abandonnée à cause '
              'des moustiques, un parc traversé par un fleuve qui déborde, un '
              'masque qui danse comme une femme. Chaque récit est daté et '
              'renvoie au document qui le documente.',
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: IvoireColors.muted.withValues(alpha: 0.95),
              ),
            ),
          ),
          const SizedBox(height: 26),
          for (var index = 0; index < stories.length; index++) ...[
            _StoryCard(story: stories[index], index: index + 1),
            if (index < stories.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _StoryCard extends StatefulWidget {
  const _StoryCard({required this.story, required this.index});

  final HistoryStory story;
  final int index;

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final story = widget.story;

    return Container(
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    widget.index.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: IvoireColors.line,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (story.period != null)
                        Text(
                          story.period!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: IvoireColors.terracotta,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: IvoireColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(62, 8, 18, 12),
            child: Text(
              story.teaser,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: IvoireColors.muted,
              ),
            ),
          ),
          if (story.figures.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(62, 0, 18, 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final figure in story.figures)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: IvoireColors.subtle,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: IvoireColors.lineSoft),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            figure.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: IvoireColors.greenDeep,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            figure.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: IvoireColors.faint,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(62, 4, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final paragraph in story.paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        paragraph,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.8,
                          color: IvoireColors.ink,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IvoireColors.sand.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: IvoireColors.lineSoft),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SOURCE',
                          style: TextStyle(
                            fontSize: 9.5,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: IvoireColors.faint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            story.source.title,
                            if (story.source.publisher != null) story.source.publisher!,
                            if (story.source.year != null) '${story.source.year}',
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.5,
                            color: IvoireColors.muted,
                          ),
                        ),
                        if (story.source.url != null) ...[
                          const SizedBox(height: 4),
                          SelectableText(
                            story.source.url!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: IvoireColors.link,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: TextButton.icon(
              onPressed: () => setState(() => _open = !_open),
              icon: Icon(
                _open ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: IvoireColors.green,
              ),
              label: Text(
                _open ? 'Réduire' : 'Lire le récit',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: IvoireColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
            OutlinedButton(onPressed: action, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
