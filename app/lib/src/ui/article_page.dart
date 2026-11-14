import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../api.dart';
import '../article_export.dart';
import '../models/article.dart';
import '../storage.dart';
import '../theme.dart';
import 'display_settings.dart';
import 'format.dart';
import 'shell.dart';
import 'wiki_actions.dart';
import 'widgets/delta_content.dart';
import 'widgets/infobox_table.dart';
import 'widgets/interactive.dart';
import 'widgets/ivorian_patterns.dart';
import 'widgets/share_bar.dart';

/// Page de lecture d'un article (`/articles/{slug}`) : sommaire suivi,
/// infobox, notes et références, partage et favoris.
///
/// `section` reçoit le fragment d'URL (`/articles/abidjan#histoire`) : la page
/// s'ouvre alors directement sur la section demandée.
class ArticlePage extends StatefulWidget {
  const ArticlePage({required this.slug, this.section, super.key});

  final String slug;
  final String? section;

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

          return _ArticleBody(
            article: snapshot.data!,
            initialSection: widget.section,
          );
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
  const _ArticleBody({required this.article, this.initialSection});

  final ArticleDetail article;
  final String? initialSection;

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
  bool _favorite = false;
  String? _activeSection;
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<int, GlobalKey> _referenceKeys = {};
  final GlobalKey _textTop = GlobalKey();
  ScrollPosition? _position;

  ArticleDetail get _article => widget.article;

  @override
  void initState() {
    super.initState();

    for (final title in deltaSections(_article.contentOps)) {
      _sectionKeys[title] = GlobalKey();
    }

    for (final reference in _article.references) {
      _referenceKeys[reference.position] = GlobalKey();
    }

    _favorite = AppStorage.instance.isFavorite(_article.slug);

    AppStorage.instance.recordRead(
      LibraryEntry(
        slug: _article.slug,
        title: _article.title,
        category: _article.categoryName,
        at: DateTime.now(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _attachScroll();
      _scrollToInitialSection();
    });
  }

  @override
  void dispose() {
    _position?.removeListener(_updateActiveSection);
    super.dispose();
  }

  void _attachScroll() {
    final position = Scrollable.maybeOf(context)?.position;

    if (position == null || identical(position, _position)) {
      return;
    }

    _position?.removeListener(_updateActiveSection);
    _position = position;
    position.addListener(_updateActiveSection);
    _updateActiveSection();
  }

  /// Suivi de lecture : la section dont le titre est passé au-dessus de la
  /// ligne de lecture est celle qui s'allume dans le sommaire.
  void _updateActiveSection() {
    if (!mounted || _sectionKeys.isEmpty) {
      return;
    }

    const threshold = 150.0;
    String? active;

    for (final entry in _sectionKeys.entries) {
      final context = entry.value.currentContext;
      if (context == null) {
        continue;
      }

      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) {
        continue;
      }

      if (box.localToGlobal(Offset.zero).dy <= threshold) {
        active = entry.key;
      }
    }

    if (active != _activeSection) {
      setState(() => _activeSection = active);
    }
  }

  void _scrollToInitialSection() {
    final section = widget.initialSection;
    if (section == null || section.isEmpty) {
      return;
    }

    for (final title in _sectionKeys.keys) {
      if (sectionAnchor(title) == section) {
        _scrollToSection(title);
        return;
      }
    }
  }

  void _scrollToSection(String title) {
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

  /// Un appel `[n]` ouvre la fiche correspondante dans la bibliothèque des
  /// sources ; si le routeur n'est pas disponible (page isolée en test), on
  /// retombe sur le défilement vers la liste locale des références.
  void _openReference(int number) {
    ArticleReference? reference;

    for (final item in _article.references) {
      if (item.position == number) {
        reference = item;

        break;
      }
    }

    final router = GoRouter.maybeOf(context);

    if (reference?.sourceId != null && router != null) {
      router.go('/sources?ref=${reference!.sourceId}');

      return;
    }

    _scrollToReference(number);
  }

  void _scrollToReference(int number) {
    final context = _referenceKeys[number]?.currentContext;

    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.2,
    );
  }

