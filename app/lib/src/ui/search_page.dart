import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../models/suggestion.dart';
import '../storage.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/interactive.dart';

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
  Timer? _suggestDebounce;
  Future<PagedArticles>? _future;
  List<SearchSuggestion> _suggestions = const [];
  String _term = '';
  String _suggestTerm = '';

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
    _suggestDebounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Suggestions affichées pendant la frappe : une requête légère, limitée à
  /// six titres, distincte de la recherche complète.
  void _loadSuggestions(String value) {
    final term = value.trim();
    _suggestTerm = term;
    _suggestDebounce?.cancel();

    if (term.length < 2) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = const []);
      }
      return;
    }

    _suggestDebounce = Timer(const Duration(milliseconds: 180), () async {
      try {
        final suggestions = await ApiScope.of(context).suggest(term);
        if (mounted && _suggestTerm == term) {
          setState(() => _suggestions = suggestions);
        }
      } catch (_) {
        // Une suggestion manquée ne doit pas interrompre la saisie.
      }
    });
  }

  void _submit(String value) {
    final term = value.trim();
    if (term.isEmpty) {
      return;
    }

    AppStorage.instance.recordSearch(term);
    _focus.unfocus();
    setState(() => _suggestions = const []);
    context.go('/recherche?q=${Uri.encodeQueryComponent(term)}');
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
        if (term.isEmpty) {
          _suggestions = const [];
        }
      });
    }

    _loadSuggestions(term);

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
            Text('Recherche', style: titleStyle(size: 30, weight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(height: 1, color: IvoireColors.line),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _submit,
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
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: _Suggestions(
                  suggestions: _suggestions,
                  onPick: (suggestion) {
                    AppStorage.instance.recordSearch(_term);
                    context.go('/articles/${suggestion.slug}');
                  },
                ),
              ),
            ],
            const SizedBox(height: 22),
            if (_future == null)
              _EmptyState(
                onPick: (term) {
                  _controller.text = term;
                  _focus.requestFocus();
                  _onChanged(term);
                },
                onSubmit: (term) => _submit(term),
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

/// Panneau de suggestions : titres indexés, ouverts d'un clic.
class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions, required this.onPick});

  final List<SearchSuggestion> suggestions;
  final void Function(SearchSuggestion suggestion) onPick;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      decoration: BoxDecoration(
        color: tone.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.lineSoft),
        boxShadow: [
          BoxShadow(
            color: tone.ink.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text('SUGGESTIONS', style: kickerStyle(color: tone.faint)),
          ),
          for (final suggestion in suggestions)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onPick(suggestion),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: tone.lineSoft)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 14, color: IvoireColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          suggestion.title,
                          style: TextStyle(fontSize: 13.5, color: tone.ink),
                        ),
                      ),
                      if (suggestion.category != null)
                        Text(
                          suggestion.category!,
                          style: TextStyle(fontSize: 11.5, color: tone.faint),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPick, required this.onSubmit});

  final void Function(String term) onPick;
  final void Function(String term) onSubmit;

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
        ValueListenableBuilder<List<String>>(
          valueListenable: AppStorage.instance.searchHistory,
          builder: (context, history, _) {
            if (history.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Recherches récentes',
                        style: titleStyle(size: 14, weight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    HoverLink(
                      label: 'effacer',
                      color: IvoireColors.faint,
                      onTap: () => AppStorage.instance.clearSearchHistory(),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final term in history)
                      GestureDetector(
                        onTap: () => onSubmit(term),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: IvoireColors.subtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: IvoireColors.lineSoft),
                          ),
                          child: Text(term,
                              style: const TextStyle(fontSize: 12.5)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
        Text('Quelques sujets :', style: titleStyle(size: 14, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (final suggestion in _suggestions)
              HoverLink(
                label: suggestion,
                onTap: () => onPick(suggestion),
                style: const TextStyle(fontSize: 14),
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
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: _hovered ? IvoireColors.ivory : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: IvoireColors.lineSoft),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.article.title,
                style: titleStyle(
                  size: 17,
                  weight: FontWeight.w600,
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
                style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
              ),
              const SizedBox(height: 6),
              Text(
                widget.article.summary,
                style: const TextStyle(fontSize: 13.5, height: 1.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
