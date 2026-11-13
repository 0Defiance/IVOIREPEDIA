import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../display_settings.dart';
import '../wiki_actions.dart';
import 'interactive.dart';

/// Rend un contenu Delta Quill (ADR-003) comme le corps d'un article
/// d'encyclopédie : chapeau, sections titrées, listes et citations.
///
/// La présentation reste volontairement sobre — mesure de lecture courte,
/// titres discrets, filet fin — pour que le texte porte la page plutôt que
/// les décors. Les appels de note `[1]` du texte deviennent cliquables et
/// renvoient à la référence correspondante.
class DeltaContent extends StatelessWidget {
  const DeltaContent({
    required this.ops,
    this.sectionKeys,
    this.afterLead,
    this.onCopySection,
    this.onCopySectionLink,
    this.onFootnote,
    super.key,
  });

  final List<Map<String, dynamic>> ops;

  /// Copie le texte d'une section seule (offert à côté de « modifier »).
  final void Function(String title)? onCopySection;

  /// Copie le lien profond d'une section (`/articles/{slug}#ancre`).
  final void Function(String title)? onCopySectionLink;

  /// Ouvre la référence numérotée correspondant à un appel `[n]`.
  final void Function(int number)? onFootnote;

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
    final tone = ToneColors.from(context);
    final header = attributes?['header'];
    final list = attributes?['list'];
    final quote = attributes?['blockquote'] == true;

    if (header is int) {
      final key = sectionKeys?[text];
      return KeyedSubtree(
        key: key,
        child: _SectionHeading(
          text: text,
          level: header,
          onCopy: onCopySection == null ? null : () => onCopySection!(text),
          onCopyLink:
              onCopySectionLink == null ? null : () => onCopySectionLink!(text),
        ),
      );
    }

    if (list != null) {
      final ordered = list == 'ordered';

      return _ListRow(
        text: text,
        marker: ordered ? null : '•',
        index: orderedIndex,
        onFootnote: onFootnote,
      );
    }

    if (quote) {
      return Container(
        margin: const EdgeInsets.only(top: 6, bottom: 18),
        padding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: tone.line, width: 2)),
        ),
        child: _RichText(
          text: text,
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 15,
            height: 1.7,
            fontStyle: FontStyle.italic,
            color: tone.muted,
          ),
          onFootnote: onFootnote,
        ),
      );
    }

    final bold = attributes?['bold'] == true;
    final italic = attributes?['italic'] == true;

    return Padding(
      padding: EdgeInsets.only(bottom: lead ? 18 : 14),
      child: _RichText(
        text: text,
        onFootnote: onFootnote,
        style: TextStyle(
          fontFamily: kFont,
          fontSize: lead ? 16.5 : 15.5,
          height: lead ? 1.8 : 1.75,
          color: bold || lead ? tone.ink : tone.body,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

/// Texte d'un paragraphe, avec appels de note cliquables.
///
/// Les `[n]` sont rendus en exposant vert et renvoient à la référence n ;
/// le reste du texte reste un simple `TextSpan`, donc sélectionnable.
class _RichText extends StatefulWidget {
  const _RichText({
    required this.text,
    required this.style,
    this.onFootnote,
  });

  final String text;
  final TextStyle style;
  final void Function(int number)? onFootnote;

  @override
  State<_RichText> createState() => _RichTextState();
}

class _RichTextState extends State<_RichText> {
  static final RegExp _marker = RegExp(r'\[(\d{1,3})\]');

  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final onFootnote = widget.onFootnote;

    if (onFootnote == null || !widget.text.contains('[')) {
      return Text(widget.text, textAlign: TextAlign.left, style: widget.style);
    }

    final spans = <InlineSpan>[];
    var index = 0;

    for (final match in _marker.allMatches(widget.text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: widget.text.substring(index, match.start)));
      }

      final number = int.tryParse(match.group(1) ?? '');

      if (number == null) {
        spans.add(TextSpan(text: match.group(0)));
      } else {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => onFootnote(number);
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: '[${match.group(1)}]',
            style: const TextStyle(
              color: IvoireColors.green,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
            recognizer: recognizer,
          ),
        );
      }

      index = match.end;
    }

    if (index < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(index)));
    }

    return Text.rich(
      TextSpan(style: widget.style, children: spans),
      textAlign: TextAlign.left,
    );
  }
}

/// Titre de section : deux niveaux seulement, filet fin, liens réduits à
/// l'essentiel comme sur une page d'encyclopédie.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.text,
    required this.level,
    this.onCopy,
    this.onCopyLink,
  });

  final String text;
  final int level;
  final VoidCallback? onCopy;
  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
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
                    color: tone.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (onCopyLink != null)
                Tooltip(
                  message: 'Copier le lien de cette section',
                  child: IconButton(
                    onPressed: onCopyLink,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    icon: Icon(Icons.link, size: 14, color: tone.faint),
                  ),
                ),
              if (onCopy != null) ...[
                HoverLink(
                  label: 'copier',
                  color: tone.faint,
                  hoverColor: IvoireColors.link,
                  onTap: onCopy!,
                  style: const TextStyle(fontSize: 11.5, height: 1.2),
                ),
                const SizedBox(width: 10),
              ],
              HoverLink(
                label: 'modifier',
                color: tone.faint,
                hoverColor: IvoireColors.link,
                onTap: () => wikiNotImplemented(context, 'Modifier une section'),
                style: const TextStyle(fontSize: 11.5, height: 1.2),
              ),
            ],
          ),
          if (primary) ...[
            const SizedBox(height: 7),
            Divider(height: 1, thickness: 1, color: tone.lineSoft),
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
    this.onFootnote,
  });

  final String text;
  final String? marker;
  final int index;
  final void Function(int number)? onFootnote;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              marker ?? '${index + 1}.',
              style: TextStyle(fontSize: 15.5, height: 1.7, color: tone.muted),
            ),
          ),
          Expanded(
            child: _RichText(
              text: text,
              onFootnote: onFootnote,
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 15.5,
                height: 1.7,
                color: tone.body,
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
