import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/article_page.dart';
import 'ui/category_page.dart';
import 'ui/home_page.dart';
import 'ui/search_page.dart';
import 'ui/shell.dart';

/// URLs du site, lisibles et partageables (CONTEXT §14, Sprint 4).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/categories/:slug',
        builder: (context, state) =>
            CategoryPage(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/articles/:slug',
        builder: (context, state) =>
            ArticlePage(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/recherche',
        builder: (context, state) =>
            SearchPage(query: state.uri.queryParameters['q'] ?? ''),
      ),
    ],
    errorBuilder: (context, state) => SiteShell(
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
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
