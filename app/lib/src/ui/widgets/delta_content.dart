import 'package:flutter/material.dart';

import '../../theme.dart';
import '../wiki_actions.dart';
import 'interactive.dart';

/// Rend un contenu Delta Quill (ADR-003) comme le corps d'un article
/// d'encyclopédie : paragraphes, sections titrées avec filet et lien
/// « modifier », listes et citations.
class DeltaContent extends StatelessWidget {
  const DeltaContent({required this.ops, this.sectionKeys, super.key});

  final List<Map<String, dynamic>> ops;

  /// Clés d'ancrage par titre de section : elles permettent au sommaire
  /// de faire défiler la page jusqu'à la bonne section.
  final Map<String, GlobalKey>? sectionKeys;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    final buffer = StringBuffer();
    Map<String, dynamic>? pendingAttributes;

    void flush() {
      final text = buffer.toString().trimRight();
      buffer.clear();

      final attributes = pendingAttributes;
      pendingAttributes = null;

      if (text.isEmpty) {
        return;
      }

      blocks.add(_block(context, text, attributes));
    }

    for (final op in ops) {
      final insert = op['insert'];
      if (insert is! String) {
        continue; // les embeds ne sont pas rendus au MVP
      }

      final attributes = op['attributes'] is Map<String, dynamic>
          ? op['attributes'] as Map<String, dynamic>
          : null;
      final lines = insert.split('\n');

      for (var i = 0; i < lines.length; i++) {
        buffer.write(lines[i]);

        if (i < lines.length - 1) {
          pendingAttributes = attributes ?? pendingAttributes;
          flush();
        } else if (attributes != null) {
          pendingAttributes = attributes;
        }
      }
    }

    flush();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }

  Widget _block(
    BuildContext context,
    String text,
    Map<String, dynamic>? attributes,
  ) {
    final header = attributes?['header'];
    final list = attributes?['list'];
    final quote = attributes?['blockquote'] == true;

    if (header is int) {
      final content = Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(text, style: titleStyle(size: 20, weight: FontWeight.w700)),
                ),
                HoverLink(
                  label: 'modifier',
                  onTap: () => wikiNotImplemented(context, 'Modifier une section'),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: IvoireColors.lineSoft),
          ],
        ),
      );

      final key = sectionKeys?[text];

      return key == null ? content : KeyedSubtree(key: key, child: content);
    }

    if (list != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(color: IvoireColors.muted)),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      );
    }

    if (quote) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(
          color: IvoireColors.subtle,
          border: Border(left: BorderSide(color: IvoireColors.line, width: 3)),
        ),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: attributes?['bold'] == true ? FontWeight.w700 : null,
              fontStyle: attributes?['italic'] == true ? FontStyle.italic : null,
            ),
      ),
    );
  }
}

/// Titres de sections d'un contenu Delta, dans l'ordre d'apparition.
List<String> deltaSections(List<Map<String, dynamic>> ops) {
  final titles = <String>[];

  for (final op in ops) {
    final attributes = op['attributes'];
    final insert = op['insert'];

    if (insert is String && attributes is Map && attributes['header'] is int) {
      final title = insert.trim();
      if (title.isNotEmpty) {
        titles.add(title);
      }
    }
  }

  return titles;
}
