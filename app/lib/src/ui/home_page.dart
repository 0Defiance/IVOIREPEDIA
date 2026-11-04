import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';

/// Page d'accueil : une « une » d'encyclopédie — introduction, article du
/// jour, ce qu'il faut savoir, domaines, et colonne d'outils.
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
                Text("L'ENCYCLOPÉDIE IVOIRIENNE LIBRE", style: kickerStyle()),
                const SizedBox(height: 6),
                Text(
                  "Page d'accueil",
                  style: titleStyle(size: 30, weight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: IvoireColors.line),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: const Text(
                    "IVOIREPEDIA est une encyclopédie libre consacrée à la Côte d'Ivoire : "
                    'ses territoires, son histoire, ses langues, ses institutions et ses '
                    'cultures. Chacun peut la lire et l’enrichir ; les articles s’appuient '
                    'sur des sources citées.',
                    style: TextStyle(fontSize: 15.5, height: 1.75),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 26,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AnimatedCount(
                      value: data.articles.total,
                      label: 'articles publiés',
                    ),
                    AnimatedCount(
                      value: data.categories.length,
                      label: 'domaines',
                    ),
                    const Text(
                      'Sans publicité, sans traceur',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: IvoireColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 880;

                    final main = ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ArticleOfTheDay(page: data.articles),
                          const SizedBox(height: 26),
                          _DidYouKnow(page: data.articles),
                          const SizedBox(height: 26),
                          _Domains(categories: data.categories),
                        ],
                      ),
                    );

                    final aside = Column(
                      children: [
                        _AsideBox(
                          title: 'Article au hasard',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Parcourir l’encyclopédie sans choisir de sujet.',
                                style: TextStyle(fontSize: 13, height: 1.55),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: HoverLink(
                                  label: 'Tirer un article',
                                  onTap: () => _openRandom(data.articles),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: HoverLink(
                                  label: 'Créer un compte',
                                  onTap: () =>
                                      wikiNotImplemented(context, 'Créer un compte'),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (!wide) {
                      return Column(
                        children: [main, const SizedBox(height: 22), aside],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: main),
                        const SizedBox(width: 32),
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
        Skeleton(width: 220, height: 12),
        SizedBox(height: 12),
        Skeleton(width: 300, height: 30),
        SizedBox(height: 26),
        SkeletonParagraph(lines: 3),
        SizedBox(height: 26),
        Skeleton(width: 180, height: 18),
        SizedBox(height: 14),
        SkeletonParagraph(lines: 2),
        SizedBox(height: 26),
        Skeleton(width: 180, height: 18),
        SizedBox(height: 14),
        SkeletonParagraph(lines: 4),
      ],
    );
  }
}

class _ArticleOfTheDay extends StatelessWidget {
  const _ArticleOfTheDay({required this.page});

  final PagedArticles page;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return const _Section(
        title: 'Article du jour',
        child: Text('Aucun article publié pour le moment.'),
      );
    }

    final article = page.items.first;

    return _Section(
      title: 'Article du jour',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HoverLink(
            label: article.title,
            onTap: () => wikiGo(context, '/articles/${article.slug}'),
            style: titleStyle(size: 21, weight: FontWeight.w600),
            color: IvoireColors.link,
            hoverColor: IvoireColors.greenDeep,
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (article.categoryName != null) article.categoryName!,
              article.typeLabel,
              '${article.readingMinutes} min de lecture',
            ].join(' · '),
            style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
          ),
          const SizedBox(height: 10),
          Text(
            article.summary,
            style: const TextStyle(fontSize: 14.5, height: 1.7),
          ),
          const SizedBox(height: 10),
          HoverLink(
            label: 'Lire la suite',
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

    return _Section(
      title: 'Le saviez-vous ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final article in others)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
                style: const TextStyle(fontSize: 14, height: 1.65),
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
    return _Section(
      title: 'Explorer par domaine',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final links = [
            for (final category in categories) _DomainLink(category: category),
          ];

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: links,
            );
          }

          final half = (links.length + 1) ~/ 2;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: links.take(half).toList(),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: links.skip(half).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DomainLink extends StatelessWidget {
  const _DomainLink({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: HoverLink(
              label: category.name,
              onTap: () => wikiGo(context, '/categories/${category.slug}'),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${category.articleCount}',
            style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
          ),
        ],
      ),
    );
  }
}

/// Titre de section à la manière d'un article : titre sobre, filet fin.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle(size: 18.5, weight: FontWeight.w600)),
        const SizedBox(height: 7),
        const Divider(height: 1, color: IvoireColors.lineSoft),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _AsideBox extends StatelessWidget {
  const _AsideBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: IvoireColors.ivory,
        border: Border.all(color: IvoireColors.lineSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle(size: 13.5, weight: FontWeight.w600)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
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
          Text('Service indisponible',
              style: titleStyle(size: 24, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
