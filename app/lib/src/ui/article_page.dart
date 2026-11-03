import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../models/article.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/delta_content.dart';
import 'widgets/infobox_table.dart';

/// Page de lecture d'un article (`/articles/{slug}`), présentée comme une
/// page d'encyclopédie : onglets, sommaire, infobox, références, catégories.
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

            return _ErrorState(
              notFound: notFound,
              message: '${snapshot.error}',
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
    final sections = deltaSections(article.contentOps);
    final infobox = article.infobox;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WikiTabs(
            items: [
              (label: 'Article', selected: true, onTap: () {}),
              (
                label: 'Discussion',
                selected: false,
                onTap: () => wikiNotImplemented(context, 'Discussion'),
              ),
              (label: 'Lire', selected: false, onTap: () {}),
              (
                label: 'Modifier',
                selected: false,
                onTap: () => wikiNotImplemented(context, 'Modifier'),
              ),
              (
                label: 'Voir l’historique',
                selected: false,
                onTap: () => wikiNotImplemented(context, 'Voir l’historique'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(article.title, style: serifStyle(size: 30, height: 1.2)),
          const SizedBox(height: 6),
          Container(height: 1, color: IvoireColors.line),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Un article de IVOIREPEDIA, l'encyclopédie libre.",
                style: const TextStyle(
                  fontSize: 12.5,
                  color: IvoireColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (article.publishedAt != null)
                Text(
                  'Dernière modification le ${formatDate(article.publishedAt)}',
                  style: const TextStyle(fontSize: 12.5, color: IvoireColors.faint),
                ),
              Text(
                '${article.readingMinutes} min de lecture',
                style: const TextStyle(fontSize: 12.5, color: IvoireColors.faint),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!wide && infobox != null) ...[
                    InfoboxTable(
                      infobox: infobox,
                      typeLabel: article.typeLabel,
                      title: article.title,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (sections.length > 1) ...[
                    _Sommaire(sections: sections),
                    const SizedBox(height: 20),
                  ],
                  DeltaContent(ops: article.contentOps),
                  if (article.references.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _References(references: article.references),
                  ],
                  _CategoryBar(article: article),
                ],
              );

              if (!wide) {
                return content;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 26),
                  SizedBox(
                    width: 300,
                    child: infobox != null
                        ? InfoboxTable(
                            infobox: infobox,
                            typeLabel: article.typeLabel,
                            title: article.title,
                          )
                        : _AsideCard(article: article),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Sommaire extends StatelessWidget {
  const _Sommaire({required this.sections});

  final List<String> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: IvoireColors.subtle,
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sommaire',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: IvoireColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < sections.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text('${i + 1}.',
                        style: const TextStyle(
                            fontSize: 13, color: IvoireColors.muted)),
                  ),
                  Expanded(
                    child: Text(
                      sections[i],
                      style: const TextStyle(
                          fontSize: 13, color: IvoireColors.link),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notes et références',
                  style: serifStyle(size: 19, weight: FontWeight.w600)),
              const SizedBox(height: 5),
              const Divider(height: 1, color: IvoireColors.lineSoft),
            ],
          ),
        ),
        for (final reference in references)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${reference.position}.',
                      style: const TextStyle(
                          fontSize: 13, color: IvoireColors.muted)),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (reference.authors != null)
                          TextSpan(
                            text: '${reference.authors}, ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        TextSpan(text: reference.title),
                        if (reference.publisher != null)
                          TextSpan(text: ', ${reference.publisher}'),
                        if (reference.year != null) TextSpan(text: ', ${reference.year}'),
                        if (reference.url != null)
                          TextSpan(
                            text: ' — ${reference.url}',
                            style: const TextStyle(color: IvoireColors.green),
                          ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.article});

  final ArticleDetail article;

  @override
  Widget build(BuildContext context) {
    final links = <String>[
      if (article.categoryName != null) article.categoryName!,
      ...article.tags,
    ];

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
      ),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Catégories :',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          for (final link in links)
            InkWell(
              onTap: () => article.categoryName == link && article.categorySlug != null
                  ? wikiGo(context, '/categories/${article.categorySlug}')
                  : wikiNotImplemented(context, 'Étiquette « $link »'),
              child: Text(
                link,
                style: const TextStyle(fontSize: 12.5, color: IvoireColors.link),
              ),
            ),
        ],
      ),
    );
  }
}

class _AsideCard extends StatelessWidget {
  const _AsideCard({required this.article});

  final ArticleDetail article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IvoireColors.subtle,
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos de cet article',
              style: serifStyle(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          _line('Type', article.typeLabel),
          if (article.categoryName != null) _line('Domaine', article.categoryName!),
          if (article.authorName != null) _line('Auteur', article.authorName!),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontSize: 12, color: IvoireColors.muted),
          ),
          TextSpan(text: value, style: const TextStyle(fontSize: 12.5)),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.notFound, required this.message});

  final bool notFound;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notFound ? 'Page inexistante' : 'Service indisponible',
            style: serifStyle(size: 26),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: IvoireColors.line),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('Retour à la page d’accueil'),
          ),
        ],
      ),
    );
  }
}