  void _scrollToText() {
    final context = _textTop.currentContext;

    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 420));
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

  Future<void> _copySectionLink(String title) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: shareUrl(articleUrl(_article.slug), section: title)),
    );
    _notify(messenger, 'Lien de la section copié.');
  }

  Future<void> _toggleFavorite() async {
    final messenger = ScaffoldMessenger.of(context);

    final added = await AppStorage.instance.toggleFavorite(
      LibraryEntry(
        slug: _article.slug,
        title: _article.title,
        category: _article.categoryName,
        at: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _favorite = added);
    _notify(
      messenger,
      added ? 'Article ajouté à votre bibliothèque.' : 'Article retiré de votre bibliothèque.',
    );
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
    final tone = ToneColors.from(context);
    final messenger = ScaffoldMessenger.of(context);

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
            style: titleStyle(size: 30, weight: FontWeight.w600, height: 1.2, color: tone.ink),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: tone.line),
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
                      style: TextStyle(
                        fontSize: 12.5,
                        color: tone.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (_article.publishedAt != null)
                    Text(
                      'Dernière modification le ${formatDate(_article.publishedAt)}',
                      style: TextStyle(fontSize: 12.5, color: tone.faint),
                    ),
                  Text(
                    '${_article.readingMinutes} min de lecture',
                    style: TextStyle(fontSize: 12.5, color: tone.faint),
                  ),
                  _ToolButton(
                    icon: _favorite ? Icons.bookmark : Icons.bookmark_border,
                    label: _favorite ? 'Gardé' : 'Garder',
                    onTap: _toggleFavorite,
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
          const SizedBox(height: 14),
          ShareBar(
            url: articleUrl(_article.slug),
            title: _article.title,
            onCopied: (message) => _notify(messenger, message),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: _tab == 0 || _tab == 2
                  ? _readingView(
                      sections: sections,
                      infobox: infobox,
                      tone: tone,
                    )
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
    required ToneColors tone,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        final veryWide = constraints.maxWidth >= 1180;

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
                        if (sections.length > 1 && !veryWide)
                          _Sommaire(sections: sections, onTap: _scrollToSection),
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
          key: _textTop,
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeltaContent(
                ops: _article.contentOps,
                sectionKeys: _sectionKeys,
                afterLead: afterLead,
                onCopySection: _copySection,
                onCopySectionLink: _copySectionLink,
                onFootnote: _openReference,
              ),
              if (_article.references.isNotEmpty)
                _References(
                  references: _article.references,
                  keys: _referenceKeys,
                  onBack: _scrollToText,
                  onOpenSource: _openReference,
                ),
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
            if (veryWide)
              SizedBox(
                width: 210,
                child: _StickyToc(
                  sections: sections,
                  active: _activeSection,
                  onTap: _scrollToSection,
                ),
              ),
            Expanded(child: content),
            const SizedBox(width: 28),
            SizedBox(width: 300, child: aside),
          ],
        );
      },
    );
  }
}

/// Sommaire de gauche, collant, qui suit la lecture.
class _StickyToc extends StatelessWidget {
  const _StickyToc({
    required this.sections,
    required this.active,
    required this.onTap,
  });

  final List<String> sections;
  final String? active;
  final void Function(String title) onTap;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.only(right: 18, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SOMMAIRE', style: kickerStyle(color: tone.faint)),
          const SizedBox(height: 10),
          for (var i = 0; i < sections.length; i++)
            _TocRow(
              index: i + 1,
              title: sections[i],
              active: sections[i] == active,
              onTap: () => onTap(sections[i]),
              tone: tone,
            ),
        ],
      ),
    );
  }
}

