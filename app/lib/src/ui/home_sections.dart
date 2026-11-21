import 'package:flutter/material.dart';

import '../brand.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../models/statistics.dart';
import '../models/timeline.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'wiki_actions.dart';
import 'widgets/article_image.dart';
import 'widgets/interactive.dart';

/// Séparateur de milliers à la française : espace fine insécable.
String groupedNumber(int value) {
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

/// Une entrée du sommaire : sa section et son libellé.
class HomeSectionEntry {
  const HomeSectionEntry(this.id, this.label);

  final String id;
  final String label;
}

/// Bandeau d'ouverture : la marque tient en trois lignes, les compteurs et
/// l'accès aux portails sont sur la même ligne. Le contenu commence dans le
/// premier écran.
class HomeOpening extends StatelessWidget {
  const HomeOpening({
    required this.articleCount,
    required this.domains,
    required this.sourceCount,
    required this.categories,
    super.key,
  });

  final int articleCount;
  final int domains;
  final int sourceCount;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final narrow = MediaQuery.sizeOf(context).width < 760;

    final brand = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          kLockupAsset,
          height: narrow ? 54 : 66,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: kTagline,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'L’encyclopédie de la Côte d’Ivoire',
                style: titleStyle(
                  size: narrow ? 17 : 21,
                  weight: FontWeight.w700,
                  color: tone.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$articleCount articles · $domains domaines · '
                '$sourceCount sources citées',
                style: TextStyle(fontSize: 12, color: tone.faint),
              ),
            ],
          ),
        ),
      ],
    );

    final portals = _PortalMenu(categories: categories);

    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tone.lineSoft)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand,
                const SizedBox(height: 12),
                Row(children: [portals]),
              ],
            )
          : Row(
              children: [
                Expanded(child: brand),
                const SizedBox(width: 24),
                portals,
              ],
            ),
    );
  }
}

/// Un seul accès aux domaines en haut de page : un menu, pas une barre de
/// douze liens qui prend la largeur de la manchette.
class _PortalMenu extends StatelessWidget {
  const _PortalMenu({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return PopupMenuButton<String>(
      tooltip: 'Parcourir les portails',
      position: PopupMenuPosition.under,
      onSelected: (slug) => wikiGo(context, '/categories/$slug'),
      itemBuilder: (context) => [
        for (final category in categories)
          PopupMenuItem<String>(
            value: category.slug,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(fontSize: 13, color: tone.ink),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${category.articleCount}',
                  style: TextStyle(fontSize: 11, color: tone.faint),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: tone.paper,
          border: Border.all(color: tone.line),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, size: 14, color: IvoireColors.link),
            const SizedBox(width: 7),
            Text(
              'Portails',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tone.ink,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 15, color: tone.faint),
          ],
        ),
      ),
    );
  }
}

/// Sommaire-rail : les rubriques de la page, numérotées, sur une seule bande.
class HomeContentsRail extends StatelessWidget {
  const HomeContentsRail({
    required this.entries,
    required this.onJump,
    super.key,
  });

  final List<HomeSectionEntry> entries;
  final void Function(String id) onJump;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tone.lineSoft)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Au sommaire',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: tone.faint,
            ),
          ),
          for (var i = 0; i < entries.length; i++)
            _RailLink(
              index: i + 1,
              entry: entries[i],
              onTap: () => onJump(entries[i].id),
            ),
        ],
      ),
    );
  }
}

class _RailLink extends StatefulWidget {
  const _RailLink({
    required this.index,
    required this.entry,
    required this.onTap,
  });

  final int index;
  final HomeSectionEntry entry;
  final VoidCallback onTap;

  @override
  State<_RailLink> createState() => _RailLinkState();
}

class _RailLinkState extends State<_RailLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final color = _hover ? IvoireColors.greenDeep : tone.body;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 10,
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
                    color: color,
                    decoration: _hover
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: IvoireColors.greenDeep,
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

/// Mosaïque de une : un article principal, deux secondaires visibles sans
/// défiler.
class HomeLeadGrid extends StatelessWidget {
  const HomeLeadGrid({required this.page, super.key});

  final PagedArticles page;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    if (page.items.isEmpty) {
      return HomeSection(
        title: 'La une',
        child: Text(
          'Aucun article publié pour le moment.',
          style: TextStyle(color: tone.muted),
        ),
      );
    }

