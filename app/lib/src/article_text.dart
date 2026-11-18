import 'models/article.dart';

/// Adresse publique du site : sert aux liens copiés, au PDF et au partage.
/// Le site occupe la racine du domaine ; l'API reste sous `/api/v1`.
const String kSiteUrl = 'https://ivoirepedia.alwaysdata.net';

/// Licence du texte, rappelée à chaque export (CONTEXT §13).
const String kContentLicense = 'CC BY-SA 4.0';

String articleUrl(String slug) => '$kSiteUrl/articles/$slug';

/// Un bloc de texte d'article, extrait du Delta Quill (ADR-003).
///
/// Le rendu à l'écran (`DeltaContent`), le presse-papiers et le PDF partent
/// tous de cette lecture : un seul analyseur, donc un seul texte.
class ArticleBlock {
  const ArticleBlock({
    required this.text,
    this.headerLevel,
    this.list,
    this.blockquote = false,
    this.bold = false,
  });

  final String text;

  /// 1 à 6 pour un titre de section, `null` pour un paragraphe.
  final int? headerLevel;

  /// `bullet` ou `ordered` pour un élément de liste.
  final String? list;

  final bool blockquote;
  final bool bold;

  bool get isHeading => headerLevel != null;
}

/// Découpe un contenu Delta en blocs, dans l'ordre du document.
///
/// Les attributs d'une opération s'appliquent au bloc qu'elle termine : un
/// titre ne contamine pas le paragraphe suivant.
List<ArticleBlock> articleBlocks(List<Map<String, dynamic>> ops) {
  final blocks = <ArticleBlock>[];
  final buffer = StringBuffer();
  Map<String, dynamic>? pendingAttributes;

  void flush() {
    final text = buffer.toString().trimRight();
    buffer.clear();

    final attributes = pendingAttributes;
    pendingAttributes = null;

    if (text.trim().isEmpty) {
      return;
    }

    final header = attributes?['header'];
    final list = attributes?['list'];

    blocks.add(
      ArticleBlock(
        text: text.trim(),
        headerLevel: header is int ? header : null,
        list: list is String ? list : null,
        blockquote: attributes?['blockquote'] == true,
        bold: attributes?['bold'] == true,
      ),
    );
  }

  for (final op in ops) {
    final insert = op['insert'];
    if (insert is! String) {
      continue; // les embeds ne sont pas exportés
    }

    final attributes = op['attributes'] is Map<String, dynamic>
        ? op['attributes'] as Map<String, dynamic>
        : null;
    final lines = insert.split('\n');

    for (var i = 0; i < lines.length; i++) {
      buffer.write(lines[i]);

      if (i < lines.length - 1) {
        if (attributes != null) {
          pendingAttributes = attributes;
        }
        flush();
      } else if (attributes != null && lines[i].isNotEmpty) {
        pendingAttributes = attributes;
      }
    }
  }

  flush();

  return blocks;
}

/// Titres de sections, dans l'ordre d'apparition.
List<String> articleSections(List<ArticleBlock> blocks) => [
      for (final block in blocks)
        if (block.isHeading) block.text,
    ];

/// Blocs d'une seule section, titre exclu, jusqu'au titre suivant.
List<ArticleBlock> sectionBlocks(List<ArticleBlock> blocks, String heading) {
  final start = blocks.indexWhere(
    (block) => block.isHeading && block.text == heading,
  );

  if (start < 0) {
    return const <ArticleBlock>[];
  }

  final section = <ArticleBlock>[];
  for (final block in blocks.skip(start + 1)) {
    if (block.isHeading) {
      break;
    }
    section.add(block);
  }

  return section;
}

/// Texte prêt pour le presse-papiers : lisible en clair, hors de l'écran.
String articleAsText(ArticleDetail article) {
  final blocks = articleBlocks(article.contentOps);
  final buffer = StringBuffer()
    ..writeln(article.title)
    ..writeln();

  if (blocks.isEmpty) {
    buffer
      ..writeln(article.summary)
      ..writeln();
  } else {
    buffer.write(_blocksAsText(blocks));
  }

  if (article.references.isNotEmpty) {
    buffer
      ..writeln('Notes et références')
      ..writeln();
    for (final reference in article.references) {
      buffer.writeln('${reference.position}. ${articleReferenceLine(reference)}');
    }
    buffer.writeln();
  }

  final categories = <String>[
    if (article.categoryName != null) article.categoryName!,
    ...article.tags,
  ];
  if (categories.isNotEmpty) {
    buffer
      ..writeln('Catégories : ${categories.join(', ')}')
      ..writeln();
  }

  buffer
    ..writeln(_sourceLine(article))
    ..writeln('Texte disponible sous licence $kContentLicense.');

  return buffer.toString().trimRight();
}

/// Texte d'une section seule, avec sa provenance.
String sectionAsText(ArticleDetail article, String heading) {
  final blocks = sectionBlocks(articleBlocks(article.contentOps), heading);

  final buffer = StringBuffer()
    ..writeln(heading)
    ..writeln()
    ..write(_blocksAsText(blocks))
    ..writeln(_sourceLine(article));

  return buffer.toString().trimRight();
}

String _blocksAsText(List<ArticleBlock> blocks) {
  final buffer = StringBuffer();
  var ordered = 0;

  for (final block in blocks) {
    if (block.isHeading) {
      ordered = 0;
      buffer
        ..writeln()
        ..writeln(block.text)
        ..writeln();
      continue;
    }

    if (block.list == 'ordered') {
      ordered++;
      buffer.writeln('$ordered. ${block.text}');
      continue;
    }

    if (block.list == 'bullet') {
      ordered = 0;
      buffer.writeln('• ${block.text}');
      continue;
    }

    ordered = 0;
    buffer
      ..writeln(block.blockquote ? '« ${block.text} »' : block.text)
      ..writeln();
  }

  return buffer.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

String articleReferenceLine(ArticleReference reference) => [
      if (reference.authors != null) reference.authors!,
      reference.title,
      if (reference.publisher != null) reference.publisher!,
      if (reference.year != null) '${reference.year}',
      if (reference.url != null) reference.url!,
    ].join(', ');

String _sourceLine(ArticleDetail article) =>
    'Source : Ivoirepedia, l’encyclopédie libre de la Côte d’Ivoire — '
    '${articleUrl(article.slug)}';
