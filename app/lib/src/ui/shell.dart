import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../brand.dart';
import '../theme.dart';

/// Largeur de lecture confortable, centrée, avec marges latérales adaptatives.
class PageContainer extends StatelessWidget {
  const PageContainer({required this.child, this.maxWidth = 1080, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }
}

/// Enveloppe commune : en-tête, contenu, pied de page.
class SiteShell extends StatelessWidget {
  const SiteShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IvoireColors.ivory,
      body: Column(
        children: [
          const _SiteHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  const _SiteFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: IvoireColors.paper,
        border: Border(bottom: BorderSide(color: IvoireColors.line)),
      ),
      child: SafeArea(
        bottom: false,
        child: PageContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;

              return SizedBox(
                height: 76,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: IvoireLogo(size: 34, compact: !wide),
                      ),
                    ),
                    const Spacer(),
                    if (wide) ...[
                      _NavLink(label: 'Accueil', path: '/'),
                      _NavLink(label: 'Catégories', path: '/categories/histoire'),
                      const SizedBox(width: 16),
                      SizedBox(width: 260, child: _HeaderSearch()),
                    ] else
                      IconButton(
                        tooltip: 'Rechercher',
                        icon: const Icon(Icons.search),
                        onPressed: () => context.go('/recherche'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      style: TextButton.styleFrom(
        foregroundColor: IvoireColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      child: Text(label),
    );
  }
}

class _HeaderSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Rechercher un article…',
        prefixIcon: Icon(Icons.search, size: 20),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      onSubmitted: (value) {
        final query = value.trim();
        if (query.isNotEmpty) {
          context.go('/recherche?q=${Uri.encodeQueryComponent(query)}');
        }
      },
    );
  }
}

class _SiteFooter extends StatelessWidget {
  const _SiteFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: IvoireColors.ink,
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: PageContainer(
        child: Wrap(
          runSpacing: 18,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IvoireMark(size: 30),
                const SizedBox(width: 10),
                const Text(
                  'IVOIREPEDIA',
                  style: TextStyle(
                    color: IvoireColors.ivory,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Text(
              "Encyclopédie inclusive ivoirienne — contenu libre, sources citées.",
              style: TextStyle(color: Color(0xFFBDB6A6), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
