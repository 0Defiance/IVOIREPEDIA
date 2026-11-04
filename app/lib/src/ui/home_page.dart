import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';

/// Page d'accueil : une « une » d'encyclopédie — bienvenue chiffrée, article
/// du jour, ce qu'il faut savoir, domaines, et colonne d'outils.
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

  void _openRandom(PagedArticles page) {
    if (page.items.isEmpty) {
      wikiNotImplemented(context, 'Article au hasard');
      return;
    }

    final pick = page.items[math.Random().nextInt(page.items.length)];
    wikiGo(context, '/articles/${pick.slug}');
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorBox(
                message: '${snapshot.error}',
                onRetry: () => setState(() => _future = _load()),
              );
            }

            if (!snapshot.hasData) {
              return const _HomeSkeleton();
            }

            final data = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "L'ENCYCLOPÉDIE IVOIRIENNE LIBRE  ·  ABIDJAN",
                  style: kickerStyle(),
                ),
                const SizedBox(height: 6),
                Text("Page d'accueil", style: titleStyle(size: 30, weight: FontWeight.w700)),
                const SizedBox(height: 10),
                const WeaveRule(height: 3, opacity: 0.9),
                const SizedBox(height: 20),
                _Welcome(total: data.articles.total, domains: data.categories.length),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 880;

                    final main = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ArticleOfTheDay(page: data.articles),
                        const SizedBox(height: 16),
                        _DidYouKnow(page: data.articles),
                        const SizedBox(height: 16),
                        _Domains(categories: data.categories),
                      ],
                    );

                    final aside = Column(
                      children: [
                        _AsideBox(
                          title: 'Article au hasard',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Découvrir un sujet sans le chercher.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _openRandom(data.articles),
                                icon: const Icon(Icons.shuffle, size: 16),
                                label: const Text('Tirer un article'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AsideBox(
                          title: 'Contribuer',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'IVOIREPEDIA se construit à plusieurs : chercheurs, '
                                'enseignants, étudiants, gardiens de la mémoire.',
                                style: TextStyle(fontSize: 13, height: 1.55),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () =>
                                    wikiNotImplemented(context, 'Créer un compte'),
                                child: const Text('Créer un compte'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (!wide) {
                      return Column(
                        children: [main, const SizedBox(height: 16), aside],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: main),
                        const SizedBox(width: 24),
                        SizedBox(width: 290, child: aside),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 260, height: 12),
        SizedBox(height: 12),
        Skeleton(width: 340, height: 30),
        SizedBox(height: 20),
        Skeleton(height: 120, radius: 12),
        SizedBox(height: 16),
        Skeleton(height: 180, radius: 12),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.total, required this.domains});

  final int total;
  final int domains;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IvoireColors.highlight, IvoireColors.ivory],
        ),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: IvoireColors.orange, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AKWABA  ·  BIENVENUE', style: kickerStyle()),
          const SizedBox(height: 6),
          Text(
            'Bienvenue sur IVOIREPEDIA',
            style: titleStyle(size: 22, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            "L'encyclopédie ivoirienne libre et inclusive, que chacun peut lire et enrichir. "
            'Les histoires, les territoires, les langues et les institutions de Côte d’Ivoire, '
            'avec des sources citées.',
            style: TextStyle(fontSize: 14, height: 1.65),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              AnimatedCount(value: total, label: 'articles publiés'),
              AnimatedCount(value: domains, label: 'domaines'),
              const AnimatedCount(value: 100, label: 'des sources citées', suffix: '%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleOfTheDay extends StatelessWidget {
  const _ArticleOfTheDay({required this.page});

  final PagedArticles page;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return const _Frame(
        title: 'Article du jour',
        child: Text('Aucun article publié pour le moment.'),
      );
    }

    final article = page.items.first;

    return _Frame(
      title: 'Article du jour',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: HoverLink(
                  label: article.title,
                  onTap: () => wikiGo(context, '/articles/${article.slug}'),
                  style: titleStyle(size: 20, weight: FontWeight.w700),
                  color: IvoireColors.ink,
                  hoverColor: IvoireColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: IvoireColors.subtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  article.typeLabel,
                  style: const TextStyle(fontSize: 11, color: IvoireColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            article.summary,
            style: const TextStyle(fontSize: 14.5, height: 1.7),
          ),
          const SizedBox(height: 12),
          HoverLink(
            label: 'Lire la suite →',
            onTap: () => wikiGo(context, '/articles/${article.slug}'),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DidYouKnow extends StatelessWidget {
  const _DidYouKnow({required this.page});

  final PagedArticles page;

  @override
  Widget build(BuildContext context) {
    final others = page.items.skip(1).take(4).toList();

    if (others.isEmpty) {
      return const SizedBox.shrink();
    }

    return _Frame(
      title: 'Le saviez-vous ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final article in others)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 5, color: IvoireColors.orange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: HoverLink(
                              label: article.title,
                              onTap: () => wikiGo(context, '/articles/${article.slug}'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: ' — ${article.summary}',
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Domains extends StatelessWidget {
  const _Domains({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Explorer par domaine',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final category in categories)
            OutlinedButton(
              onPressed: () => wikiGo(context, '/categories/${category.slug}'),
              child: Text(
                '${category.name} (${category.articleCount})',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: IvoireColors.lineSoft),
                left: BorderSide(color: IvoireColors.green, width: 3),
              ),
            ),
            child: Text(title, style: kickerStyle(color: IvoireColors.green)),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _AsideBox extends StatelessWidget {
  const _AsideBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Frame(title: title, child: child);
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service indisponible', style: titleStyle(size: 26, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
