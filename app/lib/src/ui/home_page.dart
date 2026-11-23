import 'dart:math' as math;

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

/// Domaines dont la photo montre un lieu, un paysage ou un patrimoine : la
/// couverture doit donner à voir le pays, pas un portrait.
const Set<String> _visualDomains = {'geographie', 'patrimoine', 'culture'};

/// Photos de couverture : des vues larges et nettes d'un lieu ou d'une fierté
/// culturelle du pays — la danse zaouli, la ville historique de Grand-Bassam,
/// les montagnes de Man, les rues de Korhogo. Le tirage les sert en priorité ;
/// les autres photos de géographie, de patrimoine ou de culture prennent le
/// relais quand l'une manque au corpus.
const Set<String> _coverFavourites = {
  'le-zaouli',
  'grand-bassam',
  'man',
  'korhogo',
};

/// Tirage de la visite : une des meilleures photos du pays ouvre la page, le
/// reste du corpus suit dans un ordre tiré au sort. Deux visites ne montrent
/// donc pas la même une, sans jamais écarter les articles illustrés.
List<ArticleSummary> _shuffledForHome(List<ArticleSummary> items) {
  final random = math.Random();
  final illustrated = [
    for (final item in items)
      if ((item.coverImageUrl ?? '').isNotEmpty) item,
  ];

  // Corpus sans photo : l'ordre servi reste celui de l'API, faute d'image à
  // mettre en avant.
  if (illustrated.isEmpty) {
    return List<ArticleSummary>.of(items);
  }

  final favourites = [
    for (final item in illustrated)
      if (_coverFavourites.contains(item.slug)) item,
  ];
  final vistas = [
    for (final item in illustrated)
      if (_visualDomains.contains(item.categorySlug)) item,
  ];

  final pool = favourites.isNotEmpty
      ? (favourites..shuffle(random))
      : vistas.isNotEmpty
      ? (vistas..shuffle(random))
      : (illustrated..shuffle(random));
  final cover = pool.first;
  final rest = [
    for (final item in items)
      if (item.slug != cover.slug) item,
  ]..shuffle(random);

  return [cover, ...rest];
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
    // Vingt articles : la couverture, trois à la une, quatre au fil et deux
    // « le saviez-vous » — sans jamais réafficher la même entrée. Le tirage
    // y joint les seuls articles candidats à la couverture.
    final articlesFuture = _loadCorpus(api);
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

  /// La première page du corpus, plus les seuls articles candidats à la
  /// couverture : le zaouli (37e publié) et Grand-Bassam (43e) ne figurent pas
  /// dans les vingt derniers articles, mais on ne télécharge pas pour autant
  /// tout le corpus. Un appel en panne laisse la couverture sur ce qui est
  /// déjà chargé.
  Future<PagedArticles> _loadCorpus(IvoirepediaApi api) async {
    final first = await api.fetchArticles(limit: 20);
    final candidates = await _optional(
      () => api.fetchArticles(
        slugs: _coverFavourites.toList(growable: false),
        limit: _coverFavourites.length,
      ),
      const PagedArticles(items: [], page: 1, limit: 0, total: 0),
    );

    final items = <ArticleSummary>[...first.items];
    final seen = {for (final item in first.items) item.slug};

    for (final item in candidates.items) {
      if (seen.add(item.slug)) {
        items.add(item);
      }
    }

    return PagedArticles(
      items: items,
      page: first.page,
      limit: first.limit,
      total: first.total,
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
    final data = _data;
    final error = _error;

    return SiteShell(
      immersiveHeader: true,
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

  /// L'ordre est tiré une fois par visite : la couverture ne change pas sous
  /// les yeux du lecteur pendant qu'il parcourt la page.
  late final List<ArticleSummary> _articles = _shuffledForHome(
    widget.data.articles.items,
  );

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
    // La une consomme l'article principal et deux secondaires ; le fil prend
    // la suite sans jamais les répéter, et « le saviez-vous » ferme le corpus.
    // Sur un corpus court, les deux sections se rabattent sur ce qui existe.
    final rest = _articles.skip(1).toList(growable: false);
    final leadPage = rest.take(3).toList(growable: false);
    final feedPage = rest.skip(3).take(4).toList(growable: false);
    final feed = feedPage.isEmpty
        ? rest.take(4).toList(growable: false)
        : feedPage;
    final factsPage = _articles.skip(9).take(2).toList(growable: false);
    final facts = factsPage.isEmpty
        ? feed.take(2).toList(growable: false)
        : factsPage;
    final regions = _topRegions(data.statistics);

    final contents = <HomeSectionEntry>[
      const HomeSectionEntry('article', 'La une'),
      if (timeline.isNotEmpty)
        const HomeSectionEntry('histoire', 'Aujourd’hui dans l’histoire'),
      if (regions.isNotEmpty)
        const HomeSectionEntry('regions', 'Explorer les régions'),
      if (feed.isNotEmpty)
        const HomeSectionEntry('articles', 'Le fil des publications'),
      if (facts.isNotEmpty)
        const HomeSectionEntry('saviez-vous', 'Le saviez-vous ?'),
      if (data.stories.isNotEmpty)
        const HomeSectionEntry('recits', 'Récits et mémoire'),
      const HomeSectionEntry('sources', 'Bibliothèque des sources'),
      const HomeSectionEntry('index', 'Index de A à Z'),
      if (data.categories.isNotEmpty)
        const HomeSectionEntry('portails', 'Les domaines'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeMasthead(
          articleCount: data.articles.total,
          domains: data.categories.length,
          categories: data.categories,
        ),
        HomeOpening(
          articleCount: data.articles.total,
          domains: data.categories.length,
          sourceCount: data.sources?.referenceCount ?? 0,
          categories: data.categories,
          articles: _articles,
          stats: data.statistics,
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
                    child: HomeLeadGrid(articles: leadPage),
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
                      child: HomeBand(
                        child: HomeRegionTiles(
                          regions: regions,
                          censusYear: data.statistics?.census.year,
                        ),
                      ),
                    ),
                  ],
                  if (feed.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('articles'),
                      child: HomeFeed(articles: feed),
                    ),
                  ],
                  if (facts.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('saviez-vous'),
                      child: HomeFactBand(facts: facts),
                    ),
                  ],
                  if (data.stories.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      key: _anchor('recits'),
                      child: HomeBand(
                        highlight: true,
                        child: _MemoryStories(
                          stories: data.stories.take(3).toList(),
                        ),
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
            child: HomeBand(
              child: HomePortalsBand(categories: data.categories),
            ),
          ),
        ],
        const SizedBox(height: 34),
        Container(key: _anchor('index'), child: const HomeAlphaIndex()),
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

/// Les récits documentés : trois fiches, chacune annonçant sa période et la
/// source qui l'appuie.
class _MemoryStories extends StatelessWidget {
  const _MemoryStories({required this.stories});

  final List<HistoryStory> stories;

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      title: 'Récits et mémoire',
      trailing: HoverLink(
        label: 'Tous les récits',
        onTap: () => wikiGo(context, '/histoires'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeIntro(
            'Des épisodes documentés, chacun appuyé sur une source vérifiable.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 3 : 1;
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 2 * 12) / 3;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final story in stories)
                    SizedBox(
                      width: width,
                      child: _StoryCard(story: story),
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

class _StoryCard extends StatefulWidget {
  const _StoryCard({required this.story});

  final HistoryStory story;

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final story = widget.story;
    final source = [
      story.source.publisher ?? story.source.title,
      if (story.source.year != null) '${story.source.year}',
    ].join(' · ');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/histoires?recit=${story.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          decoration: BoxDecoration(
            color: tone.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? IvoireColors.terracotta : tone.lineSoft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: IvoireColors.terracotta.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      (story.period ?? 'Récit').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w700,
                        color: IvoireColors.terracotta,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward,
                    size: 12,
                    color: _hover ? IvoireColors.terracotta : tone.faint,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle(
                  size: 15,
                  weight: FontWeight.w600,
                  color: _hover ? IvoireColors.terracotta : tone.ink,
                  height: 1.32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                story.teaser,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.55,
                  color: tone.body,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(Icons.verified_outlined, size: 11, color: tone.faint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Source : $source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: tone.faint),
                    ),
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

/// La bibliothèque des sources : le chiffre en tête, puis les portes de la
/// section.
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
          if (hasFigures) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _grouped(library.referenceCount),
                  style: titleStyle(
                    size: 24,
                    weight: FontWeight.w700,
                    color: IvoireColors.greenDeep,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'références',
                  style: TextStyle(fontSize: 11.5, color: tone.muted),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${library.institutionCount} institutions · '
              '${library.articleCount} articles sourcés',
              style: TextStyle(fontSize: 11.5, height: 1.5, color: tone.faint),
            ),
            if (library.mentionCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${_grouped(library.mentionCount)} appels de source dans les textes.',
                style: TextStyle(fontSize: 11, height: 1.5, color: tone.faint),
              ),
            ],
          ] else
            Text(
              'Les références citées par les articles, classées par '
              'institution, avec leur lien.',
              style: TextStyle(fontSize: 12.5, height: 1.6, color: tone.body),
            ),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: IvoireColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: titleStyle(
                    size: 13.5,
                    weight: FontWeight.w700,
                    color: tone.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
        icon: Icons.timeline,
        accent: IvoireColors.terracotta,
      ),
      _ExploreData(
        title: 'Lieux et territoires',
        description:
            'Districts, régions et villes du recensement, avec leur climat.',
        route: '/lieux',
        icon: Icons.map_outlined,
        accent: IvoireColors.green,
      ),
      _ExploreData(
        title: 'La Côte d’Ivoire en chiffres',
        description:
            'Démographie, économie, éducation et climat, avec leurs sources.',
        route: '/statistiques',
        icon: Icons.insights_outlined,
        accent: IvoireColors.orangeDeep,
      ),
      _ExploreData(
        title: 'Récits et mémoire',
        description: 'Des épisodes racontés, chacun appuyé sur une source.',
        route: '/histoires',
        icon: Icons.auto_stories_outlined,
        accent: IvoireColors.terracotta,
      ),
      _ExploreData(
        title: 'Bibliothèque des sources',
        description: 'Les références citées, classées par institution.',
        route: '/sources',
        icon: Icons.library_books_outlined,
        accent: IvoireColors.greenDeep,
      ),
      _ExploreData(
        title: 'Ma bibliothèque',
        description: 'Les articles que vous avez lus, gardés sur cet appareil.',
        route: '/ma-bibliotheque',
        icon: Icons.bookmarks_outlined,
        accent: IvoireColors.orange,
      ),
    ];

    return HomeSection(
      title: 'Explorer l’encyclopédie',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 820
              ? 3
              : (constraints.maxWidth >= 460 ? 2 : 1);
          final width = (constraints.maxWidth - (columns - 1) * 14) / columns;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
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
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
  final Color accent;
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
    final accent = widget.data.accent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, widget.data.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
          decoration: BoxDecoration(
            color: tone.paper,
            border: Border.all(color: _hover ? accent : tone.lineSoft),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.data.icon, size: 17, color: accent),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward,
                    size: 13,
                    color: _hover ? accent : tone.faint,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.data.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _hover ? accent : tone.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.description,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: IvoireColors.greenDeep,
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 19,
                  color: IvoireColors.gold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ce que garantit IVOIREPEDIA',
                        style: titleStyle(
                          size: 15.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'La charte éditoriale, en quatre engagements.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760
                        ? 4
                        : (constraints.maxWidth >= 460 ? 2 : 1);
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 14,
                      children: [
                        for (var i = 0; i < promises.length; i++)
                          SizedBox(
                            width: width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '0${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: IvoireColors.orangeDeep,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  promises[i].title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: tone.ink,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  promises[i].body,
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
                const SizedBox(height: 15),
                Container(height: 1, color: tone.lineSoft),
                const SizedBox(height: 11),
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
        Skeleton(height: 196, radius: 12),
        SizedBox(height: 12),
        Skeleton(height: 34, radius: 8),
        SizedBox(height: 26),
        Skeleton(width: 180, height: 18),
        SizedBox(height: 14),
        Skeleton(height: 286, radius: 10),
        SizedBox(height: 16),
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
