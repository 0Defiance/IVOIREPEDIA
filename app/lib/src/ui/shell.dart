import 'package:flutter/material.dart';

import '../brand.dart';
import '../storage.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'wiki_actions.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';

/// Largeur de lecture confortable, centrée.
class PageContainer extends StatelessWidget {
  const PageContainer({required this.child, this.maxWidth = 1180, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Enveloppe du site : fond animé, bande tissée, bandeau collant avec barre de
/// progression de lecture, colonne de navigation, feuille de contenu.
///
/// Les couleurs viennent du thème de lecture choisi (papier, sépia, nuit) :
/// l'en-tête, la colonne et la feuille changent ensemble, sans toucher aux
/// accents de la marque.
class SiteShell extends StatefulWidget {
  const SiteShell({required this.child, this.searchQuery = '', super.key});

  final Widget child;
  final String searchQuery;

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final ScrollController _scroll = ScrollController();
  double _progress = 0;
  bool _scrolled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    final max = metrics.maxScrollExtent;
    final progress = max <= 0 ? 0.0 : (metrics.pixels / max).clamp(0.0, 1.0);
    final scrolled = metrics.pixels > 4;

    if ((progress - _progress).abs() > 0.005 ||
        (_scrolled != scrolled && metrics.axis == Axis.vertical)) {
      setState(() {
        _progress = progress;
        _scrolled = scrolled;
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);
    final prefs = DisplayScope.of(context);
    final reading = prefs.readingMode;

    return Scaffold(
      backgroundColor: tone.canvas,
      drawer: reading
          ? null
          : Drawer(
              backgroundColor: tone.paper,
              child: SafeArea(child: _Sidebar(width: null, tone: tone)),
            ),
      body: IvorianBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const KenteBand(),
              if (reading)
                _ReadingModeBar(tone: tone)
              else
                _Header(
                  searchQuery: widget.searchQuery,
                  elevated: _scrolled,
                  tone: tone,
                ),
              _ProgressBar(value: _progress),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: PageContainer(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 14, 10, 28),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: tone.paper.withValues(alpha: 0.97),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tone.lineSoft),
                            boxShadow: [
                              BoxShadow(
                                color: tone.ink.withValues(alpha: 0.07),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final wide =
                                  constraints.maxWidth >= 1000 && !reading;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (wide) _Sidebar(width: 224, tone: tone),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _Reveal(
                                          child: DefaultTextStyle.merge(
                                            style: TextStyle(color: tone.ink),
                                            child: widget.child,
                                          ),
                                        ),
                                        if (!reading) _Footer(tone: tone),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
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

/// Barre minimale du mode lecture seule : quitter, régler, rien d'autre.
class _ReadingModeBar extends StatelessWidget {
  const _ReadingModeBar({required this.tone});

  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tone.paper,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text(
            'MODE LECTURE',
            style: kickerStyle(color: tone.faint),
          ),
          const Spacer(),
          const DisplaySettingsButton(compact: true),
          IconButton(
            tooltip: 'Quitter le mode lecture',
            icon: Icon(Icons.close, size: 20, color: tone.muted),
            onPressed: () => AppStorage.instance
                .saveDisplay(DisplayScope.read(context).copyWith(readingMode: false)),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.5,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 120),
          widthFactor: value.clamp(0.0, 1.0),
          heightFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: IvoireColors.weave),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchQuery,
    required this.elevated,
    required this.tone,
  });

  final String searchQuery;
  final bool elevated;
  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: tone.paper.withValues(alpha: 0.98),
        border: Border(bottom: BorderSide(color: tone.lineSoft)),
        boxShadow: [
          BoxShadow(
            color: tone.ink.withValues(alpha: elevated ? 0.07 : 0),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final showSearch = width >= 720;
            final showAccount = width >= 1120;

            return Row(
              children: [
                if (width < 1000)
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: Icon(Icons.menu, size: 22, color: tone.ink),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => wikiGo(context, '/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: IvoireLogo(size: showSearch ? 40 : 32, compact: !showSearch),
                  ),
                ),
                const SizedBox(width: 12),
                if (showSearch)
                  Expanded(child: _HeaderSearch(initialQuery: searchQuery))
                else
                  const Spacer(),
                if (showAccount) ...[
                  const SizedBox(width: 10),
                  DisplaySettingsButton(),
                  IconButton(
                    tooltip: 'Ma bibliothèque',
                    onPressed: () => wikiGo(context, '/ma-bibliotheque'),
                    icon: Icon(Icons.bookmarks_outlined, size: 21, color: tone.muted),
                  ),
                  const SizedBox(width: 4),
                  HoverLink(
                    label: 'Se connecter',
                    onTap: () => wikiNotImplemented(context, 'Se connecter'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: IvoireColors.link,
                    ),
                  ),
                  const SizedBox(width: 14),
                  FilledButton(
                    onPressed: () => wikiNotImplemented(context, 'Créer un compte'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Créer un compte'),
                  ),
                ] else ...[
                  DisplaySettingsButton(compact: true),
                  if (!showSearch)
                    IconButton(
                      tooltip: 'Rechercher',
                      icon: const Icon(Icons.search, size: 22, color: IvoireColors.green),
                      onPressed: () => wikiGo(context, '/recherche'),
                    ),
                  IconButton(
                    tooltip: 'Ma bibliothèque',
                    onPressed: () => wikiGo(context, '/ma-bibliotheque'),
                    icon: Icon(Icons.bookmarks_outlined, size: 21, color: tone.muted),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSearch extends StatefulWidget {
  const _HeaderSearch({required this.initialQuery});

  final String initialQuery;

  @override
  State<_HeaderSearch> createState() => _HeaderSearchState();
}

class _HeaderSearchState extends State<_HeaderSearch> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final term = value.trim();
    if (term.isEmpty) {
      return;
    }

    _focus.unfocus();
    AppStorage.instance.recordSearch(term);
    wikiGo(context, '/recherche?q=${Uri.encodeQueryComponent(term)}');
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: IvoireColors.green.withValues(alpha: _focused ? 0.14 : 0),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Rechercher un article, un lieu, une langue…',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: _submit,
        ),
      ),
    );
  }
}

/// Apparition douce du contenu (une seule fois par page).
class _Reveal extends StatefulWidget {
  const _Reveal({required this.child});

  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.012),
    end: Offset.zero,
  ).animate(_opacity);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;

    if (ivoireMotionAllowed(context)) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// Colonne de navigation : fond sable, titres capitales, survol réactif.
class _Sidebar extends StatelessWidget {
  const _Sidebar({this.width, required this.tone});

  final double? width;
  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
      decoration: width == null
          ? null
          : BoxDecoration(
              color: tone.subtle,
              border: Border(right: BorderSide(color: tone.lineSoft)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MotifDivider(),
          const SizedBox(height: 18),
          _SidebarGroup(
            tone: tone,
            title: 'La maison',
            items: [
              _SidebarItem(
                'Accueil',
                icon: Icons.home_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/'),
              ),
              _SidebarItem(
                'Tous les domaines',
                icon: Icons.category_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/categories/histoire'),
              ),
              _SidebarItem(
                'Recherche',
                icon: Icons.search,
                tone: tone,
                onTap: () => wikiGo(context, '/recherche'),
              ),
              _SidebarItem(
                'Villes et régions',
                icon: Icons.place_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/lieux'),
              ),
              _SidebarItem(
                'Statistiques',
                icon: Icons.insights_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/statistiques'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            tone: tone,
            title: 'Histoire',
            items: [
              _SidebarItem(
                'Histoire incroyable',
                icon: Icons.menu_book_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/histoires'),
              ),
              _SidebarItem(
                'La frise du temps',
                icon: Icons.timeline,
                tone: tone,
                onTap: () => wikiGo(context, '/chronologie'),
              ),
              _SidebarItem(
                'Article au hasard',
                icon: Icons.shuffle,
                tone: tone,
                onTap: () => wikiNotImplemented(context, 'Article au hasard'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            tone: tone,
            title: 'Mon espace',
            items: [
              _SidebarItem(
                'Ma bibliothèque',
                icon: Icons.bookmarks_outlined,
                tone: tone,
                onTap: () => wikiGo(context, '/ma-bibliotheque'),
              ),
              _SidebarItem(
                'Confort de lecture',
                icon: Icons.text_fields,
                tone: tone,
                onTap: () => openDisplaySettings(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            tone: tone,
            title: 'Écrire ensemble',
            items: [
              _SidebarItem(
                'Créer un article',
                icon: Icons.edit_outlined,
                tone: tone,
                onTap: () => wikiNotImplemented(context, 'Créer un article'),
              ),
              _SidebarItem(
                'Charte et sources',
                icon: Icons.verified_outlined,
                tone: tone,
                onTap: () => wikiNotImplemented(context, 'Charte et sources'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tone.highlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tone.lineSoft),
            ),
            child: Text(
              'Les articles qui s’appuient sur des sources les citent en bas de page.',
              style: TextStyle(fontSize: 11.5, height: 1.5, color: tone.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  const _SidebarGroup({required this.title, required this.items, required this.tone});

  final String title;
  final List<_SidebarItem> items;
  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(title.toUpperCase(), style: kickerStyle(color: tone.faint)),
        ),
        for (final item in items) item,
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem(
    this.label, {
    required this.onTap,
    required this.icon,
    required this.tone,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final ToneColors tone;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? widget.tone.paper : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: _hovered ? IvoireColors.green : widget.tone.faint,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.8,
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                    color: _hovered ? IvoireColors.greenDeep : widget.tone.muted,
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

/// Onglets de page plats, sur une seule ligne : le titre sélectionné est
/// souligné d'un trait vert. Sur petit écran, la barre défile au doigt.
class WikiTabs extends StatelessWidget {
  const WikiTabs({required this.items, super.key});

  final List<({String label, bool selected, VoidCallback onTap})> items;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tone.lineSoft)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in items)
              _WikiTab(
                label: item.label,
                selected: item.selected,
                onTap: item.onTap,
                tone: tone,
              ),
          ],
        ),
      ),
    );
  }
}

class _WikiTab extends StatefulWidget {
  const _WikiTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tone,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ToneColors tone;

  @override
  State<_WikiTab> createState() => _WikiTabState();
}

class _WikiTabState extends State<_WikiTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? widget.tone.ink
        : (_hovered ? widget.tone.ink : widget.tone.muted);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 9),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selected ? IvoireColors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.tone});

  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 36),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tone.lineSoft)),
        color: tone.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MotifDivider(),
          const SizedBox(height: 12),
          Text(
            'Le contenu est disponible sous licence CC BY-SA 4.0, sauf mention contraire.',
            style: TextStyle(fontSize: 12.5, color: tone.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              for (final label in ['À propos', 'Charte', 'Contact', 'Confidentialité'])
                HoverLink(
                  label: label,
                  onTap: () => wikiNotImplemented(context, label),
                  style: const TextStyle(fontSize: 12.5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
