import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';

/// Recherche publique (`/recherche?q=`) : les résultats se rafraîchissent
/// pendant la frappe, sans bouton à presser.
class SearchPage extends StatefulWidget {
  const SearchPage({this.query = '', super.key});

  final String query;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query);
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  Future<PagedArticles>? _future;
  String _term = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search(widget.query, immediate: true);
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
      _search(widget.query, immediate: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _search(String value, {bool immediate = false}) {
    final term = value.trim();
    _debounce?.cancel();

    void run() {
      if (!mounted) {
        return;
      }

      setState(() {
        _term = term;
        _future = term.isEmpty ? null : ApiScope.of(context).search(term);
      });
    }

    if (immediate) {
      run();
    } else {
      _debounce = Timer(const Duration(milliseconds: 280), run);
    }
  }

  // La frappe relance seulement la recherche : l'URL est mise à jour à la
  // validation, pour ne pas empiler deux requêtes par caractère.
  void _onChanged(String value) => _search(value);

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      searchQuery: widget.query,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RECHERCHER DANS L’ENCYCLOPÉDIE', style: kickerStyle()),
            const SizedBox(height: 6),
            Text('Recherche', style: titleStyle(size: 30, weight: FontWeight.w700)),
            const SizedBox(height: 10),
            const WeaveRule(height: 3, opacity: 0.9),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: (value) =>
                    context.go('/recherche?q=${Uri.encodeQueryComponent(value.trim())}'),
                decoration: InputDecoration(
                  hintText: 'Un nom, un lieu, une langue…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                            _focus.requestFocus();
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_future == null)
              _EmptyState(
                onPick: (term) {
                  _controller.text = term;
                  _focus.requestFocus();
                  _onChanged(term);
                },
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: FutureBuilder<PagedArticles>(
                  key: ValueKey(_term),
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('${snapshot.error}',
                          style: const TextStyle(fontSize: 14));
                    }

                    if (!snapshot.hasData) {
                      return const Column(
                        key: ValueKey('loading'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(width: 260, height: 12),
                          SizedBox(height: 18),
                          SkeletonParagraph(lines: 2),
                          SizedBox(height: 12),
                          SkeletonParagraph(lines: 2),
                        ],
                      );
                    }

                    final page = snapshot.data!;

                    if (page.items.isEmpty) {
                      return Text(
                        'Aucun résultat pour « $_term ». Essayez un autre mot, '
                        'ou parcourez les domaines depuis l’accueil.',
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      );
                    }

                    return Column(
                      key: ValueKey('results-$_term'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résultats 1 à ${page.items.length} sur ${page.total} pour « $_term »',
                          style: const TextStyle(
                              fontSize: 12.5, color: IvoireColors.muted),
                        ),
                        const SizedBox(height: 16),
                        for (final article in page.items) _Result(article: article),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPick});

  final void Function(String term) onPick;

  static const List<String> _suggestions = [
    'Abidjan',
    'cacao',
    'Baoulé',
    'Yamoussoukro',
    'attiéké',
    'indépendance',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saisissez un terme : les résultats apparaissent au fil de la frappe.',
          style: TextStyle(fontSize: 14, color: IvoireColors.muted),
        ),
        const SizedBox(height: 18),
        Text('SUGGESTIONS', style: kickerStyle(color: IvoireColors.faint)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in _suggestions)
              OutlinedButton(
                onPressed: () => onPick(suggestion),
                child: Text(suggestion, style: const TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Result extends StatefulWidget {
  const _Result({required this.article});

  final ArticleSummary article;

  @override
  State<_Result> createState() => _ResultState();
}

class _ResultState extends State<_Result> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/articles/${widget.article.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? IvoireColors.highlight : IvoireColors.paper,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? IvoireColors.orange.withValues(alpha: 0.5) : IvoireColors.lineSoft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.article.title,
                style: titleStyle(
                  size: 17,
                  weight: FontWeight.w700,
                  color: _hovered ? IvoireColors.greenDeep : IvoireColors.link,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                [
                  if (widget.article.categoryName != null) widget.article.categoryName!,
                  widget.article.typeLabel,
                  if (widget.article.publishedAt != null)
                    formatDate(widget.article.publishedAt),
                  '${widget.article.readingMinutes} min',
                ].join(' · '),
                style: const TextStyle(fontSize: 11.5, color: IvoireColors.faint),
              ),
              const SizedBox(height: 6),
              Text(
                widget.article.summary,
                style: const TextStyle(fontSize: 13.5, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
