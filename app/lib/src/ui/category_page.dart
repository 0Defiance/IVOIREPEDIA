import 'package:flutter/material.dart';

import '../api.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/article_list.dart';
import 'widgets/interactive.dart';
import 'widgets/page_parts.dart';

/// Page de catégorie : « Catégorie : Histoire », sous-catégories et pages.
class CategoryPage extends StatefulWidget {
  const CategoryPage({required this.slug, super.key});

  final String slug;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Future<List<Category>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchCategories();
  }

  Future<void> _reload() async {
    setState(() => _future = ApiScope.of(context).fetchCategories());
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

  @override
  Widget build(BuildContext context) {
    final api = ApiScope.of(context);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: FutureBuilder<List<Category>>(
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
                      onPressed: _reload,
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

            final category = _find(snapshot.data!, widget.slug);

            if (category == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  'Cette catégorie n’existe pas.',
                  style: titleStyle(size: 24),
                ),
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
                PageHeader(
                  kicker: 'DOMAINE',
                  title: 'Catégorie : ${category.name}',
                  intro: category.description?.isNotEmpty == true
                      ? category.description!
                      : 'Articles publiés dans ce domaine de l’encyclopédie.',
                ),
                const SizedBox(height: 10),
                Text(
                  '${category.articleCount} page${category.articleCount > 1 ? 's' : ''} dans cette catégorie.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: IvoireColors.faint,
                  ),
                ),
                if (category.children.isNotEmpty)
                  ..._subcategories(context, category),
                const SizedBox(height: 22),
                const _Heading('Pages dans la catégorie'),
                PagedArticleList(
                  loadPage: (page) => api.fetchArticles(
                    category: widget.slug,
                    limit: 20,
                    page: page,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Sous-catégories cliquables, avec leur nombre de pages.
  List<Widget> _subcategories(BuildContext context, Category category) {
    return [
      const SizedBox(height: 22),
      const _Heading('Sous-catégories'),
      for (final child in category.children)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: IvoireColors.faint,
              ),
              HoverLink(
                label: child.name,
                onTap: () => wikiGo(context, '/categories/${child.slug}'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                '(${child.articleCount})',
                style: const TextStyle(fontSize: 12, color: IvoireColors.muted),
              ),
            ],
          ),
        ),
    ];
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
        children: [SectionHeading(title: label)],
      ),
    );
  }
}
