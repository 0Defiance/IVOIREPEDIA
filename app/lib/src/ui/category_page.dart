import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catégorie indisponible', style: serifStyle(size: 26)),
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
                padding: EdgeInsets.symmetric(vertical: 90),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final category = snapshot.data!.category;

            if (category == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text('Cette catégorie n’existe pas.',
                    style: serifStyle(size: 24)),
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
                Text('Catégorie : ${category.name}',
                    style: serifStyle(size: 28, height: 1.2)),
                const SizedBox(height: 6),
                Container(height: 1, color: IvoireColors.line),
                const SizedBox(height: 14),
                Text(
                  category.description?.isNotEmpty == true
                      ? category.description!
                      : 'Articles publiés dans ce domaine de l’encyclopédie.',
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 14),
                Text(
                  '${category.articleCount} page${category.articleCount > 1 ? 's' : ''} dans cette catégorie.',
                  style: const TextStyle(fontSize: 12.5, color: IvoireColors.muted),
                ),
                if (category.children.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _Heading('Sous-catégories'),
                  for (final child in category.children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Text('•  ', style: TextStyle(color: IvoireColors.muted)),
                          InkWell(
                            onTap: () => wikiGo(context, '/categories/${child.slug}'),
                            child: Text(
                              child.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: IvoireColors.link,
                              ),
                            ),
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
                          InkWell(
                            onTap: () => wikiGo(context, '/articles/${article.slug}'),
                            child: Text(
                              article.title,
                              style: serifStyle(
                                size: 16,
                                weight: FontWeight.w600,
                                color: IvoireColors.link,
                              ),
                            ),
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
          Text(label, style: serifStyle(size: 19, weight: FontWeight.w600)),
          const SizedBox(height: 5),
          const Divider(height: 1, color: IvoireColors.lineSoft),
        ],
      ),
    );
  }
}
