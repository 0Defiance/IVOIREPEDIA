import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../models/sources.dart';
import '../theme.dart';
import 'shell.dart';

/// Page « Sources » : toutes les références des articles publiés, classées par
/// institution. Chaque référence rappelle les articles qui la citent.
class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  Future<SourceLibrary>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ApiScope.of(context).fetchSources();
  }

  void _retry() {
    setState(() => _future = ApiScope.of(context).fetchSources());
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: FutureBuilder<SourceLibrary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(text: '${snapshot.error}', action: _retry);
          }

          if (!snapshot.hasData) {
            return const _Message(text: 'Chargement des sources…');
          }

          return _SourcesBody(library: snapshot.data!);
        },
      ),
    );
  }
}

class _SourcesBody extends StatelessWidget {
  const _SourcesBody({required this.library});

  final SourceLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOURCES · BIBLIOGRAPHIE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: IvoireColors.orangeDeep,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'D’où viennent nos informations',
            style: TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: IvoireColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Chaque chiffre, chaque date citée dans un article renvoie à une '
              'source. Cette page réunit toutes les références de la plateforme, '
              'classées par institution : les organismes officiels d’abord, puis '
              'les ouvrages et encyclopédies. Une même référence citée par '
              'plusieurs articles n’apparaît qu’une fois.',
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: IvoireColors.muted.withValues(alpha: 0.95),
              ),
            ),
          ),
          if (!library.isEmpty) ...[
            const SizedBox(height: 18),
            _Counters(library: library),
            const SizedBox(height: 26),
            for (final institution in library.institutions) ...[
              _InstitutionCard(institution: institution),
              const SizedBox(height: 22),
            ],
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                'Aucune source publiée pour le moment.',
                style: TextStyle(fontSize: 14, color: IvoireColors.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _Counters extends StatelessWidget {
  const _Counters({required this.library});

  final SourceLibrary library;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30,
      runSpacing: 12,
      children: [
        _Counter(
          value: '${library.institutionCount}',
          label: 'institutions',
        ),
        _Counter(
          value: '${library.referenceCount}',
          label: 'références distinctes',
        ),
        _Counter(
          value: '${library.articleCount}',
          label: 'articles sourcés',
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: IvoireColors.ink,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            color: IvoireColors.faint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard({required this.institution});

  final SourceInstitution institution;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  institution.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: IvoireColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: IvoireColors.subtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: IvoireColors.lineSoft),
                ),
                child: Text(
                  institution.count == 1
                      ? '1 référence'
                      : '${institution.count} références',
                  style: const TextStyle(fontSize: 11, color: IvoireColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final reference in institution.references)
            _ReferenceRow(reference: reference),
        ],
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.reference});

  final SourceReference reference;

  Future<void> _open() async {
    final url = reference.url;

    if (url == null || url.isEmpty) {
      return;
    }

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7, right: 8),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: IvoireColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  reference.year == null
                      ? reference.title
                      : '${reference.title} (${reference.year})',
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: IvoireColors.ink,
                  ),
                ),
              ),
              if (reference.url != null && reference.url!.isNotEmpty)
                IconButton(
                  tooltip: 'Ouvrir la source',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.open_in_new, size: 15),
                  color: IvoireColors.green,
                  onPressed: _open,
                ),
            ],
          ),
          if (reference.articles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  const Text(
                    'Cité par :',
                    style: TextStyle(fontSize: 11, color: IvoireColors.faint),
                  ),
                  for (final article in reference.articles)
                    InkWell(
                      onTap: () => context.go('/articles/${article.slug}'),
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: IvoireColors.green,
                          decoration: TextDecoration.underline,
                        ),
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

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: IvoireColors.muted),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: action, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
