import 'package:flutter/material.dart';

import '../api.dart';
import '../brand.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../models/statistics.dart';
import '../models/timeline.dart';
import '../storage.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/article_image.dart';
import 'widgets/interactive.dart';

/// Page d'accueil : un portail d'encyclopédie. La marque et la devise ouvrent
/// la page, les portails donnent le plan, puis viennent l'article du jour,
/// le rappel historique, le défi, la frise, les chiffres et les outils du
/// lecteur.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Tout ce que la page affiche, chargé en une fois pour éviter les sauts.
class _HomeData {
  const _HomeData({
    required this.categories,
    required this.articles,
    required this.timeline,
    this.statistics,
  });

  final List<Category> categories;
  final PagedArticles articles;
  final List<TimelineEvent> timeline;
  final StatisticsSnapshot? statistics;
}

class _HomePageState extends State<HomePage> {
  Future<_HomeData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_HomeData> _load() async {
    final api = ApiScope.of(context);

    final categories = await api.fetchCategories();
    final articles = await api.fetchArticles(limit: 9);

    // La « une » ne doit pas tomber parce qu'une illustration secondaire
    // manque : la frise et les chiffres sont facultatifs, les articles non.
    var timeline = const <TimelineEvent>[];
    StatisticsSnapshot? statistics;

    try {
      timeline = await api.fetchTimeline();
    } catch (_) {
      // Frise indisponible : la page reste complète sans elle.
    }

    try {
      statistics = await api.fetchStatistics();
    } catch (_) {
      // Statistiques indisponibles : les chiffres disparaissent.
    }

    return _HomeData(
      categories: categories,
      articles: articles,
      timeline: timeline,
      statistics: statistics,
    );
  }

  /// Tirage serveur : le hasard porte sur tous les articles publiés, pas
  /// seulement sur ceux de la page d'accueil.
  Future<void> _openRandom() async {
    try {
      final pick = await ApiScope.of(context).fetchRandomArticle();

      if (!mounted) {
        return;
      }

      wikiGo(context, '/articles/${pick.slug}');
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun article à tirer pour le moment.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: FutureBuilder<_HomeData>(
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

            return _HomeBody(data: snapshot.data!, onRandom: _openRandom);
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data, required this.onRandom});

  final _HomeData data;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final timeline = data.timeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Masthead(
          articleCount: data.articles.total,
          domains: data.categories.length,
          categories: data.categories,
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;

            final main = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeadStory(page: data.articles),
                  if (timeline.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    _TodayInHistory(events: timeline),
                    if (timeline.length >= 2) ...[
                      const SizedBox(height: 26),
                      _DailyChallenge(events: timeline),
                    ],
                    const SizedBox(height: 30),
                    _TimelineRail(events: timeline),
                  ],
                  const SizedBox(height: 30),
                  _DidYouKnow(page: data.articles),
                ],
              ),
            );

            final aside = Column(
              children: [
                _KeyFigures(
                  stats: data.statistics,
                  timeline: timeline,
                  articleCount: data.articles.total,
                ),
                const SizedBox(height: 18),
                _RandomPickCard(onRandom: onRandom),
                const SizedBox(height: 18),
                const _ReadingResume(),
                const SizedBox(height: 18),
                const _ContributeBox(),
              ],
            );

            if (!wide) {
              return Column(
                children: [main, const SizedBox(height: 26), aside],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: main),
                const SizedBox(width: 36),
                SizedBox(width: 300, child: aside),
              ],
            );
          },
        ),
        if (data.categories.isNotEmpty) ...[
          const SizedBox(height: 34),
          _Portals(categories: data.categories),
        ],
      ],
    );
  }
}

/// En-tête de la page d'accueil : la signature complète, la phrase de
/// présentation, les compteurs, puis la barre des portails — comme la
/// manchette d'un portail encyclopédique, sans slogan publicitaire.
class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.articleCount,
    required this.domains,
    required this.categories,
  });

  final int articleCount;
  final int domains;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final narrow = MediaQuery.sizeOf(context).width < 560;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            kLockupAsset,
            height: narrow ? 126 : 166,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            semanticLabel: kTagline,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Une encyclopédie libre consacrée à la Côte d’Ivoire : ses '
              'territoires, son histoire, ses langues, ses institutions, ses '
              'cultures et son patrimoine.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: narrow ? 13.5 : 14.5,
                height: 1.65,
                color: tone.muted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$articleCount articles · $domains domaines · Chaque article cite ses sources',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: tone.faint),
        ),
        const SizedBox(height: 20),
        _PortalBar(categories: categories),
      ],
    );
  }
}

