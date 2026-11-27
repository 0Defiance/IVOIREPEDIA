import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/article_image.dart';
import 'widgets/interactive.dart';
import 'widgets/page_parts.dart';

/// Page d'étiquette : « Étiquette : Indépendance » et les articles qui la
/// portent.
///
/// Le filtre est celui de l'API (`GET /api/v1/articles?tag=…`), qui accepte le
/// slug de l'étiquette. Le nom affiché vient de l'article d'où l'on vient
/// (`?nom=`) : c'est le seul endroit où l'application le connaît, l'API ne
/// servant pas de liste d'étiquettes. Une adresse saisie à la main retombe donc
/// sur le slug mis en forme.
class TagPage extends StatefulWidget {
  const TagPage({required this.slug, this.name, super.key});

  final String slug;
  final String? name;

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  Future<PagedArticles>? _future;
  int _page = 1;
  final List<ArticleSummary> _loaded = <ArticleSummary>[];
  PagedArticles? _lastPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<PagedArticles> _load() async {
    final articles = await ApiScope.of(context)
        .fetchArticles(tag: widget.slug, limit: 20, page: _page);

    _lastPage = articles;
    _loaded.addAll(articles.items);

    return articles;
  }

  void _loadMore() {
    setState(() {
      _page += 1;
      _future = _load();
    });
  }

  /// Nom lisible quand l'adresse arrive sans `?nom=` (lien partagé, saisie).
  String get _label {
    final given = widget.name?.trim() ?? '';

    if (given.isNotEmpty) {
      return given;
    }

    final words = widget.slug.replaceAll('-', ' ').trim();

    return words.isEmpty
        ? 'Étiquette'
        : words[0].toUpperCase() + words.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: FutureBuilder<PagedArticles>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Étiquette indisponible', style: titleStyle(size: 26)),
                    const SizedBox(height: 10),
                    Text('${snapshot.error}'),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(0, 28, 0, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 200, height: 12),
                    SizedBox(height: 12),
                    Skeleton(width: 320, height: 28),
                    SizedBox(height: 22),
                    SkeletonParagraph(lines: 3),
                  ],
                ),
              );
            }

            final total = _lastPage?.total ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  kicker: 'ÉTIQUETTE',
                  title: 'Étiquette : $_label',
                  intro:
                      'Articles publiés qui portent cette étiquette, quel que '
                      'soit leur domaine.',
                ),
                const SizedBox(height: 10),
                Text(
                  '$total page${total > 1 ? 's' : ''} avec cette étiquette.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: IvoireColors.faint,
                  ),
                ),
                const SizedBox(height: 22),
                SectionHeading(title: 'Pages étiquetées'),
                const SizedBox(height: 8),
                if (_loaded.isEmpty)
                  const Text(
                    'Aucune page publiée ne porte encore cette étiquette.',
                    style: TextStyle(fontSize: 14),
                  )
                else
                  for (final article in _loaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MotifCard(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.coverImageUrl != null) ...[
                              ArticleThumb(
                                article: article,
                                width: 92,
                                height: 70,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HoverLink(
                                    label: article.title,
                                    onTap: () => wikiGo(
                                      context,
                                      '/articles/${article.slug}',
                                    ),
                                    style: titleStyle(
                                      size: 16,
                                      weight: FontWeight.w600,
                                    ),
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
                    ),
                if (_lastPage?.hasMore == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: OutlinedButton(
                      onPressed: _loadMore,
                      child: const Text('Charger la suite'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
