import 'package:flutter/material.dart';

import '../api.dart';
import '../brand.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../models/history.dart';
import '../models/sources.dart';
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

/// Page d'accueil : une page de portail, organisée comme une encyclopédie.
///
/// La manchette donne la promesse et les repères, le sommaire donne le plan de
/// la page, les portails donnent le plan de l'encyclopédie, puis viennent les
/// entrées — article du jour, histoire, frise, régions, publications, récits —
/// et la colonne des outils du lecteur. Aucune rubrique n'est remplie de faux
/// contenu : quand la donnée manque, elle dit ce qu'elle attend.
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
    required this.stories,
    this.statistics,
    this.sources,
  });

  final List<Category> categories;
  final PagedArticles articles;
  final List<TimelineEvent> timeline;
  final List<HistoryStory> stories;
  final StatisticsSnapshot? statistics;
  final SourceLibrary? sources;
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

    // Les appels partent ensemble : la page attend le plus lent, pas la somme.
    final categoriesFuture = api.fetchCategories();
    final articlesFuture = api.fetchArticles(limit: 9);

    // Les rubriques secondaires ne doivent pas emporter la « une » : la frise,
    // les chiffres, les récits et la bibliothèque sont facultatifs.
    final timelineFuture = _optional(api.fetchTimeline, const <TimelineEvent>[]);
    final statisticsFuture = _optional(api.fetchStatistics, null);
    final storiesFuture = _optional(api.fetchHistory, const <HistoryStory>[]);
    final sourcesFuture = _optional(api.fetchSources, null);

    final categories = await categoriesFuture;
    final articles = await articlesFuture;
    final timeline = await timelineFuture;
    final statistics = await statisticsFuture;
    final stories = await storiesFuture;
    final sources = await sourcesFuture;

    return _HomeData(
      categories: categories,
      articles: articles,
      timeline: timeline,
      stories: stories,
      statistics: statistics,
      sources: sources,
    );
  }

  /// Un appel facultatif : en cas de panne, la valeur de repli suffit.
  Future<T> _optional<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (_) {
      return fallback;
    }
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

class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.data, required this.onRandom});

  final _HomeData data;
  final VoidCallback onRandom;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

/// Une entrée du sommaire : son identifiant de section et son libellé.
class _ContentsEntry {
  const _ContentsEntry(this.id, this.label);

  final String id;
  final String label;
}

class _HomeBodyState extends State<_HomeBody> {
  final Map<String, GlobalKey> _sections = <String, GlobalKey>{};

  GlobalKey _anchor(String id) =>
      _sections.putIfAbsent(id, () => GlobalKey(debugLabel: id));

  /// Le sommaire conduit à la rubrique sans quitter la page.
  void _jumpTo(String id) {
    final anchor = _sections[id]?.currentContext;

    if (anchor == null) {
      return;
    }

    Scrollable.ensureVisible(
      anchor,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final timeline = data.timeline;
    final others = data.articles.items.skip(1).take(8).toList();
    final regions = _topRegions(data.statistics);

    final contents = <_ContentsEntry>[
      const _ContentsEntry('article', 'Article du jour'),
      if (timeline.isNotEmpty) ...[
        const _ContentsEntry('histoire', 'Aujourd’hui dans l’histoire'),
        const _ContentsEntry('frise', 'La frise en un coup d’œil'),
      ],
      if (regions.isNotEmpty) const _ContentsEntry('regions', 'Explorer les régions'),
      if (others.isNotEmpty) const _ContentsEntry('articles', 'Dernières publications'),
      if (data.stories.isNotEmpty) const _ContentsEntry('recits', 'Récits et mémoire'),
      const _ContentsEntry('sources', 'Bibliothèque des sources'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Masthead(
          articleCount: data.articles.total,
          domains: data.categories.length,
          categories: data.categories,
        ),
        const SizedBox(height: 26),
        _Contents(
          entries: contents,
          onJump: _jumpTo,
          sourceCount: data.sources?.referenceCount ?? 0,
        ),
        if (data.categories.isNotEmpty) ...[
          const SizedBox(height: 30),
          _Portals(categories: data.categories),
        ],
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;

            final main = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: _anchor('article'),
                    child: _LeadStory(page: data.articles),
                  ),
                  if (timeline.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('histoire'),
                      child: _TodayInHistory(events: timeline),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('frise'),
                      child: _TimelineRail(events: timeline),
                    ),
                  ],
                  if (regions.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('regions'),
                      child: _Regions(
                        regions: regions,
                        censusYear: data.statistics?.census.year,
                      ),
                    ),
                  ],
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('articles'),
                      child: _LatestArticles(articles: others),
                    ),
                  ],
                  if (data.stories.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('recits'),
                      child: _MemoryStories(stories: data.stories.take(3).toList()),
                    ),
                  ],
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    _DidYouKnow(page: data.articles),
                  ],
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
                _RandomPickCard(onRandom: widget.onRandom),
                const SizedBox(height: 18),
                Container(
                  key: _anchor('sources'),
                  child: _SourceLibraryBox(sources: data.sources),
                ),
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
        const SizedBox(height: 34),
        const _ExploreIndex(),
        const SizedBox(height: 34),
        const _Charter(),
      ],
    );
  }
}

