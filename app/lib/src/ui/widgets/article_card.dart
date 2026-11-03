import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/article.dart';
import '../../theme.dart';
import '../format.dart';

/// Carte d'article : la catégorie sert de repère, le titre porte la hiérarchie.
class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, this.featured = false, super.key});

  final ArticleSummary article;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go('/articles/${article.slug}'),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: IvoireColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IvoireColors.line),
        ),
        child: Padding(
          padding: EdgeInsets.all(featured ? 24 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (article.categoryName != null)
                    Text(
                      article.categoryName!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: IvoireColors.orange,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    article.typeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: IvoireColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.title,
                style: featured
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.titleLarge?.copyWith(fontSize: 19),
                maxLines: featured ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: IvoireColors.muted,
                ),
                maxLines: featured ? 4 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Text(
                [
                  if (article.publishedAt != null) formatDate(article.publishedAt),
                  formatReadingTime(article.readingMinutes),
                ].join(' · '),
                style: const TextStyle(fontSize: 12, color: IvoireColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
