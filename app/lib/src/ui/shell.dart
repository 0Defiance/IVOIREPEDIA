import 'package:flutter/material.dart';

import '../brand.dart';
import '../theme.dart';
import 'wiki_actions.dart';

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

/// Enveloppe du site : bandeau, colonne de navigation, contenu, pied de page.
class SiteShell extends StatelessWidget {
  const SiteShell({required this.child, this.searchQuery = '', super.key});

  final Widget child;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IvoireColors.paper,
      drawer: const Drawer(child: _Sidebar()),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(searchQuery: searchQuery),
            Expanded(
              child: SingleChildScrollView(
                child: PageContainer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1000;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (wide) const _Sidebar(),
                          Expanded(
                            child: Column(
                              children: [
                                child,
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
          ],
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
      decoration: const BoxDecoration(
        color: IvoireColors.paper,
        border: Border(bottom: BorderSide(color: IvoireColors.lineSoft)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: PageContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final showSearch = width >= 720;
            final showAccount = width >= 1040;

            return Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu, size: 22),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                InkWell(
                  onTap: () => wikiGo(context, '/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: IvoireLogo(size: showSearch ? 42 : 34, compact: !showSearch),
                  ),
                ),
                const SizedBox(width: 12),
                if (showSearch)
                  Expanded(child: _HeaderSearch(initialQuery: searchQuery))
                else
                  const Spacer(),
                if (showAccount) ...[
                  const SizedBox(width: 6),
                  _HeaderLink(
                    label: 'Créer un compte',
                    onTap: () => wikiNotImplemented(context, 'Créer un compte'),
                  ),
                  _HeaderLink(
                    label: 'Se connecter',
                    onTap: () => wikiNotImplemented(context, 'Se connecter'),
                  ),
                ],
                if (!showSearch)
                  IconButton(
                    tooltip: 'Rechercher',
                    icon: const Icon(Icons.search, size: 22),
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
          prefixIcon: Icon(Icons.search, size: 20, color: IvoireColors.faint),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: IvoireColors.link,
        textStyle: const TextStyle(fontSize: 13.5),
      ),
      child: Text(label),
    );
  }
}

/// Colonne de navigation, comme le menu latéral d'une encyclopédie en ligne.
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarGroup(
            title: 'Navigation',
            items: [
              _SidebarItem('Accueil', onTap: () => wikiGo(context, '/')),
              _SidebarItem('Catégories', onTap: () => wikiGo(context, '/categories/histoire')),
              _SidebarItem('Recherche', onTap: () => wikiGo(context, '/recherche')),
              _SidebarItem('Article au hasard', onTap: () => wikiNotImplemented(context, 'Article au hasard')),
            ],
          ),
          const SizedBox(height: 18),
          _SidebarGroup(
            title: 'Contribuer',
            items: [
              _SidebarItem('Créer un article', onTap: () => wikiNotImplemented(context, 'Créer un article')),
              _SidebarItem('Modifier', onTap: () => wikiNotImplemented(context, 'Modifier')),
              _SidebarItem('Aide', onTap: () => wikiNotImplemented(context, 'Aide')),
            ],
          ),
          const SizedBox(height: 18),
          _SidebarGroup(
            title: 'Outils',
            items: [
              _SidebarItem('Pages liées', onTap: () => wikiNotImplemented(context, 'Pages liées')),
              _SidebarItem('Version imprimable', onTap: () => wikiNotImplemented(context, 'Version imprimable')),
              _SidebarItem('Information sur la page', onTap: () => wikiNotImplemented(context, 'Information sur la page')),
            ],
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
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: IvoireColors.muted,
            ),
          ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: IvoireColors.link),
        ),
      ),
    );
  }
}

/// Onglets d'article : « Article · Discussion · Lire · Modifier · Historique ».
class WikiTabs extends StatelessWidget {
  const WikiTabs({required this.items, super.key});

  final List<({String label, bool selected, VoidCallback onTap})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: IvoireColors.line)),
      ),
      child: Row(
        children: [
          for (final item in items)
            InkWell(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: item.selected
                      ? IvoireColors.paper
                      : IvoireColors.subtle,
                  border: Border(
                    top: BorderSide(
                      color: item.selected ? IvoireColors.orange : Colors.transparent,
                      width: 3,
                    ),
                    left: const BorderSide(color: IvoireColors.lineSoft),
                    right: const BorderSide(color: IvoireColors.lineSoft),
                  ),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: item.selected
                        ? IvoireColors.ink
                        : IvoireColors.link,
                    fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          const Spacer(),
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
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Le contenu est disponible sous licence CC BY-SA 4.0, sauf mention contraire.',
            style: TextStyle(fontSize: 12.5, color: IvoireColors.muted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            children: [
              for (final label in ['À propos', 'Aide', 'Contact', 'Confidentialité'])
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