/// Les régions les plus peuplées du recensement, pour entrer dans le pays.
List<StatisticDivision> _topRegions(StatisticsSnapshot? stats) {
  if (stats == null) {
    return const <StatisticDivision>[];
  }

  final regions = [...stats.regions]..sort((a, b) => b.population.compareTo(a.population));

  return regions.take(8).toList(growable: false);
}

/// Séparateur de milliers à la française : espace fine insécable.
String _grouped(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('\u202F');
    }

    buffer.write(digits[i]);
  }

  return buffer.toString();
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
            filterQuality: FilterQuality.high,
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

/// Sommaire de la page : le plan, numéroté, qui conduit à chaque rubrique.
/// C'est la pièce qui distingue une page d'encyclopédie d'un fil d'actualité.
class _Contents extends StatelessWidget {
  const _Contents({
    required this.entries,
    required this.onJump,
    required this.sourceCount,
  });

  final List<_ContentsEntry> entries;
  final void Function(String id) onJump;
  final int sourceCount;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Sommaire',
                style: titleStyle(
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: tone.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cette page en ${entries.length} rubriques',
                  style: TextStyle(fontSize: 11.5, color: tone.faint),
                ),
              ),
              if (sourceCount > 0)
                Text(
                  '$sourceCount sources citées',
                  style: TextStyle(fontSize: 11.5, color: tone.faint),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              for (var i = 0; i < entries.length; i++)
                _ContentsLink(
                  index: i + 1,
                  entry: entries[i],
                  onTap: () => onJump(entries[i].id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentsLink extends StatefulWidget {
  const _ContentsLink({
    required this.index,
    required this.entry,
    required this.onTap,
  });

  final int index;
  final _ContentsEntry entry;
  final VoidCallback onTap;

  @override
  State<_ContentsLink> createState() => _ContentsLinkState();
}

class _ContentsLinkState extends State<_ContentsLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final number = widget.index.toString().padLeft(2, '0');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _hover ? IvoireColors.greenDeep : tone.faint,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                widget.entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _hover ? IvoireColors.greenDeep : tone.body,
                  decoration: _hover ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: IvoireColors.greenDeep,
                ),
              ),
            ),
          ],
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

/// Un titre suivi d'un chapeau : le format d'entrée d'encyclopédie.
class _SectionIntro extends StatelessWidget {
  const _SectionIntro(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, height: 1.6, color: tone.muted),
      ),
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

/// La frise en un coup d’œil : une vraie ligne du temps, avec ses jalons
/// posés sur un axe continu. La bande se fait défiler au doigt ou à la
/// molette, et chaque jalon ouvre le récit dont il est tiré.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    // La hauteur suit l'agrandissement du texte choisi dans « Confort de
    // lecture », pour que les titres ne soient jamais rognés.
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return _Section(
      title: 'La frise en un coup d’œil',
      trailing: HoverLink(
        label: 'Voir la frise complète',
        onTap: () => wikiGo(context, '/chronologie'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: SizedBox(
        height: 148 * scale.clamp(1.0, 1.45),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (context, index) => _RailEvent(event: events[index]),
        ),
      ),
    );
  }
}