class _TocRow extends StatefulWidget {
  const _TocRow({
    required this.index,
    required this.title,
    required this.active,
    required this.onTap,
    required this.tone,
  });

  final int index;
  final String title;
  final bool active;
  final VoidCallback onTap;
  final ToneColors tone;

  @override
  State<_TocRow> createState() => _TocRowState();
}

class _TocRowState extends State<_TocRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active
        ? IvoireColors.greenDeep
        : (_hovered ? IvoireColors.green : widget.tone.muted);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: widget.active ? widget.tone.subtle : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.active ? IvoireColors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            '${widget.index}. ${widget.title}',
            style: TextStyle(
              fontSize: 12.2,
              height: 1.4,
              color: color,
              fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
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
    final tone = ToneColors.from(context);

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
            color: _hovered ? tone.highlight : tone.subtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tone.lineSoft),
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
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: tone.highlight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tone.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('« $label » arrive bientôt',
                style: titleStyle(size: 18, weight: FontWeight.w700, color: tone.ink)),
            const SizedBox(height: 8),
            Text(
              'L’onglet existe déjà pour que vous trouviez vos repères. '
              'Il sera activé quand les comptes et l’historique des versions seront en ligne.',
              style: TextStyle(fontSize: 14, height: 1.6, color: tone.ink),
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
    final tone = ToneColors.from(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: tone.subtle,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sommaire',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: tone.ink,
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
                      style: TextStyle(fontSize: 13, color: tone.faint),
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
  const _References({
    required this.references,
    required this.keys,
    required this.onBack,
    required this.onOpenSource,
  });

  final List<ArticleReference> references;
  final Map<int, GlobalKey> keys;
  final VoidCallback onBack;
  final void Function(int number) onOpenSource;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notes et références',
                  style: titleStyle(
                      size: 21,
                      weight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: tone.ink)),
              const SizedBox(height: 7),
              Divider(height: 1, color: tone.lineSoft),
            ],
          ),
        ),
        for (final reference in references)
          Padding(
            key: keys[reference.position],
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${reference.position}.',
                      style: TextStyle(fontSize: 13, color: tone.muted)),
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
                    style: TextStyle(fontSize: 13, height: 1.5, color: tone.ink),
                  ),
                ),
                const SizedBox(width: 4),
                if (reference.sourceId != null)
                  Tooltip(
                    message: 'Voir la fiche dans la bibliothèque des sources',
                    child: IconButton(
                      onPressed: () => onOpenSource(reference.position),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: Icon(Icons.library_books_outlined,
                          size: 13, color: IvoireColors.green),
                    ),
                  ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Revenir au texte',
                  child: IconButton(
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    icon: Icon(Icons.arrow_upward, size: 13, color: tone.faint),
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
    final tone = ToneColors.from(context);
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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tone.lineSoft)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Catégories :',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: tone.ink),
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
    final tone = ToneColors.from(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.subtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos de cet article',
              style: titleStyle(size: 15, weight: FontWeight.w700, color: tone.ink)),
          const SizedBox(height: 10),
          _line('Type', article.typeLabel, tone),
          if (article.categoryName != null) _line('Domaine', article.categoryName!, tone),
          if (article.authorName != null) _line('Auteur', article.authorName!, tone),
        ],
      ),
    );
  }

  Widget _line(String label, String value, ToneColors tone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$label : ',
            style: TextStyle(fontSize: 12, color: tone.muted),
          ),
          TextSpan(text: value, style: TextStyle(fontSize: 12.5, color: tone.ink)),
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
    final tone = ToneColors.from(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notFound ? 'Page inexistante' : 'Service indisponible',
            style: titleStyle(size: 26, weight: FontWeight.w700, color: tone.ink),
          ),
          const SizedBox(height: 8),
          const WeaveRule(height: 3, opacity: 0.7),
          const SizedBox(height: 14),
          Text(message, style: TextStyle(fontSize: 14, color: tone.ink)),
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
