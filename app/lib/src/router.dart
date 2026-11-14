import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/article_page.dart';
import 'ui/category_page.dart';
import 'ui/history_page.dart';
import 'ui/home_page.dart';
import 'ui/library_page.dart';
import 'ui/place_page.dart';
import 'ui/places_page.dart';
import 'ui/search_page.dart';
import 'ui/shell.dart';
import 'ui/sources_page.dart';
import 'ui/statistics_page.dart';
import 'ui/timeline_page.dart';

/// Transition commune : fondu court + léger glissement, pour que la navigation
/// réponde immédiatement sans effet spectaculaire.
Page<void> _page(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// URLs du site, lisibles et partageables (CONTEXT §14, Sprint 4).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _page(const HomePage()),
      ),
      GoRoute(
        path: '/categories/:slug',
        pageBuilder: (context, state) => _page(
          CategoryPage(slug: state.pathParameters['slug'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/articles/:slug',
        pageBuilder: (context, state) => _page(
          ArticlePage(
            slug: state.pathParameters['slug'] ?? '',
            section: state.uri.fragment.isEmpty ? null : state.uri.fragment,
          ),
        ),
      ),
      GoRoute(
        path: '/recherche',
        pageBuilder: (context, state) => _page(
          SearchPage(query: state.uri.queryParameters['q'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/statistiques',
        pageBuilder: (context, state) => _page(const StatisticsPage()),
      ),
      GoRoute(
        path: '/histoires',
        pageBuilder: (context, state) => _page(
          HistoryPage(story: state.uri.queryParameters['recit']),
        ),
      ),
      GoRoute(
        path: '/chronologie',
        pageBuilder: (context, state) => _page(const TimelinePage()),
      ),
      GoRoute(
        path: '/sources',
        pageBuilder: (context, state) => _page(
          SourcesPage(highlight: state.uri.queryParameters['ref']),
        ),
      ),
      GoRoute(
        path: '/lieux',
        pageBuilder: (context, state) => _page(const PlacesPage()),
      ),
      GoRoute(
        path: '/lieux/:slug',
        pageBuilder: (context, state) => _page(
          PlacePage(slug: state.pathParameters['slug'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/ma-bibliotheque',
        pageBuilder: (context, state) => _page(const LibraryPage()),
      ),
    ],
    errorBuilder: (context, state) => SiteShell(
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Column(
            children: [
              const Icon(Icons.explore_off, size: 36),
              const SizedBox(height: 12),
              Text(
                'Page introuvable : ${state.uri.path}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('Revenir à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
