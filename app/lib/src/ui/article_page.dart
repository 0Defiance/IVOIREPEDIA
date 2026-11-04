import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../article_export.dart';
import '../models/article.dart';
import '../theme.dart';
import 'format.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/delta_content.dart';
import 'widgets/infobox_table.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';

/// Page de lecture d'un article (`/articles/{slug}`) : onglets, sommaire
/// cliquable, infobox, notes et références, catégories.
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
            return const _ArticleSkeleton();
          }

          return _ArticleBody(article: snapshot.data!);
        },
      ),
    );
  }
}

class _ArticleSkeleton extends StatelessWidget {
  const _ArticleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 240, height: 12),
          SizedBox(height: 14),
          Skeleton(width: 380, height: 32),
          SizedBox(height: 24),
          SkeletonParagraph(lines: 4),
          SizedBox(height: 18),
          SkeletonParagraph(lines: 5),
        ],
      ),
    );
  }
}

class _ArticleBody extends StatefulWidget {
  const _ArticleBody({required this.article});

  final ArticleDetail article;

  @override
  State<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<_ArticleBody> {
  static const List<String> _tabs = [
    'Article',
    'Discussion',
    'Lire',
    'Modifier',
    'Voir l’historique',
  ];

  int _tab = 0;
  bool _exporting = false;
  final Map<String, GlobalKey> _sectionKeys = {};

  ArticleDetail get _article => widget.article;

  @override
  void initState() {
    super.initState();

    for (final title in deltaSections(_article.contentOps)) {
      _sectionKeys[title] = GlobalKey();
    }
  }

  void _scrollTo(String title) {
    final context = _sectionKeys[title]?.currentContext;

    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }

  /// Message de confirmation, sur le messager saisi avant l'attente :
  /// l'utilisateur peut changer de page pendant la copie ou la génération.
  void _notify(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyLink() async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: articleUrl(_article.slug)));
    _notify(messenger, 'Lien de l’article copié.');
  }

  Future<void> _copyArticle() async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: articleAsText(_article)));
    _notify(messenger, 'Article copié : titre, texte et références.');
  }

  Future<void> _copySection(String title) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: sectionAsText(_article, title)),
    );
    _notify(messenger, 'Section « $title » copiée.');
  }

  Future<void> _downloadPdf() async {
    if (_exporting) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    _notify(messenger, 'Préparation du PDF…');

    try {
      final name = await downloadArticlePdf(_article);
      _notify(messenger, '« $name » téléchargé.');
    } catch (_) {
      _notify(
        messenger,
        'Le PDF n’a pas pu être généré. Réessayez dans un instant.',
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = deltaSections(_article.contentOps);
    final infobox = _article.infobox;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WikiTabs(
            items: [
              for (var i = 0; i < _tabs.length; i++)
                (
                  label: _tabs[i],
                  selected: _tab == i,
                  onTap: () => setState(() => _tab = i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            [
              if (_article.categoryName != null) _article.categoryName!.toUpperCase(),
              _article.typeLabel.toUpperCase(),
            ].join('  ·  '),
            style: kickerStyle(),
          ),
          const SizedBox(height: 6),
          Text(
            _article.title,
            style: titleStyle(size: 30, weight: FontWeight.w600, height: 1.2),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: IvoireColors.line),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;

              return Wrap(
                spacing: 14,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!compact)
                    Text(
                      "Un article de IVOIREPEDIA, l'encyclopédie libre.",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: IvoireColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (_article.publishedAt != null)
                    Text(
                      'Dernière modification le ${formatDate(_article.publishedAt)}',
                      style: const TextStyle(fontSize: 12.5, color: IvoireColors.faint),
                    ),
                  Text(
                    '${_article.readingMinutes} min de lecture',
                    style: const TextStyle(fontSize: 12.5, color: IvoireColors.faint),
                  ),
                  _ToolButton(
                    icon: Icons.copy_all_outlined,
                    label: 'Copier l’article',
                    onTap: _copyArticle,
                  ),
                  _ToolButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: _exporting ? 'Préparation…' : 'Télécharger en PDF',
                    onTap: _downloadPdf,
                  ),
                  _ToolButton(
                    icon: Icons.link,
                    label: 'Copier le lien',
                    onTap: _copyLink,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: _tab == 0 || _tab == 2
                  ? _readingView(sections: sections, infobox: infobox)
                  : _UnavailableTab(label: _tabs[_tab]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingView({
    required List<String> sections,
    required Map<String, dynamic>? infobox,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;

        final aside = infobox != null
            ? InfoboxTable(
                infobox: infobox,
                typeLabel: _article.typeLabel,
                title: _article.title,
              )
            : (wide ? _AsideCard(article: _article) : null);

        // Sur petit écran, l'infobox passe après le chapeau : le lecteur
        // rencontre d'abord le texte, comme sur une page d'encyclopédie.
        final Widget? afterLead =
            sections.length > 1 || (!wide && aside != null)
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sections.length > 1)
                          _Sommaire(sections: sections, onTap: _scrollTo),
                        if (!wide && aside != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: aside,
                          ),
                      ],
                    ),
                  )
                : null;

        final content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeltaContent(
                ops: _article.contentOps,
                sectionKeys: _sectionKeys,
                afterLead: afterLead,
                onCopySection: _copySection,
              ),
              if (_article.references.isNotEmpty)
                _References(references: _article.references),
              _CategoryBar(article: _article),
            ],
          ),
        );

        if (!wide) {
          return content;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: content),
            const SizedBox(width: 28),
            SizedBox(width: 300, child: aside),
          ],
        );
      },
    );
  }
}

class _ToolButton extends StatefulWidget {
  const _ToolButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _hovered ? IvoireColors.highlight : IvoireColors.subtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IvoireColors.lineSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: IvoireColors.green),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 12, color: IvoireColors.greenDeep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableTab extends StatelessWidget {
  const _UnavailableTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: IvoireColors.highlight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IvoireColors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('« $label » arrive bientôt', style: titleStyle(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'L’onglet existe déjà pour que vous trouviez vos repères. '
              'Il sera activé quand les comptes et l’historique des versions seront en ligne.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sommaire extends StatelessWidget {
  const _Sommaire({required this.sections, required this.onTap});

  final List<String> sections;
  final void Function(String title) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: IvoireColors.ivory,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sommaire',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: IvoireColors.ink,
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
                    width: 22,
                    child: Text(
                      '${i + 1}.',
                      style: const TextStyle(fontSize: 13, color: IvoireColors.faint),
                    ),
                  ),
                  Expanded(
                    child: HoverLink(
                      label: sections[i],
                      onTap: () => onTap(sections[i]),
                      style: const TextStyle(fontSize: 13),
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
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notes et références',
                  style: titleStyle(size: 21, weight: FontWeight.w600, letterSpacing: -0.3)),
              const SizedBox(height: 7),
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
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Catégories :',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          for (final link in links)
            HoverLink(
              label: link,
              onTap: () => article.categoryName == link && article.categorySlug != null
                  ? wikiGo(context, '/categories/${article.categorySlug}')
                  : wikiNotImplemented(context, 'Étiquette « $link »'),
              style: const TextStyle(fontSize: 12.5),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IvoireColors.subtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: IvoireColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos de cet article',
              style: titleStyle(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notFound ? 'Page inexistante' : 'Service indisponible',
            style: titleStyle(size: 26, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const WeaveRule(height: 3, opacity: 0.7),
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
