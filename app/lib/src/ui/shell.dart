import 'package:flutter/material.dart';

import '../brand.dart';
import '../theme.dart';
import 'wiki_actions.dart';
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

/// Enveloppe du site : fond animé, bande tissée, bandeau de recherche,
/// colonne de navigation, feuille de lecture, pied de page.
class SiteShell extends StatelessWidget {
  const SiteShell({required this.child, this.searchQuery = '', super.key});

  final Widget child;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IvoireColors.sand,
      drawer: const Drawer(
        backgroundColor: IvoireColors.ivory,
        child: SafeArea(child: _Sidebar(width: null)),
      ),
      body: IvorianBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const KenteBand(),
              _Header(searchQuery: searchQuery),
              Expanded(
                child: SingleChildScrollView(
                  child: PageContainer(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 28),
                      child: Container(
                        decoration: BoxDecoration(
                          color: IvoireColors.paper.withValues(alpha: 0.94),
                          border: Border.all(color: IvoireColors.lineSoft),
                          boxShadow: [
                            BoxShadow(
                              color: IvoireColors.ink.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 1000;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (wide) const _Sidebar(width: 208),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _Reveal(child: child),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IvoireColors.ivory.withValues(alpha: 0.96),
        border: const Border(bottom: BorderSide(color: IvoireColors.lineSoft)),
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
                  onTap: () => wikiGo(context, '/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: IvoireLogo(size: showSearch ? 42 : 34, compact: !showSearch),
                  ),
                ),
                const SizedBox(width: 12),
                if (showSearch)
                  Expanded(child: _HeaderSearch(initialQuery: searchQuery))
                else
                  const Spacer(),
                if (showAccount) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => wikiNotImplemented(context, 'Se connecter'),
                    child: const Text('Se connecter'),
                  ),
                  const SizedBox(width: 4),
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
                    icon: const Icon(Icons.search, size: 22, color: IvoireColors.terracotta),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Rechercher dans IVOIREPEDIA',
          prefixIcon: Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
        onSubmitted: (value) {
          final term = value.trim();
          if (term.isNotEmpty) {
            wikiGo(context, '/recherche?q=${Uri.encodeQueryComponent(term)}');
          }
        },
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
    duration: const Duration(milliseconds: 420),
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

/// Colonne de navigation : teinte sable, titres terre cuite, petits losanges.
class _Sidebar extends StatelessWidget {
  const _Sidebar({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
      decoration: width == null
          ? null
          : const BoxDecoration(
              color: Color(0x14A9502C),
              border: Border(right: BorderSide(color: IvoireColors.lineSoft)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MotifDivider(),
          const SizedBox(height: 16),
          _SidebarGroup(
            title: 'La maison',
            items: [
              _SidebarItem('Accueil', onTap: () => wikiGo(context, '/')),
              _SidebarItem('Tous les domaines', onTap: () => wikiGo(context, '/categories/histoire')),
              _SidebarItem('Recherche', onTap: () => wikiGo(context, '/recherche')),
              _SidebarItem('Article au hasard', onTap: () => wikiNotImplemented(context, 'Article au hasard')),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            title: 'Écrire ensemble',
            items: [
              _SidebarItem('Créer un article', onTap: () => wikiNotImplemented(context, 'Créer un article')),
              _SidebarItem('Modifier', onTap: () => wikiNotImplemented(context, 'Modifier')),
              _SidebarItem('Charte et sources', onTap: () => wikiNotImplemented(context, 'Charte et sources')),
            ],
          ),
          const SizedBox(height: 20),
          _SidebarGroup(
            title: 'Sur cette page',
            items: [
              _SidebarItem('Pages liées', onTap: () => wikiNotImplemented(context, 'Pages liées')),
              _SidebarItem('Version imprimable', onTap: () => wikiNotImplemented(context, 'Version imprimable')),
              _SidebarItem('Information sur la page', onTap: () => wikiNotImplemented(context, 'Information sur la page')),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: IvoireColors.highlight,
              border: Border.all(color: IvoireColors.lineSoft),
            ),
            child: const Text(
              'L’encyclopédie ivoirienne libre : chaque article cite ses sources.',
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
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(title.toUpperCase(), style: kickerStyle()),
        ),
        for (final item in items) item,
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: IvoireColors.orange,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: IvoireColors.link),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onglets de page (Article, Discussion, Lire…) en pastilles tissées plutôt
/// qu'en boîtes grises.
class WikiTabs extends StatelessWidget {
  const WikiTabs({required this.items, super.key});

  final List<({String label, bool selected, VoidCallback onTap})> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: item.selected ? IvoireColors.green : IvoireColors.ivory,
                  border: Border.all(
                    color: item.selected ? IvoireColors.green : IvoireColors.lineSoft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                    color: item.selected ? Colors.white : IvoireColors.link,
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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
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
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final label in ['À propos', 'Charte', 'Contact', 'Confidentialité'])
                InkWell(
                  onTap: () => wikiNotImplemented(context, label),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12.5, color: IvoireColors.link),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
