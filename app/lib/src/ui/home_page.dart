import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../models/statistics.dart';
import '../models/timeline.dart';
import '../storage.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';

/// Page d'accueil : une « une » d'encyclopédie. Une bande d'ouverture, les
/// chiffres du pays, l'article du jour, un jalon du jour, la frise en un coup
/// d'œil, puis les domaines et les outils du lecteur.
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
      // Statistiques indisponibles : les cartes de chiffres disparaissent.
    }

    return _HomeData(
      categories: categories,
      articles: articles,
      timeline: timeline,
      statistics: statistics,
    );
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

            return _HomeBody(
              data: snapshot.data!,
              onRandom: () => _openRandom(snapshot.data!.articles),
            );
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
    final stats = data.statistics;
    final timeline = data.timeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(
          articleCount: data.articles.total,
          domains: data.categories.length,
          timeline: timeline,
          stats: stats,
        ),
        const SizedBox(height: 22),
        _KeyFigures(
          stats: stats,
          timeline: timeline,
          articleCount: data.articles.total,
        ),
        if (data.categories.isNotEmpty) ...[
          const SizedBox(height: 28),
          _LearningPaths(categories: data.categories),
        ],
        const SizedBox(height: 32),
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
                    const SizedBox(height: 28),
                    _TodayInHistory(events: timeline),
                    const SizedBox(height: 28),
                    _TimelineRail(events: timeline),
                  ],
                  const SizedBox(height: 28),
                  _DidYouKnow(page: data.articles),
                  const SizedBox(height: 28),
                  _Domains(categories: data.categories),
                ],
              ),
            );

            final aside = Column(
              children: [
                _ReadingResume(),
                const SizedBox(height: 16),
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
                          onTap: onRandom,
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
                const SizedBox(width: 34),
                SizedBox(width: 292, child: aside),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Bande d'ouverture : un panneau de tissu peint à droite, la promesse du
/// site à gauche, et trois portes d'entrée (le temps, les territoires, les
/// chiffres). Le panneau reprend les losanges baoulés et la rosace de pagne
/// du fond, pour que l'accueil ait une matière, pas seulement du texte.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.articleCount,
    required this.domains,
    required this.timeline,
    required this.stats,
  });

  final int articleCount;
  final int domains;
  final List<TimelineEvent> timeline;
  final StatisticsSnapshot? stats;

  @override
  Widget build(BuildContext context) {
    final census = stats?.census;
    final span = timeline.isEmpty
        ? null
        : '${timeline.first.year} → ${timeline.last.year}';
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: IvoireColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: IvoireColors.green.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  'ENCYCLOPÉDIE LIBRE · CÔTE D’IVOIRE',
                  style: kickerStyle(color: IvoireColors.greenDeep),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'La Côte d’Ivoire, documentée.',
              style: titleStyle(size: 40, weight: FontWeight.w700, height: 1.1),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: const Text(
              "IVOIREPEDIA est une encyclopédie libre consacrée à la "
              "Côte d'Ivoire : ses territoires, son histoire, ses langues, "
              'ses institutions et ses cultures. Chacun peut la lire et '
              'l’enrichir ; les articles s’appuient sur des sources citées.',
              style: TextStyle(
                fontSize: 15.5,
                height: 1.7,
                color: IvoireColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 22,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AnimatedCount(value: articleCount, label: 'articles publiés'),
              AnimatedCount(value: domains, label: 'domaines'),
              if (span != null)
                _HeroStat(value: span, label: 'd’histoire couverte'),
              if (census != null && regions > 0)
                _HeroStat(
                  value: '$regions régions',
                  label: '$districts districts',
                ),
            ],
          ),
          const SizedBox(height: 20),
          const _HeroDoors(),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: IvoireColors.ivory,
        border: Border.all(color: IvoireColors.lineSoft),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: IvoireColors.ink.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filet de tissu : le seul endroit où les trois couleurs du
          // drapeau se touchent.
          Row(
            children: [
              for (final color in IvoireColors.weave)
                Expanded(child: Container(height: 4, color: color)),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 820) {
                return content;
              }

              // Panneau posé en fond de la colonne de droite : `Positioned`
              // lui donne la hauteur exacte de l'ouverture, sans contrainte
              // infinie.
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 244),
                    child: content,
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    width: 244,
                    child: _HeroCloth(),
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

/// Panneau de tissu : losanges, rosace et légende. Peint en code, comme le
/// reste des motifs du site.
class _HeroCloth extends StatelessWidget {
  const _HeroCloth();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IvoireColors.sand, IvoireColors.highlight],
        ),
        border: Border(left: BorderSide(color: IvoireColors.lineSoft)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: CustomPaint(
                painter: _ClothPainter(),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'MOTIFS BAOULÉ ET KORHOGO',
              style: kickerStyle(color: IvoireColors.terracotta),
            ),
            const SizedBox(height: 4),
            Text(
              'Losanges tissés, rosaces de pagne et gravures du Nord : '
              'le fond du site reprend des motifs ivoiriens, dessinés '
              'à la main dans le code.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.55,
                color: IvoireColors.muted.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClothPainter extends CustomPainter {
  const _ClothPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = IvoireColors.terracotta.withValues(alpha: 0.35);
    final green = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = IvoireColors.green.withValues(alpha: 0.32);
    final fill = Paint()..color = IvoireColors.orange.withValues(alpha: 0.10);

    // Treillis de losanges.
    const step = 34.0;
    for (double y = 10; y < size.height - 10; y += step) {
      for (double x = 10; x < size.width - 10; x += step) {
        final path = Path()
          ..moveTo(x, y - step * 0.4)
          ..lineTo(x + step * 0.4, y)
          ..lineTo(x, y + step * 0.4)
          ..lineTo(x - step * 0.4, y)
          ..close();
        canvas.drawPath(path, (x + y) % (step * 2) < step ? stroke : green);
      }
    }

    // Rosace centrale, motif de pagne.
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = math.min(size.width, size.height) * 0.26;
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(center, radius * 0.55, green);
    canvas.drawCircle(center, radius * 0.18, fill);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.2,
        center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.9,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClothPainter oldDelegate) => false;
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: IvoireColors.ink,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: IvoireColors.faint),
        ),
      ],
    );
  }
}

