import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'widgets/delta_content.dart';
import 'widgets/infobox_table.dart';
import 'widgets/section_title.dart';

/// Page de lecture d'un article publié (`/articles/{slug}`).
class ArticlePage extends StatefulWidget {
  const ArticlePage({required this.slug, super.key});

  final String slug;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Future<ArticleDetail>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchArticle(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final notFound = snapshot.error is ApiException &&
                (snapshot.error as ApiException).statusCode == 404;

            return PageContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      notFound ? Icons.search_off : Icons.cloud_off,
                      size: 36,
                      color: IvoireColors.muted,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Retour à l’accueil'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _ArticleBody(article: snapshot.data!);
        },
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.article});

  final ArticleDetail article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infobox = article.infobox;

    return PageContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Breadcrumb(article: article),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.categoryName != null)
                        Text(
                          article.categoryName!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: IvoireColors.orange,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        article.typeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: IvoireColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(article.title, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 14),
                  Text(
                    [
                      if (article.authorName != null) article.authorName!,
                      if (article.publishedAt != null)
                        formatDate(article.publishedAt),
                      formatReadingTime(article.readingMinutes),
                    ].join(' · '),
                    style: const TextStyle(fontSize: 13, color: IvoireColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 860;

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!wide && infobox != null) ...[
                      InfoboxTable(
                        infobox: infobox,
                        typeLabel: article.typeLabel,
                      ),
                      const SizedBox(height: 24),
                    ],
                    DeltaContent(ops: article.contentOps),
                    if (article.tags.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      SectionTitle('Étiquettes'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in article.tags)
                            Chip(label: Text(tag)),
                        ],
                      ),
                    ],
                    if (article.references.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      SectionTitle('Références'),
                      const SizedBox(height: 12),
                      _References(references: article.references),
                    ],
                  ],
                );

                if (!wide) {
                  return content;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: content),
                    const SizedBox(width: 32),
                    if (infobox != null)
                      SizedBox(
                        width: 280,
                        child: InfoboxTable(
                          infobox: infobox,
                          typeLabel: article.typeLabel,
                        ),
                      ),
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.article});

  final ArticleDetail article;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        _Crumb(label: 'Accueil', onTap: () => context.go('/')),
        const Text('/', style: TextStyle(color: IvoireColors.muted)),
        if (article.categorySlug != null) ...[
          _Crumb(
            label: article.categoryName ?? '',
            onTap: () => context.go('/categories/${article.categorySlug}'),
          ),
          const Text('/', style: TextStyle(color: IvoireColors.muted)),
        ],
        Text(
          article.title,
          style: const TextStyle(fontSize: 13, color: IvoireColors.muted),
        ),
      ],
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: IvoireColors.orange),
      ),
    );
  }
}

class _References extends StatelessWidget {
  const _References({required this.references});

  final List<ArticleReference> references;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final reference in references)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    '${reference.position}.',
                    style: const TextStyle(color: IvoireColors.orange),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reference.authors != null)
                        Text(
                          reference.authors!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        [
                          reference.title,
                          if (reference.publisher != null) reference.publisher!,
                          if (reference.year != null) '${reference.year}',
                        ].join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: IvoireColors.muted,
                        ),
                      ),
                      if (reference.url != null)
                        Text(
                          reference.url!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: IvoireColors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
