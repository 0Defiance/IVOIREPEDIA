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
import 'widgets/ivorian_patterns.dart';

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

const double _cardRadius = 10;

/// Accent et pictogramme d'un domaine : chaque portail a sa couleur, reprise
/// sur les tuiles, les étiquettes et les cartes du fil.
({Color accent, IconData icon}) _domainLook(String slug) {
  return switch (slug) {
    'histoire' => (
      accent: IvoireColors.terracotta,
      icon: Icons.menu_book_outlined,
    ),
    'geographie' => (accent: IvoireColors.green, icon: Icons.public),
    'personnalites' => (
      accent: IvoireColors.orangeDeep,
      icon: Icons.portrait_outlined,
    ),
    'institutions' => (
      accent: IvoireColors.greenDeep,
      icon: Icons.account_balance_outlined,
    ),
    'langues' => (accent: IvoireColors.orangeDeep, icon: Icons.translate),
    'culture' => (
      accent: IvoireColors.terracotta,
      icon: Icons.palette_outlined,
    ),
    'economie' => (accent: IvoireColors.green, icon: Icons.trending_up),
    'patrimoine' => (
      accent: IvoireColors.terracotta,
      icon: Icons.museum_outlined,
    ),
    _ => (accent: IvoireColors.green, icon: Icons.category_outlined),
  };
}

/// Étiquette de domaine : petites capitales sur fond teinté.
class HomeCategoryChip extends StatelessWidget {
  const HomeCategoryChip({
    required this.label,
    this.slug,
    this.onDark = false,
    super.key,
  });

  final String label;
  final String? slug;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final look = _domainLook(slug ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: onDark
            ? look.accent.withValues(alpha: 0.30)
            : look.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.22)
              : look.accent.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: kFont,
          fontSize: 9.5,
          height: 1.3,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: onDark ? Colors.white : look.accent,
        ),
      ),
    );
  }
}

/// Bandeau d'ouverture : la manchette du portail à gauche, la carte d'identité
/// du pays à droite. Le contenu (la une) commence juste en dessous.
class HomeOpening extends StatelessWidget {
  const HomeOpening({
    required this.articleCount,
    required this.domains,
    required this.sourceCount,
    required this.categories,
    this.stats,
    super.key,
  });

  final int articleCount;
  final int domains;
  final int sourceCount;
  final List<Category> categories;
  final StatisticsSnapshot? stats;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.line),
        boxShadow: [
          BoxShadow(
            color: tone.ink.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KenteBand(height: 9),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 820;

              final intro = _HeroIntro(
                articleCount: articleCount,
                domains: domains,
                sourceCount: sourceCount,
                categories: categories,
                narrow: !wide,
              );
              final facts = _CountryFacts(stats: stats, narrow: !wide);

              if (!wide) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [intro, const SizedBox(height: 18), facts],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(26, 22, 22, 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 22),
                    SizedBox(width: 306, child: facts),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({
    required this.articleCount,
    required this.domains,
    required this.sourceCount,
    required this.categories,
    required this.narrow,
  });

  final int articleCount;
  final int domains;
  final int sourceCount;
  final List<Category> categories;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              kLockupAsset,
              height: narrow ? 44 : 52,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: kTagline,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'PORTAIL NATIONAL',
          style: kickerStyle(color: IvoireColors.orangeDeep),
        ),
        const SizedBox(height: 7),
        Text(
          'La Côte d’Ivoire,\nracontée et sourcée',
          style: titleStyle(
            size: narrow ? 29 : 38,
            weight: FontWeight.w700,
            color: tone.ink,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'L’encyclopédie de la Côte d’Ivoire : territoires, langues, '
            'institutions, personnalités et récits — chaque page s’appuie sur '
            'des sources que vous pouvez ouvrir.',
            style: TextStyle(fontSize: 14, height: 1.65, color: tone.muted),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 26,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            _HeroStat(value: groupedNumber(articleCount), label: 'pages'),
            _HeroStat(value: '$domains', label: 'domaines'),
            _HeroStat(value: groupedNumber(sourceCount), label: 'sources'),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _PortalMenu(categories: categories),
            HoverLink(
              label: 'Rechercher un sujet',
              onTap: () => wikiGo(context, '/recherche'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: titleStyle(
            size: 22,
            weight: FontWeight.w700,
            color: tone.ink,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            letterSpacing: 0.9,
            fontWeight: FontWeight.w600,
            color: tone.faint,
          ),
        ),
      ],
    );
  }
}

