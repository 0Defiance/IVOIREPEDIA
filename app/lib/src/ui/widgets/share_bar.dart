import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../display_settings.dart';

/// Adresse partageable d'un article, éventuellement ancrée sur une section.
String shareUrl(String articleUrl, {String? section}) {
  if (section == null || section.isEmpty) {
    return articleUrl;
  }

  return '$articleUrl#${sectionAnchor(section)}';
}

/// Ancre d'une section : minuscules, sans accents ni ponctuation, comme les
/// fragments d'URL habituels (`#histoire`).
String sectionAnchor(String title) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
    'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u', 'ÿ': 'y', 'ñ': 'n', 'œ': 'oe',
  };

  final buffer = StringBuffer();
  var separator = false;

  for (final rune in title.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final plain = accents[char] ?? char;

    if (RegExp(r'[a-z0-9]').hasMatch(plain)) {
      if (separator && buffer.isNotEmpty) {
        buffer.write('-');
      }
      buffer.write(plain);
      separator = false;
    } else {
      separator = true;
    }
  }

  return buffer.toString();
}

/// Liens de partage des réseaux utiles en Côte d'Ivoire et ailleurs.
Map<String, String> shareLinks(String url, String title) {
  final encodedUrl = Uri.encodeComponent(url);
  final encodedText = Uri.encodeComponent(title);

  return {
    'WhatsApp': 'https://wa.me/?text=$encodedText%20$encodedUrl',
    'X': 'https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl',
    'Facebook': 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl',
    'LinkedIn':
        'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl',
  };
}

/// Ouvre un lien hors de l'application ; renvoie faux si le navigateur refuse.
Future<bool> openExternal(String url) async {
  try {
    return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Boutons de partage posés sous le titre d'un article.
class ShareBar extends StatelessWidget {
  const ShareBar({
    required this.url,
    required this.title,
    this.onCopied,
    this.compact = false,
    super.key,
  });

  final String url;
  final String title;
  final void Function(String message)? onCopied;
  final bool compact;

  static const _colors = {
    'WhatsApp': Color(0xFF1F8F4E),
    'X': Color(0xFF1B1B1B),
    'Facebook': Color(0xFF2D58A8),
    'LinkedIn': Color(0xFF0A5C8C),
  };

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final links = shareLinks(url, title);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!compact)
          Text(
            'Partager :',
            style: TextStyle(fontSize: 12, color: tone.muted),
          ),
        for (final entry in links.entries)
          _SharePill(
            label: entry.key,
            color: _colors[entry.key] ?? IvoireColors.green,
            onTap: () async {
              final opened = await openExternal(entry.value);
              if (!opened) {
                onCopied?.call('Le partage n’a pas pu s’ouvrir.');
              }
            },
          ),
        _SharePill(
          label: 'Copier le lien',
          color: IvoireColors.terracotta,
          icon: Icons.link,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: url));
            onCopied?.call('Lien copié.');
          },
        ),
      ],
    );
  }
}

class _SharePill extends StatefulWidget {
  const _SharePill({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_SharePill> createState() => _SharePillState();
}

class _SharePillState extends State<_SharePill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? tone.highlight : tone.subtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tone.lineSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, size: 13, color: widget.color)
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(fontSize: 12, color: tone.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
