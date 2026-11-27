import 'package:flutter/material.dart';

import '../../models/article.dart';
import '../../theme.dart';
import '../wiki_actions.dart';
import 'article_image.dart';
import 'interactive.dart';
import 'page_parts.dart';

/// Liste paginée d'articles, partagée par la page de catégorie et celle
/// d'étiquette.
///
/// Le chargement, l'accumulation des pages, le bouton « Charger la suite » et
/// les états chargement / vide / erreur vivaient en double dans les deux
/// écrans. Chacune garde son en-tête et ses liens ; seule la liste est ici.
///
/// [loadPage] reçoit le numéro de page et le filtre du serveur (catégorie ou
/// étiquette) : la pagination reste celle de l'API, jamais une découpe locale.
/// [onTotal] prévient la page du total annoncé, pour qu'elle puisse l'afficher.
class PagedArticleList extends StatefulWidget {
  const PagedArticleList({
    required this.loadPage,
    this.emptyMessage = 'Aucune page publiée pour le moment.',
    this.onTotal,
    super.key,
  });

  final Future<PagedArticles> Function(int page) loadPage;
  final String emptyMessage;
  final void Function(int total)? onTotal;

  @override
  State<PagedArticleList> createState() => _PagedArticleListState();
}

class _PagedArticleListState extends State<PagedArticleList> {
  final List<ArticleSummary> _items = <ArticleSummary>[];
  int _nextPage = 1;
  bool _started = false;
  bool _loading = false;
  bool _hasMore = false;
  Object? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Le premier chargement attend que `ApiScope` soit lisible au-dessus.
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await widget.loadPage(_nextPage);

      if (!mounted) {
        return;
      }

      setState(() {
        _items.addAll(page.items);
        _nextPage += 1;
        _hasMore = page.hasMore;
      });

      widget.onTotal?.call(page.total);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liste indisponible', style: titleStyle(size: 20)),
            const SizedBox(height: 8),
            Text('$_error'),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loading ? null : _load,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && _loading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonParagraph(lines: 2),
          SizedBox(height: 12),
          SkeletonParagraph(lines: 2),
        ],
      );
    }

    if (_items.isEmpty) {
      return Text(widget.emptyMessage, style: const TextStyle(fontSize: 14));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final article in _items) _ArticleRow(article: article),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: OutlinedButton(
              onPressed: _loading ? null : _load,
              child: const Text('Charger la suite'),
            ),
          ),
      ],
    );
  }
}

/// Une ligne de la liste : vignette facultative, titre, résumé.
class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MotifCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.coverImageUrl != null) ...[
              ArticleThumb(article: article, width: 92, height: 70),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HoverLink(
                    label: article.title,
                    onTap: () => wikiGo(context, '/articles/${article.slug}'),
                    style: titleStyle(size: 16, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: IvoireColors.muted,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
