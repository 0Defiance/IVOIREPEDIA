import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';

/// Page de catégorie : « Catégorie : Histoire », sous-catégories et pages.
class CategoryPage extends StatefulWidget {
  const CategoryPage({required this.slug, super.key});

  final String slug;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Future<({Category? category, PagedArticles articles})>? _future;
  int _page = 1;
  final List<ArticleSummary> _loaded = <ArticleSummary>[];
  PagedArticles? _lastPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<({Category? category, PagedArticles articles})> _load() async {
    final api = ApiScope.of(context);
    final categories = await api.fetchCategories();
    final articles = await api.fetchArticles(
      category: widget.slug,
      limit: 20,
      page: _page,
    );

    _lastPage = articles;
    _loaded.addAll(articles.items);

    return (category: _find(categories, widget.slug), articles: articles);
  }

  Category? _find(List<Category> categories, String slug) {
    for (final category in categories) {
      if (category.slug == slug) {
        return category;
      }
      final child = _find(category.children, slug);
      if (child != null) {
        return child;
      }
    }

    return null;
  }

  void _loadMore() {
    setState(() {
      _page += 1;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catégorie indisponible', style: titleStyle(size: 26)),
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

            final category = snapshot.data!.category;

            if (category == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text('Cette catégorie n’existe pas.',
                    style: titleStyle(size: 24)),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WikiTabs(
                  items: [
                    (label: 'Catégorie', selected: true, onTap: () {}),
                    (
                      label: 'Discussion',
                      selected: false,
                      onTap: () => wikiNotImplemented(context, 'Discussion'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Catégorie : ${category.name}',
                  style: titleStyle(size: 27, weight: FontWeight.w600, height: 1.2),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: IvoireColors.line),
                const SizedBox(height: 14),
                Text(
                  category.description?.isNotEmpty == true
                      ? category.description!
                      : 'Articles publiés dans ce domaine de l’encyclopédie.',
                  style: const TextStyle(fontSize: 14.5, height: 1.7),
                ),
                const SizedBox(height: 12),
                Text(
                  '${category.articleCount} page${category.articleCount > 1 ? 's' : ''} dans cette catégorie.',
                  style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
                ),
                if (category.children.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _Heading('Sous-catégories'),
                  for (final child in category.children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.chevron_right, size: 14, color: IvoireColors.faint),
                          HoverLink(
                            label: child.name,
                            onTap: () => wikiGo(context, '/categories/${child.slug}'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text('(${child.articleCount})',
                              style: const TextStyle(
                                  fontSize: 12, color: IvoireColors.muted)),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 22),
                _Heading('Pages dans la catégorie'),
                if (_loaded.isEmpty)
                  const Text('Aucune page publiée pour le moment.',
                      style: TextStyle(fontSize: 14))
                else
                  for (final article in _loaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HoverLink(
                            label: article.title,
                            onTap: () => wikiGo(context, '/articles/${article.slug}'),
                            style: titleStyle(size: 16, weight: FontWeight.w600),
                          ),
                          Text(
                            article.summary,
                            style: const TextStyle(
                              fontSize: 13,
                              color: IvoireColors.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
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

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: titleStyle(size: 18.5, weight: FontWeight.w600)),
          const SizedBox(height: 7),
          const Divider(height: 1, color: IvoireColors.lineSoft),
        ],
      ),
    );
  }
}