/// Barre des portails : une seule ligne de liens, avec le nombre d'articles.
/// Sur téléphone, les liens passent à la ligne plutôt que de défiler.
class _PortalBar extends StatelessWidget {
  const _PortalBar({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tone.lineSoft),
          bottom: BorderSide(color: tone.lineSoft),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Portails',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: tone.faint,
              ),
            ),
          ),
          for (final category in categories.take(8))
            _PortalLink(category: category),
        ],
      ),
    );
  }
}

class _PortalLink extends StatefulWidget {
  const _PortalLink({required this.category});

  final Category category;

  @override
  State<_PortalLink> createState() => _PortalLinkState();
}

class _PortalLinkState extends State<_PortalLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final color = _hover ? IvoireColors.greenDeep : IvoireColors.link;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, '/categories/${widget.category.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                  decoration: _hover
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.category.articleCount}',
                style: TextStyle(fontSize: 10.5, color: tone.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titre de section : un libellé, un filet fin, puis le contenu. Aucun losange
/// décoratif ici : le rythme de la page vient de la typographie et du filet.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final narrow = MediaQuery.sizeOf(context).width < 460;

    final heading = Text(
      title,
      style: titleStyle(size: 17.5, weight: FontWeight.w700, color: tone.ink),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing == null)
          heading
        else if (narrow) ...[
          heading,
          const SizedBox(height: 5),
          trailing!,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: heading),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: trailing,
              ),
            ],
          ),
        const SizedBox(height: 7),
        Container(height: 1, color: tone.lineSoft),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

/// L'article du jour : l'illustration sourcée, puis le titre, le chapô et le
/// lien de lecture. Pas de carte ni de bordure : la page porte le contenu.
class _LeadStory extends StatelessWidget {
  const _LeadStory({required this.page});

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
    final tone = ToneColors.from(context);

