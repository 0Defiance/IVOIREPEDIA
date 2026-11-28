import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import 'shell.dart';
import 'widgets/article_list.dart';
import 'widgets/page_parts.dart';

/// Page d'étiquette : « Étiquette : Indépendance » et les articles qui la
/// portent.
///
/// Le filtre est celui de l'API (`GET /api/v1/articles?tag=…`), qui accepte le
/// slug de l'étiquette. Le nom affiché vient de l'article d'où l'on vient
/// (`?nom=`) : c'est le seul endroit où l'application le connaît, l'API ne
/// servant pas de liste d'étiquettes. Une adresse saisie à la main retombe donc
/// sur le slug mis en forme.
class TagPage extends StatefulWidget {
  const TagPage({required this.slug, this.name, super.key});

  final String slug;
  final String? name;

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  /// Total annoncé par la première page ; nul tant que le serveur n'a pas
  /// répondu, pour ne pas afficher « 0 page » le temps du chargement.
  int? _total;

  /// Nom lisible quand l'adresse arrive sans `?nom=` (lien partagé, saisie).
  String get _label {
    final given = widget.name?.trim() ?? '';

    if (given.isNotEmpty) {
      return given;
    }

    final words = widget.slug.replaceAll('-', ' ').trim();

    return words.isEmpty
        ? 'Étiquette'
        : words[0].toUpperCase() + words.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiScope.of(context);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              kicker: 'ÉTIQUETTE',
              title: 'Étiquette : $_label',
              intro:
                  'Articles publiés qui portent cette étiquette, quel que '
                  'soit leur domaine.',
            ),
            if (_total != null) ...[
              const SizedBox(height: 10),
              Text(
                '$_total page${_total! > 1 ? 's' : ''} avec cette étiquette.',
                style: const TextStyle(fontSize: 12, color: IvoireColors.faint),
              ),
            ],
            const SizedBox(height: 22),
            SectionHeading(title: 'Pages étiquetées'),
            const SizedBox(height: 8),
            PagedArticleList(
              loadPage: (page) =>
                  api.fetchArticles(tag: widget.slug, limit: 20, page: page),
              onProgress: (_, total) => setState(() => _total = total),
              emptyMessage:
                  'Aucune page publiée ne porte encore cette étiquette.',
            ),
          ],
        ),
      ),
    );
  }
}
