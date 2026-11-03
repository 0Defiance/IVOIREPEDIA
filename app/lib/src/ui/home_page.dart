import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'widgets/article_card.dart';
import 'widgets/section_title.dart';

/// Accueil : ce que le visiteur voit en premier — l'intention éditoriale,
/// l'arborescence, puis les derniers articles publiés.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<({List<Category> categories, PagedArticles articles})>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<({List<Category> categories, PagedArticles articles})> _load() async {
    final api = ApiScope.of(context);
    final categories = await api.fetchCategories();
    final articles = await api.fetchArticles(limit: 9);

    return (categories: categories, articles: articles);
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Column(
        children: [
          const _Hero(),
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _HomeError(
                  message: '${snapshot.error}',
                  onRetry: () => setState(() => _future = _load()),
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final data = snapshot.data!;

              return Column(
                children: [
                  _CategoryStrip(categories: data.categories),
                  _LatestArticles(page: data.articles),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IvoireColors.sand, IvoireColors.ivory],
        ),
      ),
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: IvoireColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ENCYCLOPÉDIE INCLUSIVE IVOIRIENNE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: IvoireColors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  "L'ivoire, la lagune, les langues :\nun savoir ivoirien à portée de main.",
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  "IVOIREPEDIA rassemble les histoires, les territoires, les langues et les "
                  "institutions de Côte d'Ivoire dans des articles sourcés, écrits pour être lus "
                  "par tous — y compris à l'oral et hors ligne.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: IvoireColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/articles/abidjan'),
                    icon: const Icon(Icons.auto_stories_outlined, size: 18),
                    label: const Text('Commencer par Abidjan'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/recherche'),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Explorer le catalogue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Parcourir par domaine'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final category in categories)
                  ActionChip(
                    label: Text(
                      category.articleCount > 0
                          ? '${category.name} · ${category.articleCount}'
                          : category.name,
                    ),
                    onPressed: () =>
                        context.go('/categories/${category.slug}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestArticles extends StatelessWidget {
  const _LatestArticles({required this.page});

  final PagedArticles page;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return const PageContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Text('Aucun article publié pour le moment.'),
        ),
      );
    }

    final [featured, ...others] = page.items;

    return PageContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Derniers articles publiés'),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 820;

                if (!wide) {
                  return Column(
                    children: [
                      for (final article in page.items) ...[
                        ArticleCard(article: article, featured: article == featured),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    ArticleCard(article: featured, featured: true),
                    const SizedBox(height: 16),
                    _ArticleGrid(articles: others),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleGrid extends StatelessWidget {
  const _ArticleGrid({required this.articles});

  final List<ArticleSummary> articles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 720 ? 2 : 1;
        final spacing = 16.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final article in articles)
              SizedBox(width: width, child: ArticleCard(article: article)),
          ],
        );
      },
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 32, color: IvoireColors.muted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
