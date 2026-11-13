import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'shell.dart';
import 'widgets/interactive.dart';

/// « Ma bibliothèque » : les articles gardés en favori et les derniers lus.
///
/// Tout est local (stockage du navigateur) : aucun compte n'est nécessaire et
/// rien n'est envoyé au serveur.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final storage = AppStorage.instance;

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SUR CET APPAREIL', style: kickerStyle()),
            const SizedBox(height: 6),
            Text(
              'Ma bibliothèque',
              style: titleStyle(size: 30, weight: FontWeight.w600, color: tone.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Vos favoris et vos lectures récentes restent dans ce navigateur : '
              'aucun compte, aucun envoi au serveur. Effacer les données du site '
              'les efface aussi.',
              style: TextStyle(fontSize: 14, height: 1.65, color: tone.muted),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: tone.line),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 880;

                final favorites = _EntryList(
                  title: 'Favoris',
                  empty: 'Aucun favori pour le moment. Utilisez « Garder » en '
                      'haut d’un article.',
                  listenable: storage.favorites,
                  onClear: null,
                );

                final recent = _EntryList(
                  title: 'Lectures récentes',
                  empty: 'Les articles que vous ouvrez apparaîtront ici.',
                  listenable: storage.recent,
                  onClear: () => storage.clearRecent(),
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [favorites, const SizedBox(height: 26), recent],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: favorites),
                    const SizedBox(width: 32),
                    Expanded(child: recent),
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

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.title,
    required this.empty,
    required this.listenable,
    this.onClear,
  });

  final String title;
  final String empty;
  final ValueListenable<List<LibraryEntry>> listenable;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return ValueListenableBuilder<List<LibraryEntry>>(
      valueListenable: listenable,
      builder: (context, entries, _) {
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
                if (onClear != null && entries.isNotEmpty)
                  HoverLink(
                    label: 'Vider',
                    onTap: onClear!,
                    color: tone.faint,
                    hoverColor: IvoireColors.terracotta,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: tone.lineSoft),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  empty,
                  style: TextStyle(fontSize: 13, height: 1.6, color: tone.faint),
                ),
              ),
            for (final entry in entries) _EntryRow(entry: entry),
          ],
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return GestureDetector(
      onTap: () => context.go('/articles/${entry.slug}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.article_outlined, size: 15, color: IvoireColors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(fontSize: 13.5, color: tone.ink),
                  ),
                  if (entry.category != null)
                    Text(
                      entry.category!,
                      style: TextStyle(fontSize: 11.5, color: tone.faint),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: tone.faint),
          ],
        ),
      ),
    );
  }
}