    final lead = page.items.first;
    final secondary = page.items.skip(1).take(2).toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;

        final main = _LeadMain(article: lead);

        if (!wide) {
          return HomeSection(
            title: 'La une',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                main,
                for (final article in secondary) ...[
                  const SizedBox(height: 18),
                  _SecondaryStory(article: article),
                ],
              ],
            ),
          );
        }

        return HomeSection(
          title: 'La une',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: main),
              const SizedBox(width: 28),
              Container(width: 1, height: 330, color: tone.lineSoft),
              const SizedBox(width: 28),
              SizedBox(
                width: 290,
                child: Column(
                  children: [
                    for (var i = 0; i < secondary.length; i++) ...[
                      if (i > 0) ...[
                        const SizedBox(height: 14),
                        Divider(height: 1, color: tone.lineSoft),
                        const SizedBox(height: 14),
                      ],
                      _SecondaryStory(article: secondary[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeadMain extends StatelessWidget {
  const _LeadMain({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final hasImage =
        article.coverImageUrl != null && article.coverImageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          ArticleFigure(article: article, height: 300, radius: 2),
          const SizedBox(height: 14),
        ],
        Text(
          [
            if (article.categoryName != null) article.categoryName!,
            article.typeLabel,
            '${article.readingMinutes} min',
            if (article.publishedAt != null) formatDate(article.publishedAt),
          ].join(' · '),
          style: TextStyle(fontSize: 11.5, color: tone.faint),
        ),
        const SizedBox(height: 6),
        HoverLink(
          label: article.title,
          onTap: () => wikiGo(context, '/articles/${article.slug}'),
          color: tone.ink,
          hoverColor: IvoireColors.greenDeep,
          style: titleStyle(
            size: 30,
            weight: FontWeight.w700,
            color: tone.ink,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Text(
            article.summary,
            style: TextStyle(fontSize: 15.5, height: 1.7, color: tone.body),
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
            const Icon(Icons.arrow_forward, size: 13, color: IvoireColors.link),
          ],
        ),
      ],
    );
  }
}

class _SecondaryStory extends StatelessWidget {
  const _SecondaryStory({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => wikiGo(context, '/articles/${article.slug}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleThumb(article: article, width: 78, height: 78, radius: 3),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.categoryName ?? article.typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: tone.faint),
                ),
                const SizedBox(height: 3),
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: tone.ink,
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${article.readingMinutes} min de lecture',
                  style: TextStyle(fontSize: 11, color: tone.faint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bande historique : l'année en très grand, le récit du jour, puis la frise
/// continue — une seule section au lieu de deux blocs empilés.
class HomeHistoryBand extends StatelessWidget {
  const HomeHistoryBand({
    required this.events,
    required this.onOpen,
    super.key,
  });

  final List<TimelineEvent> events;
  final void Function(String slug) onOpen;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final tone = ToneColors.from(context);
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final event = events[dayOfYear % events.length];
    final age = today.year - event.year;

    return HomeSection(
      title: 'Aujourd’hui dans l’histoire',
      trailing: HoverLink(
        label: 'Voir la frise complète',
        onTap: () => wikiGo(context, '/chronologie'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;

          final story = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 132,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.year}',
                      style: titleStyle(
                        size: 44,
                        weight: FontWeight.w700,
                        color: tone.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      age > 0 ? 'il y a $age ans' : 'cette année',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: IvoireColors.orangeDeep,
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
                      onTap: () => onOpen(event.slug),
                      color: tone.ink,
                      hoverColor: IvoireColors.greenDeep,
                      style: titleStyle(
                        size: 18,
                        weight: FontWeight.w600,
                        color: tone.ink,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
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
                      onTap: () => onOpen(event.slug),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final rail = SizedBox(
            height: 116,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              itemBuilder: (context, index) => _RailEvent(
                event: events[index],
                onTap: () => onOpen(events[index].slug),
              ),
            ),
          );

          // La frise se glisse sous le récit quand la largeur manque.
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: story),
                    const SizedBox(width: 24),
                    Container(width: 1, height: 116, color: tone.lineSoft),
                    const SizedBox(width: 20),
                    SizedBox(width: 300, child: rail),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [story, const SizedBox(height: 18), rail],
                );
        },
      ),
    );
  }
}

class _RailEvent extends StatefulWidget {
  const _RailEvent({required this.event, required this.onTap});

  final TimelineEvent event;
  final VoidCallback onTap;

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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: 186,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle(
                  size: 17,
                  weight: FontWeight.w700,
                  color: _hover
                      ? IvoireColors.greenDeep
                      : IvoireColors.terracotta,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 9,
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hover
                            ? IvoireColors.green
                            : IvoireColors.terracotta,
                        border: Border.all(color: tone.paper, width: 2),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: _hover
                            ? IvoireColors.green.withValues(alpha: 0.45)
                            : tone.line,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                widget.event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: _hover ? IvoireColors.greenDeep : tone.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tuiles de régions : le chiffre d'abord, la comparaison ensuite.
class HomeRegionTiles extends StatelessWidget {
  const HomeRegionTiles({
    required this.regions,
    required this.censusYear,
    super.key,
  });

  final List<StatisticDivision> regions;
  final int? censusYear;

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) {
      return const SizedBox.shrink();
    }

    final census = censusYear == null ? 'Recensement' : 'RGPH $censusYear';
    final max = regions.first.population.toDouble();

    return HomeSection(
      title: 'Explorer les régions',
      trailing: HoverLink(
        label: 'Tout le découpage',
        onTap: () => wikiGo(context, '/lieux'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeIntro(
            'Les régions les plus peuplées du dernier recensement. Chacune '
            'ouvre sa fiche : climat, villes et récits.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620
                  ? 3
                  : (constraints.maxWidth >= 400 ? 2 : 1);
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final region in regions)
                    SizedBox(
                      width: width,
                      child: _RegionTile(
                        region: region,
                        census: census,
                        share: max == 0 ? 0 : region.population / max,
                      ),
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

class _RegionTile extends StatefulWidget {
  const _RegionTile({
    required this.region,
    required this.census,
    required this.share,
  });

  final StatisticDivision region;
  final String census;
  final double share;

  @override
  State<_RegionTile> createState() => _RegionTileState();
}

class _RegionTileState extends State<_RegionTile> {
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
        onTap: () => wikiGo(
          context,
          slug == null || slug.isEmpty ? '/lieux' : '/lieux/$slug',
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _hover ? IvoireColors.greenDeep : tone.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                groupedNumber(region.population),
                style: titleStyle(
                  size: 19,
                  weight: FontWeight.w700,
                  color: tone.ink,
                ),
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 3,
                  color: tone.lineSoft,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: widget.share.clamp(0.04, 1.0),
                    child: Container(
                      color: _hover
                          ? IvoireColors.green
                          : IvoireColors.terracotta,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.census,
                style: TextStyle(fontSize: 10.5, color: tone.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fil des publications : une grille de fiches, puis trois entrées « le
/// saviez-vous » sur une seule ligne.
class HomeFeed extends StatelessWidget {
  const HomeFeed({required this.articles, required this.facts, super.key});

  final List<ArticleSummary> articles;
  final List<ArticleSummary> facts;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return HomeSection(
      title: 'Le fil des publications',
      trailing: HoverLink(
        label: 'Toutes les publications',
        onTap: () => wikiGo(context, '/recherche'),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700
                  ? 3
                  : (constraints.maxWidth >= 440 ? 2 : 1);
              final width =
                  (constraints.maxWidth - (columns - 1) * 18) / columns;

              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final article in articles)
                    SizedBox(
                      width: width,
                      child: _FeedCard(article: article),
                    ),
                ],
              );
            },
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: tone.lineSoft),
                  bottom: BorderSide(color: tone.lineSoft),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LE SAVIEZ-VOUS ?',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: tone.faint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final fact in facts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => wikiGo(context, '/articles/${fact.slug}'),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${fact.title} — ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: IvoireColors.link,
                                ),
                              ),
                              TextSpan(
                                text: fact.summary,
                                style: TextStyle(color: tone.body),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedCard extends StatefulWidget {
  const _FeedCard({required this.article});

  final ArticleSummary article;

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: ArticleThumb(
                article: article,
                width: double.infinity,
                height: 96,
                radius: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.categoryName ?? article.typeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: tone.faint),
            ),
            const SizedBox(height: 3),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle(
                size: 14.5,
                weight: FontWeight.w600,
                color: _hover ? IvoireColors.greenDeep : tone.ink,
                height: 1.32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, height: 1.5, color: tone.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bande des portails : tout le plan de l'encyclopédie, une fois, en bas de
/// page, avec le nombre d'articles de chaque domaine.
class HomePortalsBand extends StatelessWidget {
  const HomePortalsBand({required this.categories, super.key});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return HomeSection(
      title: 'Tous les portails',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 3
              : (constraints.maxWidth >= 460 ? 2 : 1);
          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;

          return Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final category in categories)
                SizedBox(
                  width: width,
                  child: _PortalStrip(category: category),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PortalStrip extends StatefulWidget {
  const _PortalStrip({required this.category});

  final Category category;

  @override
  State<_PortalStrip> createState() => _PortalStripState();
}

class _PortalStripState extends State<_PortalStrip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final category = widget.category;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/categories/${category.slug}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tone.lineSoft)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '${category.articleCount}',
                  style: titleStyle(
                    size: 12,
                    weight: FontWeight.w700,
                    color: _hover
                        ? IvoireColors.greenDeep
                        : IvoireColors.terracotta,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _hover ? IvoireColors.greenDeep : tone.ink,
                      ),
                    ),
                    if (category.description?.trim().isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          category.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: tone.faint),
                        ),
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

/// Poste de travail du lecteur : le chiffre national en tête, trois repères,
/// puis les outils (hasard, bibliothèque, sources).
class HomeReaderDesk extends StatelessWidget {
  const HomeReaderDesk({
    required this.stats,
    required this.articleCount,
    required this.timelineCount,
    required this.onRandom,
    super.key,
  });

  final StatisticsSnapshot? stats;
  final int articleCount;
  final int timelineCount;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final population = _indicator(stats, 'SP.POP.TOTL');
    final census = stats?.census;
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: tone.paper,
        border: Border.all(color: tone.lineSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LA CÔTE D’IVOIRE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: tone.faint,
            ),
          ),
          if (population != null) ...[
            const SizedBox(height: 6),
            Text(
              population.display ?? '—',
              style: titleStyle(
                size: 28,
                weight: FontWeight.w700,
                color: tone.ink,
                height: 1.15,
              ),
            ),
            if (population.trend?.display != null)
              Text(
                population.trend!.display,
                style: TextStyle(fontSize: 11.5, color: tone.muted),
              ),
          ],
          const SizedBox(height: 8),
          if (census != null && regions > 0)
            _DeskRow(
              label: 'Territoires',
              value: '$regions régions',
              caption: '$districts districts · RGPH ${census.year}',
              route: '/lieux',
            ),
          if (timelineCount > 0)
            _DeskRow(
              label: 'Histoire',
              value: '$timelineCount jalons',
              caption: 'Chronologie datée',
              route: '/chronologie',
            ),
          _DeskRow(
            label: 'Le savoir',
            value: '$articleCount articles',
            caption: 'Sources citées, lecture libre',
            route: '/ma-bibliotheque',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              HoverLink(
                label: 'Au hasard',
                onTap: onRandom,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              HoverLink(
                label: 'Bibliothèque des sources',
                onTap: () => wikiGo(context, '/sources'),
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

class _DeskRow extends StatefulWidget {
  const _DeskRow({
    required this.label,
    required this.value,
    required this.caption,
    required this.route,
  });

  final String label;
  final String value;
  final String caption;
  final String route;

  @override
  State<_DeskRow> createState() => _DeskRowState();
}

class _DeskRowState extends State<_DeskRow> {
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
        onTap: () => wikiGo(context, widget.route),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tone.lineSoft)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600,
                        color: tone.faint,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.caption,
                      style: TextStyle(fontSize: 11, color: tone.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.value,
                style: titleStyle(
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: _hover ? IvoireColors.greenDeep : tone.ink,
                ),
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

/// Section numérotée : un libellé à gauche, un filet, puis le contenu. Le
/// rythme vient de la typographie, comme le reste du site.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final narrow = MediaQuery.sizeOf(context).width < 460;

    final heading = Text(
      title,
      style: titleStyle(size: 17, weight: FontWeight.w700, color: tone.ink),
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

/// Un chapeau de section, plus discret que le corps des articles.
class HomeIntro extends StatelessWidget {
  const HomeIntro(this.text, {super.key});

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
