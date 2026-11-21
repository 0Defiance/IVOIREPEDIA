import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/article.dart';
import '../display_settings.dart';

/// Largeur d'image demandée à Wikimedia : quelques paliers seulement, pour
/// que le cache du navigateur serve plusieurs vignettes avec un seul
/// téléchargement.
// Seuls ces paliers sont servis par Wikimedia Commons : une largeur
// arbitraire (640 px, par exemple) répond 400. Si un fichier n'a pas encore
// sa variante, `_Cover` se rabat sur l'original.
const List<int> _coverWidths = [250, 500, 960, 1280];

int coverWidthFor(int pixels) {
  for (final width in _coverWidths) {
    if (pixels <= width) {
      return width;
    }
  }

  return _coverWidths.last;
}

/// Wikimedia Commons sert chaque image en plusieurs largeurs, dans des URL du
/// type `…/thumb/a/b/Fichier.jpg/1280px-Fichier.jpg`. On demande la largeur
/// réellement affichée : une vignette de 96 px n'a pas besoin du fichier de
/// 1280 px, qui pèse plusieurs centaines de ko.
String sizedCoverUrl(String url, int width) {
  if (url.isEmpty) {
    return url;
  }

  final match = RegExp(r'/(\d+)px-([^/]+)$').firstMatch(url);

  if (match == null) {
    return url;
  }

  final current = int.parse(match.group(1)!);
  final target = coverWidthFor(width);

  if (current <= target) {
    return url;
  }

  return url.replaceRange(
    match.start,
    match.end,
    '/${target}px-${match.group(2)}',
  );
}

/// Illustration d'un article, avec sa mention de source.
///
/// Les images viennent de Wikimedia Commons : la ligne de crédit affiche
/// l'auteur et la licence, et ouvre la page de description du fichier. Une
/// image qui ne se charge pas laisse un cadre neutre plutôt qu'une icône
/// cassée.
class ArticleFigure extends StatelessWidget {
  const ArticleFigure({
    required this.article,
    this.height = 260,
    this.radius = 12,
    this.showCaption = true,
    this.alignment = Alignment.center,
    this.requestWidth = 960,
    super.key,
  });

  final ArticleSummary article;
  final double height;
  final double radius;
  final bool showCaption;
  final Alignment alignment;

  /// Largeur d'affichage visée, en pixels logiques : elle fixe la variante
  /// téléchargée et la taille de décodage.
  final double requestWidth;

  @override
  Widget build(BuildContext context) {
    final url = article.coverImageUrl;

    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    final tone = ToneColors.from(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final width = coverWidthFor(
      requestWidth.isFinite ? (requestWidth * ratio).round() : 960,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: height,
            width: double.infinity,
            color: tone.subtle,
            child: _Cover(
              url: url,
              width: width,
              fit: BoxFit.cover,
              alignment: alignment,
              semanticLabel: article.coverImageAlt,
            ),
          ),
        ),
        if (showCaption && article.imageCredit != null) ...[
          const SizedBox(height: 6),
          _CreditLine(article: article),
        ],
      ],
    );
  }
}

/// Vignette carrée pour les listes : même source, même cadre, taille réduite.
class ArticleThumb extends StatelessWidget {
  const ArticleThumb({
    required this.article,
    this.width = 108,
    this.height = 78,
    this.radius = 9,
    super.key,
  });

  final ArticleSummary article;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = article.coverImageUrl;
    final tone = ToneColors.from(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    // Une vignette peut remplir une largeur imposée (double.infinity) : on
    // demande alors le palier intermédiaire plutôt qu'une largeur infinie.
    final pixels = coverWidthFor(
      width.isFinite ? (width * ratio).round() : 500,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        color: tone.subtle,
        child: url == null || url.isEmpty
            ? const _MissingImage(compact: true)
            : _Cover(
                url: url,
                width: pixels,
                fit: BoxFit.cover,
                semanticLabel: article.coverImageAlt,
                compact: true,
              ),
      ),
    );
  }
}

/// Ligne « Photo : auteur — licence », cliquable vers la page Commons.
class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final license = article.coverImageLicense;
    final label = [
      'Photo : ${article.imageCredit}',
      if (license != null && license.isNotEmpty) license,
    ].join(' — ');

    final text = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 11.5, color: tone.faint, height: 1.45),
    );

    final source = article.coverImageSourceUrl;

    if (source == null || source.isEmpty) {
      return text;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            launchUrl(Uri.parse(source), mode: LaunchMode.externalApplication),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: text),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 11, color: tone.faint),
          ],
        ),
      ),
    );
  }
}

/// Image de couverture à la bonne largeur, avec repli sur l'original.
///
/// Wikimedia ne sert que quelques largeurs de vignette : quand la variante
/// demandée n'existe pas encore, la réponse est une erreur 400. Plutôt qu'un
/// cadre vide, on redemande alors le fichier d'origine.
class _Cover extends StatefulWidget {
  const _Cover({
    required this.url,
    required this.width,
    required this.fit,
    required this.semanticLabel,
    this.alignment = Alignment.center,
    this.compact = false,
  });

  final String url;
  final int width;
  final BoxFit fit;
  final String? semanticLabel;
  final Alignment alignment;
  final bool compact;

  @override
  State<_Cover> createState() => _CoverState();
}

class _CoverState extends State<_Cover> {
  bool _original = false;

  @override
  Widget build(BuildContext context) {
    final src = _original
        ? widget.url
        : sizedCoverUrl(widget.url, widget.width);

    return Image.network(
      src,
      fit: widget.fit,
      alignment: widget.alignment,
      cacheWidth: _original ? null : widget.width,
      filterQuality: FilterQuality.medium,
      semanticLabel: widget.semanticLabel,
      errorBuilder: (_, _, _) {
        if (_original) {
          return _MissingImage(compact: widget.compact);
        }

        // Cette variante n'existe pas : on repasse à l'image d'origine au
        // prochain rendu, sans interrompre la construction en cours.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _original = true);
          }
        });

        return const _ImagePlaceholder();
      },
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return ColoredBox(color: tone.subtle);
  }
}

class _MissingImage extends StatelessWidget {
  const _MissingImage({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return ColoredBox(
      color: tone.subtle,
      child: Center(
        child: Icon(
          Icons.photo_outlined,
          size: compact ? 20 : 28,
          color: tone.faint,
        ),
      ),
    );
  }
}
