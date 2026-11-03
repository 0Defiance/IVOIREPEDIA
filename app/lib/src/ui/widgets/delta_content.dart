import 'package:flutter/material.dart';

import '../../theme.dart';

/// Rend un contenu Delta Quill (ADR-003) en widgets Flutter.
///
/// Le backend ne stocke jamais de HTML : ce rendu est donc la seule barrière
/// d'affichage, et il ne peut produire que du texte et des styles typographiques.
class DeltaContent extends StatelessWidget {
  const DeltaContent({required this.ops, super.key});

  final List<Map<String, dynamic>> ops;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    final buffer = StringBuffer();
    Map<String, dynamic>? pendingAttributes;

    void flush() {
      final text = buffer.toString().trimRight();
      buffer.clear();

      if (text.isEmpty) {
        pendingAttributes = null;
        return;
      }

      blocks.add(_block(context, text, pendingAttributes));
      pendingAttributes = null;
    }

    for (final op in ops) {
      final insert = op['insert'];
      if (insert is! Map) {
        if (insert is! String) {
          continue; // les opérations non textuelles (embeds) sont ignorées
        }

        final attributes = op['attributes'];
        final lines = insert.split('\n');

        for (var i = 0; i < lines.length; i++) {
          buffer.write(lines[i]);

          if (i < lines.length - 1) {
            pendingAttributes = (attributes is Map<String, dynamic>)
                ? attributes
                : pendingAttributes;
            flush();
          } else if (attributes is Map<String, dynamic>) {
            pendingAttributes = attributes;
          }
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
    final theme = Theme.of(context);
    final header = attributes?['header'];
    final list = attributes?['list'];
    final quote = attributes?['blockquote'] == true;

    if (header is int) {
      final style = switch (header) {
        1 => theme.textTheme.headlineMedium,
        2 => theme.textTheme.headlineSmall,
        _ => theme.textTheme.titleLarge,
      };

      return Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 10),
        child: Text(text, style: style),
      );
    }

    if (list != null) {
      final ordered = list == 'ordered';
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                ordered ? '•' : '•',
                style: const TextStyle(color: IvoireColors.orange, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(text, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      );
    }

    if (quote) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: IvoireColors.gold, width: 3)),
          color: IvoireColors.sand,
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: attributes?['bold'] == true ? FontWeight.w700 : null,
          fontStyle: attributes?['italic'] == true ? FontStyle.italic : null,
        ),
      ),
    );
  }
}