    return _Section(
      title: 'Article du jour',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.coverImageUrl != null &&
              article.coverImageUrl!.isNotEmpty) ...[
            ArticleFigure(article: article, height: 320, radius: 2),
            const SizedBox(height: 14),
          ],
          Text(
            [
              if (article.categoryName != null) article.categoryName!,
              article.typeLabel,
              '${article.readingMinutes} min de lecture',
              if (article.publishedAt != null) formatDate(article.publishedAt),
            ].join(' · '),
            style: TextStyle(fontSize: 12, color: tone.faint),
          ),
          const SizedBox(height: 6),
          HoverLink(
            label: article.title,
            onTap: () => wikiGo(context, '/articles/${article.slug}'),
            color: tone.ink,
            hoverColor: IvoireColors.greenDeep,
            style: titleStyle(
              size: 26,
              weight: FontWeight.w700,
              color: tone.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              article.summary,
              style: TextStyle(fontSize: 15.5, height: 1.72, color: tone.body),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HoverLink(
                label: 'Lire l’article',
                onTap: () => wikiGo(context, '/articles/${article.slug}'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 13,
                color: IvoireColors.link,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Un jalon tiré pour la journée : la page change de récit chaque jour, sans
/// hasard serveur ni nouvelle requête.
class _TodayInHistory extends StatelessWidget {
  const _TodayInHistory({required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final event = events[dayOfYear % events.length];
    final age = today.year - event.year;

    return _Section(
      title: 'Aujourd’hui dans l’histoire',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.year}',
                  style: titleStyle(
                    size: 27,
                    weight: FontWeight.w700,
                    color: tone.ink,
                  ),
                ),
                Text(
                  age > 0 ? 'il y a $age ans' : 'cette année',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: IvoireColors.orangeDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HoverLink(
                  label: event.title,
                  onTap: () =>
                      wikiGo(context, '/histoires?recit=${event.slug}'),
                  color: tone.ink,
                  hoverColor: IvoireColors.greenDeep,
                  style: titleStyle(
                    size: 16.5,
                    weight: FontWeight.w600,
                    color: tone.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.teaser,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: tone.body,
                  ),
                ),
                const SizedBox(height: 6),
                HoverLink(
                  label: 'Lire ce récit',
                  onTap: () =>
                      wikiGo(context, '/histoires?recit=${event.slug}'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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

/// Le défi du jour : retrouver l'année d'un jalon documenté, parmi trois
/// propositions. Il s'appuie sur la frise déjà chargée — aucun fait inventé —
/// et choisit un autre jalon que « Aujourd'hui dans l'histoire », dont la
/// réponse est affichée juste au-dessus.
class _DailyChallenge extends StatefulWidget {
  const _DailyChallenge({required this.events});

  final List<TimelineEvent> events;

  @override
  State<_DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<_DailyChallenge> {
  int? _picked;

  TimelineEvent get _event {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final count = widget.events.length;
    final offset = count > 2 ? (count ~/ 2).clamp(1, count - 1) : 1;

    return widget.events[(dayOfYear + offset) % count];
  }

  /// Trois années : la bonne réponse et deux autres jalons de la frise. Si la
  /// frise est trop courte, des décennies voisines complètent le tirage.
  List<int> _options(TimelineEvent event) {
    final options = <int>{event.year};
    final others =
        widget.events
            .map((item) => item.year)
            .where((year) => year != event.year)
            .toSet()
            .toList()
          ..sort();

    var index = others.isEmpty ? 0 : event.year % others.length;
    while (options.length < 3 && index < others.length) {
      options.add(others[index]);
      index++;
    }

    var step = 10;
    while (options.length < 3) {
      options.add(event.year + step);
      step += 10;
    }

    return options.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final event = _event;
    final picked = _picked;
    final solved = picked != null;
    final correct = picked == event.year;

    return _Section(
      title: 'Le défi du jour',
      child: Container(
        decoration: BoxDecoration(
          color: tone.paper,
          border: Border.all(color: tone.lineSoft),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En quelle année ce jalon de l’histoire ivoirienne a-t-il eu lieu ?',
              style: TextStyle(fontSize: 13, height: 1.55, color: tone.muted),
            ),
            const SizedBox(height: 5),
            Text(
              event.title,
              style: titleStyle(
                size: 16.5,
                weight: FontWeight.w700,
                color: tone.ink,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final year in _options(event))
                  _QuizOption(
                    key: ValueKey('quiz-option-$year'),
                    year: year,
                    state: !solved
                        ? _QuizState.idle
                        : (year == event.year
                              ? _QuizState.answer
                              : (year == picked
                                    ? _QuizState.wrong
                                    : _QuizState.dimmed)),
                    onTap: solved ? null : () => setState(() => _picked = year),
                  ),
              ],
            ),
            if (solved) ...[
              const SizedBox(height: 12),
              Row(
                key: const ValueKey('quiz-feedback'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: correct
                          ? IvoireColors.green
                          : IvoireColors.orangeDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correct
                          ? 'Bien vu : ce jalon date de ${event.year}.'
                          : 'Pas cette fois : c’était ${event.year}.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: correct
                            ? IvoireColors.greenDeep
                            : IvoireColors.orangeDeep,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HoverLink(
                label: 'Lire le récit',
                onTap: () => wikiGo(context, '/histoires?recit=${event.slug}'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _QuizState { idle, answer, wrong, dimmed }

class _QuizOption extends StatefulWidget {
  const _QuizOption({
    required this.year,
    required this.state,
    this.onTap,
    super.key,
  });

  final int year;
  final _QuizState state;
  final VoidCallback? onTap;

  @override
  State<_QuizOption> createState() => _QuizOptionState();
}

class _QuizOptionState extends State<_QuizOption> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    final (background, border, foreground) = switch (widget.state) {
      _QuizState.answer => (
        IvoireColors.green.withValues(alpha: 0.12),
        IvoireColors.green,
        IvoireColors.greenDeep,
      ),
      _QuizState.wrong => (
        IvoireColors.terracotta.withValues(alpha: 0.10),
        IvoireColors.terracotta,
        IvoireColors.terracotta,
      ),
      _QuizState.dimmed => (Colors.transparent, tone.lineSoft, tone.faint),
      _QuizState.idle => (
        _hover ? tone.subtle : tone.paper,
        _hover ? IvoireColors.green : tone.line,
        tone.ink,
      ),
    };

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${widget.year}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// La frise entière, en une bande qu'on fait défiler.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'La frise en un coup d’œil',
      trailing: HoverLink(
        label: 'Voir la frise complète',
        onTap: () => wikiGo(context, '/chronologie'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: SizedBox(
        height: 118,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) => _RailCard(event: events[index]),
        ),
      ),
    );
  }
}

class _RailCard extends StatefulWidget {
  const _RailCard({required this.event});

  final TimelineEvent event;

  @override
  State<_RailCard> createState() => _RailCardState();
}

class _RailCardState extends State<_RailCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, '/histoires?recit=${widget.event.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 186,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: _hover ? tone.subtle : tone.paper,
            border: Border.all(
              color: _hover ? IvoireColors.terracotta : tone.lineSoft,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.event.year}',
                style: titleStyle(
                  size: 19,
                  weight: FontWeight.w700,
                  color: IvoireColors.terracotta,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.event.era,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: tone.faint),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  widget.event.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: tone.body,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final tone = ToneColors.from(context);

    return _Section(
      title: 'Le saviez-vous ?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final article in others)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '•',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: IvoireColors.terracotta,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: HoverLink(
                              label: article.title,
                              onTap: () =>
                                  wikiGo(context, '/articles/${article.slug}'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: ' — ${article.summary}',
                            style: TextStyle(color: tone.body),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 13.5, height: 1.65),
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

/// Les portails thématiques, en fin de page : le plan complet de
/// l'encyclopédie, avec le nombre d'articles de chaque domaine.
class _Portals extends StatelessWidget {
  const _Portals({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return _Section(
      title: 'Portails thématiques',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tous les domaines de l’encyclopédie, avec le nombre d’articles '
            'publiés.',
            style: TextStyle(fontSize: 13, height: 1.6, color: tone.muted),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720
                  ? 3
                  : (constraints.maxWidth >= 440 ? 2 : 1);
              final width =
                  (constraints.maxWidth - (columns - 1) * 20) / columns;

              return Wrap(
                spacing: 20,
                runSpacing: 0,
                children: [
                  for (final category in categories)
                    SizedBox(
                      width: width,
                      child: _PortalRow(category: category),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PortalRow extends StatefulWidget {
  const _PortalRow({required this.category});

  final Category category;

  @override
  State<_PortalRow> createState() => _PortalRowState();
}

class _PortalRowState extends State<_PortalRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final color = _hover ? IvoireColors.greenDeep : IvoireColors.link;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, '/categories/${widget.category.slug}'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tone.lineSoft)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: color,
                    decoration: _hover
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: color,
                  ),
                ),
              ),
              Text(
                '${widget.category.articleCount}',
                style: TextStyle(fontSize: 11.5, color: tone.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Les chiffres du pays, en liste de définitions : libellé, valeur, précision.
class _KeyFigures extends StatelessWidget {
  const _KeyFigures({
    required this.stats,
    required this.timeline,
    required this.articleCount,
  });

  final StatisticsSnapshot? stats;
  final List<TimelineEvent> timeline;
  final int articleCount;

  @override
  Widget build(BuildContext context) {
    final rows = <_FigureData>[];
    final population = _indicator(stats, 'SP.POP.TOTL');

    if (population != null) {
      rows.add(
        _FigureData(
          label: 'Population',
          value: population.display ?? '—',
          caption: population.trend?.display ?? 'Donnée ${population.year}',
          route: '/statistiques',
        ),
      );
    }

    final census = stats?.census;
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;
    if (census != null && regions > 0) {
      rows.add(
        _FigureData(
          label: 'Territoires',
          value: '$regions régions',
          caption: '$districts districts · RGPH ${census.year}',
          route: '/lieux',
        ),
      );
    }

    if (timeline.isNotEmpty) {
      rows.add(
        _FigureData(
          label: 'Histoire',
          value: '${timeline.length} jalons',
          caption: '${timeline.first.year} → ${timeline.last.year}',
          route: '/chronologie',
        ),
      );
    }

    rows.add(
      _FigureData(
        label: 'Le savoir',
        value: '$articleCount articles',
        caption: 'Sources citées, lecture libre',
        route: '/ma-bibliotheque',
      ),
    );

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return _AsideBox(
      title: 'La Côte d’Ivoire en chiffres',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _FigureRow(data: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _FigureData {
  const _FigureData({
    required this.label,
    required this.value,
    required this.caption,
    required this.route,
  });

  final String label;
  final String value;
  final String caption;
  final String route;
}

class _FigureRow extends StatefulWidget {
  const _FigureRow({required this.data});

  final _FigureData data;

  @override
  State<_FigureRow> createState() => _FigureRowState();
}

class _FigureRowState extends State<_FigureRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, widget.data.route),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tone.lineSoft)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.label,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                  color: tone.faint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.data.value,
                style: titleStyle(
                  size: 17,
                  weight: FontWeight.w700,
                  color: _hover ? IvoireColors.greenDeep : tone.ink,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                widget.data.caption,
                style: TextStyle(fontSize: 11.5, color: tone.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

StatisticIndicator? _indicator(StatisticsSnapshot? stats, String code) {
  if (stats == null) {
    return null;
  }

  for (final indicator in stats.headline) {
    if (indicator.code == code) {
      return indicator;
    }
  }

  return null;
}

/// Reprendre là où le lecteur s'est arrêté, depuis la mémoire de l'appareil.
class _ReadingResume extends StatelessWidget {
  const _ReadingResume();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LibraryEntry>>(
      valueListenable: AppStorage.instance.recent,
      builder: (context, entries, _) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }

        final last = entries.first;
        final when = last.at == null ? '' : formatDate(last.at);
        final tone = ToneColors.from(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: _AsideBox(
            title: 'Reprendre la lecture',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: tone.ink,
                  ),
                ),
                if (last.category != null || when.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (last.category != null) last.category!,
                      when,
                    ].join(' · '),
                    style: TextStyle(fontSize: 11, color: tone.faint),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: HoverLink(
                    label: 'Continuer',
                    onTap: () => wikiGo(context, '/articles/${last.slug}'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tirage au sort : une entrée discrète, pour flâner dans l'encyclopédie.
class _RandomPickCard extends StatelessWidget {
  const _RandomPickCard({required this.onRandom});

  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return _AsideBox(
      title: 'Article au hasard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parcourir l’encyclopédie sans choisir de sujet.',
            style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.muted),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRandom,
            icon: const Icon(Icons.shuffle, size: 15),
            label: const Text('Tirer un article'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributeBox extends StatelessWidget {
  const _ContributeBox();

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return _AsideBox(
      title: 'Contribuer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IVOIREPEDIA se construit à plusieurs : chercheurs, enseignants, '
            'étudiants, gardiens de la mémoire.',
            style: TextStyle(fontSize: 12.5, height: 1.6, color: tone.body),
          ),
          const SizedBox(height: 10),
          HoverLink(
            label: 'Charte et sources',
            onTap: () => wikiGo(context, '/sources'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          HoverLink(
            label: 'Créer un compte',
            onTap: () => wikiNotImplemented(context, 'Créer un compte'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
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
    final tone = ToneColors.from(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle(
              size: 13.5,
              weight: FontWeight.w700,
              color: tone.ink,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
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
        Center(child: Skeleton(width: 260, height: 120)),
        SizedBox(height: 20),
        Center(child: Skeleton(width: 320, height: 14)),
        SizedBox(height: 10),
        Center(child: Skeleton(width: 240, height: 12)),
        SizedBox(height: 30),
        Skeleton(width: 180, height: 18),
        SizedBox(height: 14),
        SkeletonParagraph(lines: 3),
        SizedBox(height: 26),
        Skeleton(width: 180, height: 18),
        SizedBox(height: 14),
        SkeletonParagraph(lines: 4),
      ],
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
          Text(
            'Service indisponible',
            style: titleStyle(size: 24, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