/// Un jalon posé sur l'axe : l'année, l'époque, la ligne et le titre.
class _RailEvent extends StatefulWidget {
  const _RailEvent({required this.event});

  final TimelineEvent event;

  @override
  State<_RailEvent> createState() => _RailEventState();
}

class _RailEventState extends State<_RailEvent> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final year = widget.event.year;
    final label = year < 0 ? '${-year} av. J.-C.' : '$year';
    final accent = _hover ? IvoireColors.green : IvoireColors.terracotta;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/histoires?recit=${widget.event.slug}'),
        child: SizedBox(
          width: 212,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(
                    size: 21,
                    weight: FontWeight.w700,
                    color: _hover ? IvoireColors.greenDeep : accent,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  widget.event.era.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.2,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w600,
                    color: tone.faint,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // L'axe court d'un jalon au suivant : les segments se touchent,
              // la ligne reste continue d'un bout à l'autre de la bande.
              SizedBox(
                height: 11,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hover ? IvoireColors.green : IvoireColors.terracotta,
                        border: Border.all(color: tone.paper, width: 2),
                      ),
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        height: 1,
                        color: _hover
                            ? IvoireColors.green.withValues(alpha: 0.45)
                            : tone.line,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  widget.event.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: _hover ? FontWeight.w600 : FontWeight.w400,
                    color: _hover ? IvoireColors.greenDeep : tone.body,
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

/// Explorer les régions : les effectifs du recensement servent de porte
/// d'entrée géographique, avec leur année et leur source.
class _Regions extends StatelessWidget {
  const _Regions({required this.regions, this.censusYear});

  final List<StatisticDivision> regions;
  final int? censusYear;

  @override
  Widget build(BuildContext context) {
    final census = censusYear == null ? 'Recensement' : 'RGPH $censusYear';

    return _Section(
      title: 'Explorer les régions',
      trailing: HoverLink(
        label: 'Tout le découpage',
        onTap: () => wikiGo(context, '/lieux'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIntro(
            'Les régions les plus peuplées du dernier recensement. Chacune '
            'ouvre sa fiche : climat, villes et récits.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620
                  ? 3
                  : (constraints.maxWidth >= 400 ? 2 : 1);
              final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final region in regions)
                    SizedBox(
                      width: width,
                      child: _RegionCard(region: region, census: census),
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

class _RegionCard extends StatefulWidget {
  const _RegionCard({required this.region, required this.census});

  final StatisticDivision region;
  final String census;

  @override
  State<_RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<_RegionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final region = widget.region;
    final slug = region.slug;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Une région qui a sa fiche y conduit ; les autres mènent à l'annuaire
        // des lieux, plutôt que nulle part.
        onTap: () => wikiGo(
          context,
          slug == null || slug.isEmpty ? '/lieux' : '/lieux/$slug',
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
          decoration: BoxDecoration(
            color: _hover ? tone.paper : Colors.transparent,
            border: Border.all(color: _hover ? tone.line : tone.lineSoft),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _hover ? IvoireColors.greenDeep : tone.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_grouped(region.population)} habitants',
                style: titleStyle(
                  size: 15,
                  weight: FontWeight.w600,
                  color: tone.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.census,
                style: TextStyle(fontSize: 11, color: tone.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Les autres publications : une grille de fiches courtes, avec vignette,
/// catégorie et temps de lecture.
class _LatestArticles extends StatelessWidget {
  const _LatestArticles({required this.articles});

  final List<ArticleSummary> articles;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Dernières publications',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 620 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 18) / columns;

          return Wrap(
            spacing: 18,
            runSpacing: 14,
            children: [
              for (final article in articles)
                SizedBox(width: width, child: _ArticleCard(article: article)),
            ],
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  const _ArticleCard({required this.article});

  final ArticleSummary article;

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final article = widget.article;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/articles/${article.slug}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleThumb(article: article, width: 84, height: 62, radius: 3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      if (article.categoryName != null) article.categoryName!,
                      article.typeLabel,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: tone.faint),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: _hover ? IvoireColors.greenDeep : tone.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, height: 1.5, color: tone.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Les récits documentés : chaque carte annonce sa période et sa source, ce
/// qui est précisément la promesse de la section « Histoire ».
class _MemoryStories extends StatelessWidget {
  const _MemoryStories({required this.stories});

  final List<HistoryStory> stories;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Récits et mémoire',
      trailing: HoverLink(
        label: 'Tous les récits',
        onTap: () => wikiGo(context, '/histoires'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIntro(
            'Des épisodes documentés, chacun appuyé sur une source vérifiable.',
          ),
          for (var i = 0; i < stories.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: ToneColors.from(context).lineSoft),
              ),
            _StoryRow(story: stories[i]),
          ],
        ],
      ),
    );
  }
}

class _StoryRow extends StatefulWidget {
  const _StoryRow({required this.story});

  final HistoryStory story;

  @override
  State<_StoryRow> createState() => _StoryRowState();
}

class _StoryRowState extends State<_StoryRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final story = widget.story;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/histoires?recit=${story.slug}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 116,
              child: Text(
                story.period ?? 'Récit',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: tone.faint,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: titleStyle(
                      size: 15,
                      weight: FontWeight.w600,
                      color: _hover ? IvoireColors.greenDeep : tone.ink,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    story.teaser,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.body),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Source : ${story.source.publisher ?? story.source.title}'
                    '${story.source.year != null ? ' (${story.source.year})' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: tone.faint),
                  ),
                ],
              ),
            ),
          ],
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

/// Les portails thématiques, en tête de page : le plan complet de
/// l'encyclopédie, avec le nombre d'articles de chaque domaine.
class _Portals extends StatelessWidget {
  const _Portals({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Portails thématiques',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIntro(
            'Tous les domaines de l’encyclopédie, avec le nombre d’articles '
            'publiés. Chaque portail ouvre sa liste.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760
                  ? 3
                  : (constraints.maxWidth >= 460 ? 2 : 1);
              final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final category in categories)
                    SizedBox(
                      width: width,
                      child: _PortalCard(category: category),
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

class _PortalCard extends StatefulWidget {
  const _PortalCard({required this.category});

  final Category category;

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final category = widget.category;
    final initial = category.name.isEmpty ? '·' : category.name.substring(0, 1);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/categories/${category.slug}'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
          decoration: BoxDecoration(
            color: _hover ? tone.paper : Colors.transparent,
            border: Border.all(color: _hover ? tone.line : tone.lineSoft),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: IvoireColors.sand,
                      border: Border.all(color: tone.lineSoft),
                    ),
                    child: Text(
                      initial.toUpperCase(),
                      style: titleStyle(
                        size: 15,
                        weight: FontWeight.w700,
                        color: IvoireColors.terracotta,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: _hover ? IvoireColors.greenDeep : tone.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${category.articleCount}',
                    style: TextStyle(fontSize: 11.5, color: tone.faint),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                category.description?.trim().isNotEmpty == true
                    ? category.description!
                    : 'Portail thématique de l’encyclopédie.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.muted),
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

/// La bibliothèque des sources : le nombre d'institutions et de références
/// derrière les articles, avec la porte d'entrée de la section.
class _SourceLibraryBox extends StatelessWidget {
  const _SourceLibraryBox({required this.sources});

  final SourceLibrary? sources;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final library = sources;
    final hasFigures = library != null && library.referenceCount > 0;

    return _AsideBox(
      title: 'Bibliothèque des sources',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasFigures
                ? '${_grouped(library.referenceCount)} références, '
                    '${library.institutionCount} institutions, '
                    '${library.articleCount} articles sourcés.'
                : 'Les références citées par les articles, classées par '
                    'institution, avec leur lien.',
            style: TextStyle(fontSize: 12.5, height: 1.6, color: tone.body),
          ),
          if (hasFigures && library.mentionCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${_grouped(library.mentionCount)} appels de source dans les textes.',
              style: TextStyle(fontSize: 11.5, color: tone.faint),
            ),
          ],
          const SizedBox(height: 10),
          HoverLink(
            label: 'Ouvrir la bibliothèque',
            onTap: () => wikiGo(context, '/sources'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
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
            onTap: () => wikiGo(context, '/inscription'),
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

/// Explorer autrement : les autres entrées de l'encyclopédie, avec ce qu'on y
/// trouve — la page d'accueil ne doit pas être un cul-de-sac.
class _ExploreIndex extends StatelessWidget {
  const _ExploreIndex();

  @override
  Widget build(BuildContext context) {
    const entries = <_ExploreData>[
      _ExploreData(
        title: 'Chronologie',
        description: 'Les jalons datés, du royaume d’Indénié à la République.',
        route: '/chronologie',
      ),
      _ExploreData(
        title: 'Lieux et territoires',
        description: 'Districts, régions et villes du recensement, avec leur climat.',
        route: '/lieux',
      ),
      _ExploreData(
        title: 'La Côte d’Ivoire en chiffres',
        description: 'Démographie, économie, éducation et climat, avec leurs sources.',
        route: '/statistiques',
      ),
      _ExploreData(
        title: 'Récits et mémoire',
        description: 'Des épisodes racontés, chacun appuyé sur une source.',
        route: '/histoires',
      ),
      _ExploreData(
        title: 'Bibliothèque des sources',
        description: 'Les références citées, classées par institution.',
        route: '/sources',
      ),
      _ExploreData(
        title: 'Ma bibliothèque',
        description: 'Les articles que vous avez lus, gardés sur cet appareil.',
        route: '/ma-bibliotheque',
      ),
    ];

    return _Section(
      title: 'Explorer l’encyclopédie',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 3
              : (constraints.maxWidth >= 460 ? 2 : 1);
          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final entry in entries)
                SizedBox(width: width, child: _ExploreCard(data: entry)),
            ],
          );
        },
      ),
    );
  }
}

class _ExploreData {
  const _ExploreData({
    required this.title,
    required this.description,
    required this.route,
  });

  final String title;
  final String description;
  final String route;
}

class _ExploreCard extends StatefulWidget {
  const _ExploreCard({required this.data});

  final _ExploreData data;

  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, widget.data.route),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
          decoration: BoxDecoration(
            color: _hover ? tone.paper : Colors.transparent,
            border: Border.all(color: _hover ? tone.line : tone.lineSoft),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.data.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hover ? IvoireColors.greenDeep : tone.ink,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward,
                    size: 13,
                    color: _hover ? IvoireColors.greenDeep : tone.faint,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.data.description,
                style: TextStyle(fontSize: 12.5, height: 1.55, color: tone.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ce que le site garantit, en pied de page : la charte éditoriale en quatre
/// phrases, sans chiffre inventé ni promesse qui ne soit tenue par le code.
class _Charter extends StatelessWidget {
  const _Charter();

  @override
  Widget build(BuildContext context) {
    const promises = <_PromiseData>[
      _PromiseData(
        title: 'Des sources citées',
        body: 'Chaque article publié renvoie à au moins une source consultable.',
      ),
      _PromiseData(
        title: 'Des versions datées',
        body: 'Chaque soumission et chaque publication laissent une version datée.',
      ),
      _PromiseData(
        title: 'Une lecture libre',
        body: 'Aucun compte, aucun mur payant, aucune publicité pour lire.',
      ),
      _PromiseData(
        title: 'Des corrections tracées',
        body: 'Une correction est une nouvelle version, jamais une réécriture muette.',
      ),
    ];

    final tone = ToneColors.from(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce que garantit IVOIREPEDIA',
            style: titleStyle(size: 14, weight: FontWeight.w700, color: tone.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'La charte éditoriale, en quatre engagements.',
            style: TextStyle(fontSize: 12, color: tone.faint),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760
                  ? 4
                  : (constraints.maxWidth >= 460 ? 2 : 1);
              final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (final promise in promises)
                    SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promise.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: tone.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            promise.body,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: tone.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              HoverLink(
                label: 'Lire la charte et les sources',
                onTap: () => wikiGo(context, '/sources'),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              HoverLink(
                label: 'Contribuer',
                onTap: () => wikiGo(context, '/inscription'),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              HoverLink(
                label: 'Rechercher un sujet',
                onTap: () => wikiGo(context, '/recherche'),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromiseData {
  const _PromiseData({required this.title, required this.body});

  final String title;
  final String body;
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