/// Carte d'identité du pays : les grands chiffres, sur fond vert profond.
class _CountryFacts extends StatelessWidget {
  const _CountryFacts({required this.stats, required this.narrow});

  final StatisticsSnapshot? stats;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final population = stats == null ? null : _headline(stats!, 'SP.POP.TOTL');
    final census = stats?.census;
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;

    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 18 : 20, 18, narrow ? 18 : 20, 16),
      decoration: BoxDecoration(
        color: IvoireColors.greenDeep,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: IvoireColors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, size: 14, color: IvoireColors.gold),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'LA CÔTE D’IVOIRE EN CLAIR',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: kickerStyle(color: IvoireColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (population?.display != null) ...[
            Text(
              population!.display!,
              style: titleStyle(
                size: narrow ? 26 : 27,
                weight: FontWeight.w700,
                color: Colors.white,
                height: 1.14,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 3),
            if (population.trend?.display != null)
              Text(
                population.trend!.display,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: IvoireColors.gold,
                ),
              ),
            const SizedBox(height: 1),
            Text(
              'Banque mondiale, ${population.year ?? ''}',
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
            const SizedBox(height: 10),
          ] else ...[
            Text(
              'Les repères du pays arrivent avec les statistiques.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (census != null && regions > 0) ...[
            _FactRow(label: 'Régions', value: '$regions'),
            _FactRow(label: 'Districts', value: '$districts'),
            _FactRow(label: 'Recensement', value: 'RGPH ${census.year}'),
          ],
          const SizedBox(height: 12),
          HoverLink(
            label: 'Toutes les statistiques',
            onTap: () => wikiGo(context, '/statistiques'),
            color: Colors.white,
            hoverColor: IvoireColors.gold,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Accès aux domaines : un bouton plein, le plan de l'encyclopédie en menu.
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
                Icon(
                  _domainLook(category.slug).icon,
                  size: 15,
                  color: _domainLook(category.slug).accent,
                ),
                const SizedBox(width: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: IvoireColors.greenDeep,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, size: 15, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Portails',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.expand_more, size: 16, color: Colors.white70),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: tone.subtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 2),
            child: Text(
              'AU SOMMAIRE',
              style: TextStyle(
                fontSize: 9.5,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: IvoireColors.orangeDeep,
              ),
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: _hover ? tone.paper : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _hover ? tone.line : Colors.transparent),
          ),
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
                    fontSize: 9.5,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mosaïque de une : un article principal en grand, puis deux entrées
/// secondaires numérotées.
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

    return HomeSection(
      title: 'La une',
      trailing: Text(
        'Édition du ${formatDate(DateTime.now())}',
        style: TextStyle(fontSize: 11, color: tone.faint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadStory(article: lead),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth >= 720;

                if (!side) {
                  return Column(
                    children: [
                      for (var i = 0; i < secondary.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _SecondaryStory(index: i + 2, article: secondary[i]),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < secondary.length; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      Expanded(
                        child: _SecondaryStory(
                          index: i + 2,
                          article: secondary[i],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadStory extends StatelessWidget {
  const _LeadStory({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final hasImage =
        article.coverImageUrl != null && article.coverImageUrl!.isNotEmpty;
    final meta = [
      article.typeLabel,
      '${article.readingMinutes} min',
      if (article.publishedAt != null) formatDate(article.publishedAt),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          Stack(
            children: [
              ArticleFigure(
                article: article,
                height: 320,
                radius: _cardRadius,
                requestWidth: 780,
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: IvoireColors.greenDeep,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'À LA UNE',
                        style: TextStyle(
                          fontFamily: kFont,
                          fontSize: 9.5,
                          letterSpacing: 0.9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (article.categoryName != null) ...[
                      const SizedBox(width: 6),
                      HomeCategoryChip(
                        label: article.categoryName!,
                        slug: article.categorySlug,
                        onDark: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            if (article.categoryName != null) ...[
              HomeCategoryChip(
                label: article.categoryName!,
                slug: article.categorySlug,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: tone.faint),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        HoverLink(
          label: article.title,
          onTap: () => wikiGo(context, '/articles/${article.slug}'),
          color: tone.ink,
          hoverColor: IvoireColors.greenDeep,
          style: titleStyle(
            size: 31,
            weight: FontWeight.w700,
            color: tone.ink,
            height: 1.16,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Text(
            article.summary,
            style: TextStyle(fontSize: 15, height: 1.65, color: tone.body),
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            _ActionPill(
              label: 'Lire l’article',
              onTap: () => wikiGo(context, '/articles/${article.slug}'),
            ),
            const Spacer(),
            if (article.authorName != null)
              Flexible(
                child: Text(
                  'par ${article.authorName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: tone.faint),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hover ? IvoireColors.greenDeep : IvoireColors.green,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 13, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryStory extends StatefulWidget {
  const _SecondaryStory({required this.index, required this.article});

  final int index;
  final ArticleSummary article;

  @override
  State<_SecondaryStory> createState() => _SecondaryStoryState();
}

class _SecondaryStoryState extends State<_SecondaryStory> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tone.paper,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: _hover ? IvoireColors.green : tone.lineSoft,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                height: 124,
                child: ArticleThumb(
                  article: article,
                  width: 104,
                  height: 124,
                  radius: 0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.index.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: IvoireColors.orangeDeep,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              article.categoryName ?? article.typeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w600,
                                color: tone.faint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle(
                          size: 14,
                          weight: FontWeight.w600,
                          color: _hover ? IvoireColors.greenDeep : tone.ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${article.readingMinutes} min de lecture',
                        style: TextStyle(fontSize: 10.5, color: tone.faint),
                      ),
                    ],
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

/// Bande historique : l'année en très grand sur fond sombre, le récit du jour,
/// puis la frise continue.
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

    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final event = events[dayOfYear % events.length];
    final age = today.year - event.year;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: IvoireColors.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WeaveRule(height: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Aujourd’hui dans l’histoire',
                          style: titleStyle(
                            size: 18,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      HoverLink(
                        label: 'Voir la frise complète',
                        onTap: () => wikiGo(context, '/chronologie'),
                        color: IvoireColors.gold,
                        hoverColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 700;

                      final story = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 132,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.year < 0
                                      ? '${-event.year}'
                                      : '${event.year}',
                                  style: titleStyle(
                                    size: 46,
                                    weight: FontWeight.w700,
                                    color: IvoireColors.gold,
                                    height: 1,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                if (event.year < 0)
                                  const Text(
                                    'av. J.-C.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: IvoireColors.gold,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  age > 0 ? 'il y a $age ans' : 'cette année',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: IvoireColors.orange,
                                  ),
                                ),
                                if (event.era.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      event.era.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HoverLink(
                                  label: event.title,
                                  onTap: () => onOpen(event.slug),
                                  color: Colors.white,
                                  hoverColor: IvoireColors.gold,
                                  style: titleStyle(
                                    size: 19,
                                    weight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  event.teaser,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                HoverLink(
                                  label: 'Lire ce récit',
                                  onTap: () => onOpen(event.slug),
                                  color: IvoireColors.gold,
                                  hoverColor: Colors.white,
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
                        height: 124,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) => _RailEvent(
                            event: events[index],
                            onTap: () => onOpen(events[index].slug),
                          ),
                        ),
                      );

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [story, const SizedBox(height: 18), rail],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: story),
                          const SizedBox(width: 20),
                          Container(
                            width: 1,
                            height: 124,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          const SizedBox(width: 18),
                          SizedBox(width: 290, child: rail),
                        ],
                      );
                    },
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
    final year = widget.event.year;
    final label = year < 0 ? '${-year} av. J.-C.' : '$year';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 190,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hover ? 0.13 : 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hover ? 0.32 : 0.12),
            ),
          ),
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
                  color: IvoireColors.gold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  widget.event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.event.era,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Classement des régions : la première carte passe sur fond vert, les autres
/// restent des fiches claires avec leur rang.
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
              final columns = constraints.maxWidth >= 700
                  ? 4
                  : (constraints.maxWidth >= 440 ? 2 : 1);
              final width =
                  (constraints.maxWidth - (columns - 1) * 10) / columns;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < regions.length; i++)
                    SizedBox(
                      width: width,
                      child: _RegionTile(
                        rank: i + 1,
                        region: regions[i],
                        census: census,
                        share: max == 0 ? 0 : regions[i].population / max,
                        leading: i == 0,
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
    required this.rank,
    required this.region,
    required this.census,
    required this.share,
    required this.leading,
  });

  final int rank;
  final StatisticDivision region;
  final String census;
  final double share;
  final bool leading;

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
    final dark = widget.leading;

    final nameColor = dark
        ? Colors.white
        : (_hover ? IvoireColors.greenDeep : tone.ink);
    final captionColor = dark
        ? Colors.white.withValues(alpha: 0.6)
        : tone.faint;
    final trackColor = dark
        ? Colors.white.withValues(alpha: 0.18)
        : tone.lineSoft;

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: dark
                ? IvoireColors.greenDeep
                : (_hover ? tone.paper : Colors.transparent),
            border: Border.all(
              color: dark
                  ? IvoireColors.greenDeep
                  : (_hover ? IvoireColors.green : tone.lineSoft),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? IvoireColors.gold
                          : IvoireColors.terracotta.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      widget.rank.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: dark
                            ? IvoireColors.ink
                            : IvoireColors.terracotta,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward,
                    size: 12,
                    color: dark
                        ? Colors.white.withValues(alpha: 0.6)
                        : (_hover ? IvoireColors.green : tone.faint),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                region.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                groupedNumber(region.population),
                style: titleStyle(
                  size: 20,
                  weight: FontWeight.w700,
                  color: dark ? Colors.white : tone.ink,
                ),
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: widget.share.clamp(0.04, 1.0),
                  minHeight: 4,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dark ? IvoireColors.gold : IvoireColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.census,
                style: TextStyle(fontSize: 10, color: captionColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fil des publications : une grille de fiches illustrées, puis trois entrées
/// « le saviez-vous » sur une seule ligne.
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
                  (constraints.maxWidth - (columns - 1) * 14) / columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
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
            const SizedBox(height: 16),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tone.highlight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tone.lineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 3, color: IvoireColors.orange),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LE SAVIEZ-VOUS ?',
                          style: TextStyle(
                            fontSize: 9.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: IvoireColors.orangeDeep,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 640;

                            final items = [
                              for (final fact in facts)
                                _FactItem(article: fact),
                            ];

                            if (!wide) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < items.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 8),
                                    items[i],
                                  ],
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < items.length; i++) ...[
                                  if (i > 0) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 1,
                                      height: 54,
                                      color: tone.line,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(child: items[i]),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
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

class _FactItem extends StatelessWidget {
  const _FactItem({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => wikiGo(context, '/articles/${article.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: IvoireColors.link,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            article.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, height: 1.5, color: tone.body),
          ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tone.paper,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: _hover ? IvoireColors.green : tone.lineSoft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArticleThumb(
                article: article,
                width: double.infinity,
                height: 124,
                radius: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.categoryName ?? article.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: _domainLook(article.categorySlug ?? '').accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle(
                        size: 14.5,
                        weight: FontWeight.w600,
                        color: _hover ? IvoireColors.greenDeep : tone.ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: tone.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${article.readingMinutes} min',
                          style: TextStyle(fontSize: 10.5, color: tone.faint),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: _hover ? IvoireColors.green : tone.faint,
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

/// Bande des portails : le plan de l'encyclopédie en cartes, chacune avec son
/// pictogramme, sa couleur et le nombre de pages publiées.
class HomePortalsBand extends StatelessWidget {
  const HomePortalsBand({required this.categories, super.key});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categories.fold<int>(
      0,
      (sum, category) => sum + category.articleCount,
    );

    return HomeSection(
      title: 'Tous les portails',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeIntro(
            'Huit domaines pour entrer dans l’encyclopédie. Chaque portail '
            'rassemble ses pages et leurs sous-catégories.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820
                  ? 4
                  : (constraints.maxWidth >= 520 ? 2 : 1);
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final category in categories)
                    SizedBox(
                      width: width,
                      child: _PortalCard(category: category, total: total),
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
  const _PortalCard({required this.category, required this.total});

  final Category category;
  final int total;

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final category = widget.category;
    final look = _domainLook(category.slug);
    final share = widget.total == 0
        ? 0.0
        : category.articleCount / widget.total;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => wikiGo(context, '/categories/${category.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: tone.paper,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: _hover ? look.accent : tone.lineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: look.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(look.icon, size: 19, color: look.accent),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${category.articleCount}',
                        style: titleStyle(
                          size: 20,
                          weight: FontWeight.w700,
                          color: _hover ? look.accent : tone.ink,
                          height: 1,
                        ),
                      ),
                      Text(
                        category.articleCount > 1 ? 'pages' : 'page',
                        style: TextStyle(fontSize: 9.5, color: tone.faint),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle(
                  size: 15.5,
                  weight: FontWeight.w700,
                  color: tone.ink,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: share.clamp(0.03, 1.0),
                  minHeight: 3,
                  backgroundColor: tone.lineSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(look.accent),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Parcourir ce portail',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _hover ? look.accent : tone.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 11,
                    color: _hover ? look.accent : tone.faint,
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

/// Poste de travail du lecteur : les repères nationaux sur fond sombre, puis
/// les portes d'entrée (hasard, statistiques).
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
    final gdp = stats == null ? null : _headline(stats!, 'NY.GDP.MKTP.CD');
    final life = stats == null ? null : _themed(stats!, 'SP.DYN.LE00.IN');
    final literacy = stats == null ? null : _themed(stats!, 'SE.ADT.LITR.ZS');
    final regions = stats?.regions.length ?? 0;
    final districts = stats?.districts.length ?? 0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: IvoireColors.ink,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 13,
                      color: IvoireColors.gold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'REPÈRES NATIONAUX',
                      style: kickerStyle(color: IvoireColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (gdp?.display != null) ...[
                  Text(
                    gdp!.display!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${gdp.label} · ${gdp.year ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ] else
                  Text(
                    'Les indicateurs du pays sont en cours de chargement.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (life?.display != null)
                  _DeskRow(label: 'Espérance de vie', value: life!.display!),
                if (literacy?.display != null)
                  _DeskRow(label: 'Alphabétisation', value: literacy!.display!),
                if (regions > 0)
                  _DeskRow(label: 'Territoires', value: '$regions régions'),
                if (districts > 0)
                  _DeskRow(label: 'Districts', value: '$districts'),
                if (timelineCount > 0)
                  _DeskRow(
                    label: 'Chronologie',
                    value: '$timelineCount jalons',
                  ),
                _DeskRow(label: 'Pages publiées', value: '$articleCount'),
                const SizedBox(height: 8),
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
                      label: 'Statistiques complètes',
                      onTap: () => wikiGo(context, '/statistiques'),
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

class _DeskRow extends StatelessWidget {
  const _DeskRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: tone.muted),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: titleStyle(
              size: 12.5,
              weight: FontWeight.w700,
              color: tone.ink,
            ),
          ),
        ],
      ),
    );
  }
}

StatisticIndicator? _headline(StatisticsSnapshot stats, String code) {
  for (final indicator in stats.headline) {
    if (indicator.code == code) {
      return indicator;
    }
  }

  return null;
}

StatisticIndicator? _themed(StatisticsSnapshot stats, String code) {
  for (final theme in stats.themes) {
    for (final indicator in theme.indicators) {
      if (indicator.code == code) {
        return indicator;
      }
    }
  }

  return _headline(stats, code);
}

/// Section numérotée : un filet d'accent à gauche, un titre, puis le contenu.
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

    final heading = Row(
      children: [
        Container(
          width: 4,
          height: 19,
          decoration: BoxDecoration(
            color: IvoireColors.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: titleStyle(
              size: 18,
              weight: FontWeight.w700,
              color: tone.ink,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
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
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: trailing,
                ),
            ],
          ),
        const SizedBox(height: 9),
        Row(
          children: [
            SizedBox(width: 58, child: const WeaveRule(height: 3)),
            Expanded(child: Container(height: 1, color: tone.lineSoft)),
          ],
        ),
        const SizedBox(height: 15),
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