/// Trois portes : le temps, les territoires, les chiffres.
class _HeroDoors extends StatelessWidget {
  const _HeroDoors();

  @override
  Widget build(BuildContext context) {
    final doors = [
      (
        icon: Icons.schedule,
        label: 'La frise du temps',
        detail: 'De 1701 à aujourd’hui',
        route: '/chronologie',
      ),
      (
        icon: Icons.place_outlined,
        label: 'Villes et régions',
        detail: 'Districts, régions, chef-lieu',
        route: '/lieux',
      ),
      (
        icon: Icons.insights_outlined,
        label: 'Les chiffres du pays',
        detail: 'Population, économie, climat',
        route: '/statistiques',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final door in doors)
              SizedBox(
                width: width,
                child: _DoorTile(
                  icon: door.icon,
                  label: door.label,
                  detail: door.detail,
                  onTap: () => wikiGo(context, door.route),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DoorTile extends StatefulWidget {
  const _DoorTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  State<_DoorTile> createState() => _DoorTileState();
}

class _DoorTileState extends State<_DoorTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          decoration: BoxDecoration(
            color: _hover ? IvoireColors.paper : IvoireColors.paper.withValues(alpha: 0.7),
            border: Border.all(
              color: _hover ? IvoireColors.green : IvoireColors.lineSoft,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: IvoireColors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: IvoireColors.ink,
                      ),
                    ),
                    Text(
                      widget.detail,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: IvoireColors.faint,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: _hover ? IvoireColors.green : IvoireColors.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quatre chiffres, chacun menant à la page qui les détaille.
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
    final cards = <Widget>[];
    final population = _indicator(stats, 'SP.POP.TOTL');

    if (population != null) {
      cards.add(_FigureCard(
        kicker: 'POPULATION',
        value: population.display ?? '—',
        caption: population.trend?.display ?? 'Donnée ${population.year}',
        accent: IvoireColors.orange,
        route: '/statistiques',
        detail: 'Chiffres du pays',
      ));
    }

    final census = stats?.census;
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;
    if (census != null && regions > 0) {
      cards.add(_FigureCard(
        kicker: 'TERRITOIRES',
        value: '$regions régions',
        caption: '$districts districts · RGPH ${census.year}',
        accent: IvoireColors.green,
        route: '/lieux',
        detail: 'Villes et régions',
      ));
    }

    if (timeline.isNotEmpty) {
      cards.add(_FigureCard(
        kicker: 'HISTOIRE',
        value: '${timeline.length} jalons',
        caption: '${timeline.first.year} → ${timeline.last.year}',
        accent: IvoireColors.terracotta,
        route: '/chronologie',
        detail: 'La frise du temps',
      ));
    }

    cards.add(_FigureCard(
      kicker: 'LE SAVOIR',
      value: '$articleCount articles',
      caption: 'Sources citées, lecture libre',
      accent: IvoireColors.gold,
      route: '/ma-bibliotheque',
      detail: 'Ma bibliothèque',
    ));

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : (constraints.maxWidth >= 560 ? 2 : 1);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
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

class _FigureCard extends StatelessWidget {
  const _FigureCard({
    required this.kicker,
    required this.value,
    required this.caption,
    required this.accent,
    required this.route,
    required this.detail,
  });

  final String kicker;
  final String value;
  final String caption;
  final Color accent;
  final String route;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => wikiGo(context, route),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: IvoireColors.paper,
            border: Border.all(color: IvoireColors.lineSoft),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 3, color: accent),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kicker, style: kickerStyle(color: accent)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: titleStyle(size: 24, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: IvoireColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: IvoireColors.link,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: IvoireColors.link,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'article du jour, mis en scène comme une ouverture de journal.
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

    return _Section(
      title: 'Article du jour',
      child: Container(
        decoration: BoxDecoration(
          color: IvoireColors.paper,
          border: Border.all(color: IvoireColors.lineSoft),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: IvoireColors.weave),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.categoryName != null)
                    Text(
                      article.categoryName!.toUpperCase(),
                      style: kickerStyle(color: IvoireColors.terracotta),
                    ),
                  const SizedBox(height: 8),
                  HoverLink(
                    label: article.title,
                    onTap: () => wikiGo(context, '/articles/${article.slug}'),
                    style: titleStyle(size: 25, weight: FontWeight.w700),
                    color: IvoireColors.ink,
                    hoverColor: IvoireColors.greenDeep,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      article.typeLabel,
                      '${article.readingMinutes} min de lecture',
                      if (article.publishedAt != null)
                        formatDate(article.publishedAt),
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: IvoireColors.faint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.summary,
                    style: const TextStyle(fontSize: 15, height: 1.72),
                  ),
                  const SizedBox(height: 12),
                  HoverLink(
                    label: 'Lire la suite',
                    onTap: () => wikiGo(context, '/articles/${article.slug}'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Un jalon tiré pour la journée : la page change de récit chaque jour, sans
/// hasard serveur ni nouvelle requête.
class _TodayInHistory extends StatelessWidget {
  const _TodayInHistory({required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final event = events[dayOfYear % events.length];
    final age = today.year - event.year;

    return _Section(
      title: 'Aujourd’hui dans l’histoire',
      child: Container(
        decoration: BoxDecoration(
          color: IvoireColors.highlight,
          border: Border.all(color: IvoireColors.lineSoft),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.year}',
                  style: titleStyle(size: 30, weight: FontWeight.w700),
                ),
                Text(
                  age > 0 ? 'il y a $age ans' : 'cette année',
                  style: const TextStyle(
                    fontSize: 11,
                    color: IvoireColors.orangeDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 62,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: IvoireColors.line,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HoverLink(
                    label: event.title,
                    onTap: () =>
                        wikiGo(context, '/histoires?recit=${event.slug}'),
                    style: titleStyle(size: 17, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.teaser,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, height: 1.6),
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
          separatorBuilder: (_, _) => const SizedBox(width: 10),
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
            color: _hover ? IvoireColors.ivory : IvoireColors.paper,
            border: Border.all(
              color: _hover ? IvoireColors.terracotta : IvoireColors.lineSoft,
            ),
            borderRadius: BorderRadius.circular(8),
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
                style: const TextStyle(fontSize: 10, color: IvoireColors.faint),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  widget.event.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, height: 1.4),
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

/// Trois parcours numérotés, tirés des domaines les plus fournis : une entrée
/// guidée pour qui ne sait pas par où commencer.
class _LearningPaths extends StatelessWidget {
  const _LearningPaths({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final sorted = [...categories]
      ..sort((a, b) => b.articleCount.compareTo(a.articleCount));
    final paths = sorted.take(3).toList(growable: false);

    if (paths.isEmpty) {
      return const SizedBox.shrink();
    }

    return _Section(
      title: 'Trois parcours pour apprendre',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 780 ? 3 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < paths.length; i++)
                SizedBox(
                  width: width,
                  child: _PathCard(
                    step: i + 1,
                    category: paths[i],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PathCard extends StatefulWidget {
  const _PathCard({required this.step, required this.category});

  final int step;
  final Category category;

  @override
  State<_PathCard> createState() => _PathCardState();
}

class _PathCardState extends State<_PathCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final accent = _domainColor(category.slug);
    final count = category.articleCount;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, '/categories/${category.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: IvoireColors.paper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover ? accent : IvoireColors.lineSoft,
            ),
            boxShadow: [
              BoxShadow(
                color: IvoireColors.ink.withValues(alpha: _hover ? 0.07 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
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
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.step.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(_domainIcon(category.slug), size: 17, color: accent),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: titleStyle(size: 16, weight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? 'Parcours à compléter'
                    : '$count article${count > 1 ? 's' : ''} à lire',
                style: const TextStyle(
                  fontSize: 12,
                  color: IvoireColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Commencer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: accent),
                ],
              ),
            ],
          ),
        ),
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
          final columns = constraints.maxWidth >= 520 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in categories)
                SizedBox(
                  width: width,
                  child: _DomainTile(category: category),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DomainTile extends StatefulWidget {
  const _DomainTile({required this.category});

  final Category category;

  @override
  State<_DomainTile> createState() => _DomainTileState();
}

class _DomainTileState extends State<_DomainTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final accent = _domainColor(category.slug);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => wikiGo(context, '/categories/${category.slug}'),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: _hover ? IvoireColors.ivory : Colors.transparent,
            border: Border.all(
              color: _hover ? accent.withValues(alpha: 0.5) : IvoireColors.lineSoft,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_domainIcon(category.slug), size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: IvoireColors.ink,
                  ),
                ),
              ),
              Text(
                '${category.articleCount}',
                style: const TextStyle(fontSize: 11.5, color: IvoireColors.faint),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 15,
                color: _hover ? accent : IvoireColors.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Symbole de chaque domaine : un repère visuel vaut mieux qu'une liste
/// indifférenciée, et il rend la page plus facile à parcourir des yeux.
IconData _domainIcon(String slug) {
  return switch (slug) {
    'histoire' => Icons.menu_book_outlined,
    'geographie' => Icons.public,
    'culture' => Icons.music_note_outlined,
    'langues' => Icons.translate,
    'institutions' => Icons.account_balance_outlined,
    'economie' => Icons.trending_up,
    'personnalites' => Icons.person_outline,
    'gastronomie' => Icons.restaurant_outlined,
    _ => Icons.category_outlined,
  };
}

Color _domainColor(String slug) {
  return switch (slug) {
    'histoire' => IvoireColors.terracotta,
    'geographie' => IvoireColors.green,
    'culture' => IvoireColors.orangeDeep,
    'langues' => IvoireColors.gold,
    'institutions' => IvoireColors.greenDeep,
    'economie' => IvoireColors.orange,
    'personnalites' => IvoireColors.terracotta,
    'gastronomie' => IvoireColors.green,
    _ => IvoireColors.green,
  };
}

/// Reprendre là où le lecteur s'est arrêté, depuis la mémoire de l'appareil.
class _ReadingResume extends StatelessWidget {
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _AsideBox(
            title: 'Reprendre la lecture',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(size: 14, weight: FontWeight.w600),
                ),
                if (last.category != null || when.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    [if (last.category != null) last.category!, when].join(' · '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: IvoireColors.faint,
                    ),
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

/// Titre de section à la manière d'un article : titre sobre, filet fin.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle(size: 18.5, weight: FontWeight.w600),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const MotifDivider(),
            const SizedBox(width: 10),
            Expanded(
              child: Container(height: 1, color: IvoireColors.lineSoft),
            ),
          ],
        ),
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
