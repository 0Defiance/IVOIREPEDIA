import 'package:flutter/material.dart';

import '../brand.dart';
import '../theme.dart';
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
    return Scaffold(
      backgroundColor: IvoireColors.canvas,
      drawer: const Drawer(
        backgroundColor: IvoireColors.paper,
        child: SafeArea(child: _Sidebar(width: null)),
      ),
      body: IvorianBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const KenteBand(),
              _Header(searchQuery: widget.searchQuery, elevated: _scrolled),
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
                            color: IvoireColors.paper.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: IvoireColors.lineSoft),
                            boxShadow: [
                              BoxShadow(
                                color: IvoireColors.ink.withValues(alpha: 0.07),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 1000;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (wide) const _Sidebar(width: 224),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _Reveal(child: widget.child),
                                        const _Footer(),
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
  const _Header({required this.searchQuery, required this.elevated});

  final String searchQuery;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: IvoireColors.paper.withValues(alpha: 0.97),
        border: const Border(bottom: BorderSide(color: IvoireColors.lineSoft)),
        boxShadow: [
          BoxShadow(
            color: IvoireColors.ink.withValues(alpha: elevated ? 0.07 : 0),
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
            final showAccount = width >= 1000;

            return Row(
              children: [
                if (width < 1000)
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu, size: 22, color: IvoireColors.ink),
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
                  HoverLink(
                    label: 'Se connecter',
                    onTap: () => wikiNotImplemented(context, 'Se connecter'),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
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
                ],
                if (!showSearch)
                  IconButton(
                    tooltip: 'Rechercher',
                    icon: const Icon(Icons.search, size: 22, color: IvoireColors.green),
                    onPressed: () => wikiGo(context, '/recherche'),
                  ),
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
  const _Sidebar({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
      decoration: width == null
          ? null
          : const BoxDecoration(
              color: IvoireColors.subtle,
              border: Border(right: BorderSide(color: IvoireColors.lineSoft)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MotifDivider(),
          const SizedBox(height: 18),
          _SidebarGroup(
            title: 'La maison',
            items: [
              _SidebarItem(
                'Accueil',
                icon: Icons.home_outlined,
                onTap: () => wikiGo(context, '/'),
              ),
              _SidebarItem(
                'Tous les domaines',
                icon: Icons.category_outlined,
                onTap: () => wikiGo(context, '/categories/histoire'),
              ),
              _SidebarItem(
                'Recherche',
                icon: Icons.search,
                onTap: () => wikiGo(context, '/recherche'),
              ),
              _SidebarItem(
                'Article au hasard',
                icon: Icons.shuffle,
                onTap: () => wikiNotImplemented(context, 'Article au hasard'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            title: 'Écrire ensemble',
            items: [
              _SidebarItem(
                'Créer un article',
                icon: Icons.edit_outlined,
                onTap: () => wikiNotImplemented(context, 'Créer un article'),
              ),
              _SidebarItem(
                'Modifier',
                icon: Icons.drive_file_rename_outline,
                onTap: () => wikiNotImplemented(context, 'Modifier'),
              ),
              _SidebarItem(
                'Charte et sources',
                icon: Icons.verified_outlined,
                onTap: () => wikiNotImplemented(context, 'Charte et sources'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            title: 'Sur cette page',
            items: [
              _SidebarItem(
                'Pages liées',
                icon: Icons.link,
                onTap: () => wikiNotImplemented(context, 'Pages liées'),
              ),
              _SidebarItem(
                'Version imprimable',
                icon: Icons.print_outlined,
                onTap: () => wikiNotImplemented(context, 'Version imprimable'),
              ),
              _SidebarItem(
                'Information sur la page',
                icon: Icons.info_outline,
                onTap: () => wikiNotImplemented(context, 'Information sur la page'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IvoireColors.highlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: IvoireColors.lineSoft),
            ),
            child: const Text(
              'Les articles qui s’appuient sur des sources les citent en bas de page.',
              style: TextStyle(fontSize: 11.5, height: 1.5, color: IvoireColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  const _SidebarGroup({required this.title, required this.items});

  final String title;
  final List<_SidebarItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(title.toUpperCase(), style: kickerStyle(color: IvoireColors.faint)),
        ),
        for (final item in items) item,
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem(this.label, {required this.onTap, required this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData icon;

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
            color: _hovered ? IvoireColors.paper : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: _hovered ? IvoireColors.green : IvoireColors.faint,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.8,
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                    color: _hovered ? IvoireColors.greenDeep : IvoireColors.muted,
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

/// Onglets de page en pastilles, avec transition de couleur animée.
class WikiTabs extends StatelessWidget {
  const WikiTabs({required this.items, super.key});

  final List<({String label, bool selected, VoidCallback onTap})> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: item.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: item.selected ? IvoireColors.green : IvoireColors.subtle,
                    border: Border.all(
                      color: item.selected ? IvoireColors.green : IvoireColors.lineSoft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.selected ? FontWeight.w600 : FontWeight.w500,
                      color: item.selected ? Colors.white : IvoireColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 36),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
        color: IvoireColors.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MotifDivider(),
          const SizedBox(height: 12),
          const Text(
            'Le contenu est disponible sous licence CC BY-SA 4.0, sauf mention contraire.',
            style: TextStyle(fontSize: 12.5, color: IvoireColors.muted),
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
