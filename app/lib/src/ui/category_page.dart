import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'widgets/article_card.dart';
import 'widgets/section_title.dart';

/// Page d'une catégorie : arborescence éditoriale d'un domaine (CONTEXT §11.1).
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
      limit: 12,
      page: _page,
    );

    _lastPage = articles;
    _loaded.addAll(articles.items);

    return (
      category: _find(categories, widget.slug),
      articles: articles,
    );
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
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _Message(
                  icon: Icons.cloud_off,
                  title: '${snapshot.error}',
                  action: OutlinedButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Réessayer'),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final category = snapshot.data!.category;

              if (category == null) {
                return const _Message(
                  icon: Icons.search_off,
                  title: 'Cette catégorie n’existe pas.',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle('Domaine'),
                  const SizedBox(height: 12),
                  Text(category.name, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 12),
                  Text(
                    category.description?.isNotEmpty == true
                        ? category.description!
                        : 'Articles publiés dans ce domaine.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: IvoireColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.articleCount} article${category.articleCount > 1 ? 's' : ''} publié${category.articleCount > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 13, color: IvoireColors.muted),
                  ),
                  const SizedBox(height: 28),
                  if (_loaded.isEmpty)
                    const Text('Aucun article publié dans ce domaine pour le moment.')
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 720 ? 2 : 1;
                        const spacing = 16.0;
                        final width =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                                columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final article in _loaded)
                              SizedBox(
                                width: width,
                                child: ArticleCard(article: article),
                              ),
                          ],
                        );
                      },
                    ),
                  if (_lastPage?.hasMore == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: OutlinedButton(
                        onPressed: _loadMore,
                        child: const Text('Charger plus d’articles'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.action});

  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(icon, size: 32, color: IvoireColors.muted),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
