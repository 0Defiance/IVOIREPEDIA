import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'shell.dart';
import 'widgets/article_card.dart';
import 'widgets/section_title.dart';

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
    _search(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
      _search(widget.query);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final term = query.trim();

    if (term.isEmpty) {
      _future = null;
      return;
    }

    _future = ApiScope.of(context).search(term);
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
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Recherche'),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Un nom, un lieu, une langue…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: _submit,
                ),
              ),
              const SizedBox(height: 28),
              if (_future == null)
                const Text(
                  'Saisissez un terme pour parcourir les articles publiés.',
                  style: TextStyle(color: IvoireColors.muted),
                )
              else
                FutureBuilder<PagedArticles>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        '${snapshot.error}',
                        style: const TextStyle(color: IvoireColors.muted),
                      );
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
                        'Aucun article ne correspond à « ${widget.query} ».',
                        style: const TextStyle(color: IvoireColors.muted),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${page.total} résultat${page.total > 1 ? 's' : ''} pour « ${widget.query} »',
                          style: const TextStyle(
                            fontSize: 13,
                            color: IvoireColors.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final article in page.items) ...[
                          ArticleCard(article: article),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
