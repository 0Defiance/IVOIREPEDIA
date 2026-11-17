import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/article.dart';
import '../display_settings.dart';

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
    super.key,
  });

  final ArticleSummary article;
  final double height;
  final double radius;
  final bool showCaption;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final url = article.coverImageUrl;

    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: height,
            width: double.infinity,
            color: tone.subtle,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.medium,
              semanticLabel: article.coverImageAlt,
              errorBuilder: (_, _, _) => const _MissingImage(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _ImagePlaceholder(),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        color: tone.subtle,
        child: url == null || url.isEmpty
            ? const _MissingImage(compact: true)
            : Image.network(
                url,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                semanticLabel: article.coverImageAlt,
                errorBuilder: (_, _, _) => const _MissingImage(compact: true),
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
        onTap: () => launchUrl(
          Uri.parse(source),
          mode: LaunchMode.externalApplication,
        ),
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
