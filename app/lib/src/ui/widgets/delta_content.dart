import 'package:flutter/material.dart';

import '../../theme.dart';
import '../wiki_actions.dart';
import 'interactive.dart';

/// Rend un contenu Delta Quill (ADR-003) comme le corps d'un article
/// d'encyclopédie : chapeau, sections titrées, listes et citations.
///
/// La présentation reste volontairement sobre — mesure de lecture courte,
/// titres discrets, filet fin — pour que le texte porte la page plutôt que
/// les décors.
class DeltaContent extends StatelessWidget {
  const DeltaContent({
    required this.ops,
    this.sectionKeys,
    this.afterLead,
    super.key,
  });

  final List<Map<String, dynamic>> ops;

  /// Bloc inséré juste après le chapeau (le sommaire, comme sur une page
  /// d'encyclopédie, se place après l'introduction).
  final Widget? afterLead;

  /// Clés d'ancrage par titre de section : elles permettent au sommaire
  /// de faire défiler la page jusqu'à la bonne section.
  final Map<String, GlobalKey>? sectionKeys;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    final buffer = StringBuffer();
    Map<String, dynamic>? pendingAttributes;
    var inLead = true;
    var orderedIndex = 0;

    void flush() {
      final text = buffer.toString().trimRight();
      buffer.clear();

      final attributes = pendingAttributes;
      pendingAttributes = null;

      if (text.isEmpty) {
        return;
      }

      final isHeader = attributes?['header'] is int;
      final isOrdered = attributes?['list'] == 'ordered';
      final isLead = inLead;

      if (!isOrdered) {
        orderedIndex = 0;
      }

      blocks.add(_block(
        context,
        text,
        attributes,
        lead: isLead && !isHeader,
        orderedIndex: isOrdered ? orderedIndex++ : 0,
      ));

      if (isLead && !isHeader && afterLead != null) {
        blocks.add(afterLead!);
      }

      inLead = false;
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
          // Fin de bloc : les attributs de l'op s'appliquent à ce bloc,
          // puis sont oubliés pour ne pas contaminer le suivant.
          if (attributes != null) {
            pendingAttributes = attributes;
          }
          flush();
        } else if (attributes != null && lines[i].isNotEmpty) {
          // Bloc non terminé : les attributs courent jusqu'au prochain saut.
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
    Map<String, dynamic>? attributes, {
    required bool lead,
    required int orderedIndex,
  }) {
    final header = attributes?['header'];
    final list = attributes?['list'];
    final quote = attributes?['blockquote'] == true;

    if (header is int) {
      final key = sectionKeys?[text];
      final content = KeyedSubtree(
        key: key,
        child: _SectionHeading(text: text, level: header),
      );

      return content;
    }

    if (list != null) {
      final ordered = list == 'ordered';

      return _ListRow(
        text: text,
        marker: ordered ? null : '•',
        index: orderedIndex,
      );
    }

    if (quote) {
      return Container(
        margin: const EdgeInsets.only(top: 6, bottom: 18),
        padding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: IvoireColors.line, width: 2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            fontStyle: FontStyle.italic,
            color: IvoireColors.muted,
          ),
        ),
      );
    }

    final bold = attributes?['bold'] == true;
    final italic = attributes?['italic'] == true;

    return Padding(
      padding: EdgeInsets.only(bottom: lead ? 18 : 14),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: kFont,
          fontSize: lead ? 16.5 : 15.5,
          height: lead ? 1.8 : 1.75,
          color: bold || lead ? IvoireColors.ink : const Color(0xFF28322C),
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

/// Titre de section : deux niveaux seulement, filet fin, lien « modifier »
/// réduit à l'essentiel comme sur une page d'encyclopédie.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, required this.level});

  final String text;
  final int level;

  @override
  Widget build(BuildContext context) {
    final primary = level <= 2;

    return Padding(
      padding: EdgeInsets.only(top: primary ? 30 : 20, bottom: primary ? 10 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: titleStyle(
                    size: primary ? 21 : 16.5,
                    weight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              HoverLink(
                label: 'modifier',
                color: IvoireColors.faint,
                hoverColor: IvoireColors.link,
                onTap: () => wikiNotImplemented(context, 'Modifier une section'),
                style: const TextStyle(fontSize: 11.5, height: 1.2),
              ),
            ],
          ),
          if (primary) ...[
            const SizedBox(height: 7),
            const Divider(height: 1, thickness: 1, color: IvoireColors.lineSoft),
          ],
        ],
      ),
    );
  }
}

/// Élément de liste à puce ou numéroté, avec retrait aligné sur le texte.
class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.text,
    required this.marker,
    required this.index,
  });

  final String text;
  final String? marker;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              marker ?? '${index + 1}.',
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.7,
                color: IvoireColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 15.5,
                height: 1.7,
                color: Color(0xFF28322C),
              ),
            ),
          ),
        ],
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
