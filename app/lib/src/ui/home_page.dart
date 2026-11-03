import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../theme.dart';
import 'shell.dart';
import 'wiki_actions.dart';

/// Page d'accueil : une « une » d'encyclopédie — accueil, article du jour,
/// ce qu'il faut savoir, domaines, et colonne d'outils.
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 90),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Page d'accueil", style: serifStyle(size: 30, height: 1.2)),
                const SizedBox(height: 6),
                Container(height: 1, color: IvoireColors.line),
                const SizedBox(height: 16),
                _Welcome(total: data.articles.total, domains: data.categories.length),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;

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
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () => wikiNotImplemented(
                                    context, 'Article au hasard'),
                                child: const Text('Tirer un article'),
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
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
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
                        const SizedBox(width: 26),
                        SizedBox(width: 300, child: aside),
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

class _Welcome extends StatelessWidget {
  const _Welcome({required this.total, required this.domains});

  final int total;
  final int domains;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IvoireColors.highlight,
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue sur IVOIREPEDIA",
            style: serifStyle(size: 21, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "L'encyclopédie ivoirienne libre et inclusive, que chacun peut lire et enrichir. "
            'Les histoires, les territoires, les langues et les institutions de Côte d’Ivoire, '
            'avec des sources citées.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _stat('$total', 'articles publiés'),
              _stat('$domains', 'domaines'),
              _stat('100 %', 'sources citées'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        TextSpan(
          text: ' $label',
          style: const TextStyle(fontSize: 13, color: IvoireColors.muted),
        ),
      ]),
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
                child: InkWell(
                  onTap: () => wikiGo(context, '/articles/${article.slug}'),
                  child: Text(
                    article.title,
                    style: serifStyle(
                      size: 19,
                      weight: FontWeight.w600,
                      color: IvoireColors.link,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${article.typeLabel}',
                style: const TextStyle(fontSize: 12, color: IvoireColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.summary,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => wikiGo(context, '/articles/${article.slug}'),
            child: const Text(
              'Lire la suite →',
              style: TextStyle(fontSize: 13, color: IvoireColors.link),
            ),
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: IvoireColors.muted)),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: article.title,
                            style: const TextStyle(
                              color: IvoireColors.link,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' — ${article.summary}',
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14, height: 1.55),
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
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: IvoireColors.subtle,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: IvoireColors.muted,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
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
          Text('Service indisponible', style: serifStyle(size: 26)),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
