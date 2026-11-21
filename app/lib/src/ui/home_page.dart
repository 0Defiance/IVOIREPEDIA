import 'package:flutter/material.dart';

import '../api.dart';
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
import 'home_sections.dart';
import 'shell.dart';
import 'wiki_actions.dart';
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
  _HomeData? _data;
  Object? _error;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_started) {
      _started = true;
      _load();
    }
  }

  /// Deux temps de chargement : la une s'affiche dès que les articles sont
  /// là, les rubriques secondaires (frise, chiffres, récits, sources) la
  /// complètent quand elles arrivent. L'écran ne reste jamais vide à les
  /// attendre, alors que la lecture peut commencer sans elles.
  Future<void> _load() async {
    final api = ApiScope.of(context);

    // Tous les appels partent ensemble : le second temps ne coûte pas la
    // durée des requêtes, seulement celle de la plus lente.
    final categoriesFuture = api.fetchCategories();
    final articlesFuture = api.fetchArticles(limit: 9);
    final timelineFuture = _optional(
      api.fetchTimeline,
      const <TimelineEvent>[],
    );
    final statisticsFuture = _optional(api.fetchStatistics, null);
    final storiesFuture = _optional(api.fetchHistory, const <HistoryStory>[]);
    final sourcesFuture = _optional(api.fetchSources, null);

    final PagedArticles articles;
    final List<Category> categories;

    try {
      articles = await articlesFuture;
      categories = await categoriesFuture;
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _error = error);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _error = null;
      _data = _HomeData(
        categories: categories,
        articles: articles,
        timeline: const [],
        stories: const [],
      );
    });

    final timeline = await timelineFuture;
    final statistics = await statisticsFuture;
    final stories = await storiesFuture;
    final sources = await sourcesFuture;

    if (!mounted) {
      return;
    }

    setState(() {
      _data = _HomeData(
        categories: categories,
        articles: articles,
        timeline: timeline,
        stories: stories,
        statistics: statistics,
        sources: sources,
      );
    });
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
    final data = _data;
    final error = _error;

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: error != null
            ? _ErrorBox(
                message: '$error',
                onRetry: () {
                  setState(() {
                    _data = null;
                    _error = null;
                  });
                  _load();
                },
              )
            : data == null
            ? const _HomeSkeleton()
            : _HomeBody(data: data, onRandom: _openRandom),
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
    // Le fil prend la suite de la une ; « le saviez-vous » prend ce qui
    // reste, et se rabat sur les mêmes entrées quand le corpus est court.
    final rest = data.articles.items.skip(1).toList(growable: false);
    final feed = rest.take(6).toList(growable: false);
    final facts = rest.length > 6
        ? rest.skip(6).take(3).toList(growable: false)
        : rest.take(2).toList(growable: false);
    final regions = _topRegions(data.statistics);

    final contents = <HomeSectionEntry>[
      const HomeSectionEntry('article', 'La une'),
      if (timeline.isNotEmpty)
        const HomeSectionEntry('histoire', 'Aujourd’hui dans l’histoire'),
      if (regions.isNotEmpty)
        const HomeSectionEntry('regions', 'Explorer les régions'),
      if (feed.isNotEmpty)
        const HomeSectionEntry('articles', 'Le fil des publications'),
      if (data.stories.isNotEmpty)
        const HomeSectionEntry('recits', 'Récits et mémoire'),
      const HomeSectionEntry('sources', 'Bibliothèque des sources'),
      if (data.categories.isNotEmpty)
        const HomeSectionEntry('portails', 'Les domaines'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeOpening(
          articleCount: data.articles.total,
          domains: data.categories.length,
          sourceCount: data.sources?.referenceCount ?? 0,
          categories: data.categories,
        ),
        const SizedBox(height: 4),
        HomeContentsRail(entries: contents, onJump: _jumpTo),
        const SizedBox(height: 28),
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
                    child: HomeLeadGrid(page: data.articles),
                  ),
                  if (timeline.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('histoire'),
                      child: HomeHistoryBand(
                        events: timeline,
                        onOpen: (slug) =>
                            wikiGo(context, '/histoires?recit=$slug'),
                      ),
                    ),
                  ],
                  if (regions.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('regions'),
                      child: HomeRegionTiles(
                        regions: regions,
                        censusYear: data.statistics?.census.year,
                      ),
                    ),
                  ],
                  if (feed.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('articles'),
                      child: HomeFeed(articles: feed, facts: facts),
                    ),
                  ],
                  if (data.stories.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('recits'),
                      child: _MemoryStories(
                        stories: data.stories.take(3).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );

            final aside = Column(
              children: [
                HomeReaderDesk(
                  stats: data.statistics,
                  articleCount: data.articles.total,
                  timelineCount: timeline.length,
                  onRandom: widget.onRandom,
                ),
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
        if (data.categories.isNotEmpty) ...[
          const SizedBox(height: 34),
          Container(
            key: _anchor('portails'),
            child: HomePortalsBand(categories: data.categories),
          ),
        ],
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

  final regions = [...stats.regions]
    ..sort((a, b) => b.population.compareTo(a.population));

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
                child: Divider(
                  height: 1,
                  color: ToneColors.from(context).lineSoft,
                ),
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
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      color: tone.body,
                    ),
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
        description:
            'Districts, régions et villes du recensement, avec leur climat.',
        route: '/lieux',
      ),
      _ExploreData(
        title: 'La Côte d’Ivoire en chiffres',
        description:
            'Démographie, économie, éducation et climat, avec leurs sources.',
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
                SizedBox(
                  width: width,
                  child: _ExploreCard(data: entry),
                ),
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
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.55,
                  color: tone.muted,
                ),
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
        body:
            'Chaque article publié renvoie à au moins une source consultable.',
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
            style: titleStyle(
              size: 14,
              weight: FontWeight.w700,
              color: tone.ink,
            ),
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
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;

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
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              HoverLink(
                label: 'Contribuer',
                onTap: () => wikiGo(context, '/inscription'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              HoverLink(
                label: 'Rechercher un sujet',
                onTap: () => wikiGo(context, '/recherche'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
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
