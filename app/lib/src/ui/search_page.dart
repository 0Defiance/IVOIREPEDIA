import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/ivorian_patterns.dart';

/// Recherche publique (`/recherche?q=`), branchée sur `GET /api/v1/search`.
class SearchPage extends StatefulWidget {
  const SearchPage({this.query = '', super.key});

  final String query;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query);
  Future<PagedArticles>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
      _start(widget.query);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start(String query) {
    final term = query.trim();
    _future = term.isEmpty ? null : ApiScope.of(context).search(term);
  }

  void _submit(String value) {
    final term = value.trim();
    if (term.isEmpty) {
      return;
    }

    context.go('/recherche?q=${Uri.encodeQueryComponent(term)}');
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      searchQuery: widget.query,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RECHERCHER DANS L’ENCYCLOPÉDIE', style: kickerStyle()),
            const SizedBox(height: 4),
            Text('Recherche', style: serifStyle(size: 28)),
            const SizedBox(height: 8),
            const WeaveRule(height: 3, opacity: 0.85),
            const SizedBox(height: 3),
            Container(height: 1, color: IvoireColors.lineSoft),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Un nom, un lieu, une langue…',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                onSubmitted: _submit,
              ),
            ),
            const SizedBox(height: 20),
            if (_future == null)
              const Text(
                'Saisissez un terme pour parcourir les articles publiés.',
                style: TextStyle(fontSize: 14, color: IvoireColors.muted),
              )
            else
              FutureBuilder<PagedArticles>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('${snapshot.error}',
                        style: const TextStyle(fontSize: 14));
                  }

                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final page = snapshot.data!;

                  if (page.items.isEmpty) {
                    return Text(
                      'Aucun résultat pour « ${widget.query} ».',
                      style: const TextStyle(fontSize: 14),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résultats 1 à ${page.items.length} sur ${page.total} pour « ${widget.query} »',
                        style: const TextStyle(
                            fontSize: 12.5, color: IvoireColors.muted),
                      ),
                      const SizedBox(height: 14),
                      for (final article in page.items) _Result(article: article),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.article});

  final ArticleSummary article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go('/articles/${article.slug}'),
            child: Text(
              article.title,
              style: serifStyle(
                size: 18,
                weight: FontWeight.w600,
                color: IvoireColors.link,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            [
              if (article.categoryName != null) article.categoryName!,
              article.typeLabel,
              if (article.publishedAt != null) formatDate(article.publishedAt),
              '${article.readingMinutes} min',
            ].join(' · '),
            style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
          ),
          const SizedBox(height: 4),
          Text(
            article.summary,
            style: const TextStyle(fontSize: 13.5, height: 1.55),
          ),
        ],
      ),
    );
  }
}
