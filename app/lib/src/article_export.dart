import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models/article.dart';

/// Adresse publique du site : sert aux liens copiés, au PDF et au partage.
/// Le site est publié sous `/site/` ; l'API reste sous `/api/v1`.
const String kSiteUrl = 'https://ivoirepedia.alwaysdata.net/site';

/// Licence du texte, rappelée à chaque export (CONTEXT §13).
const String kContentLicense = 'CC BY-SA 4.0';

String articleUrl(String slug) => '$kSiteUrl/#/articles/$slug';

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
      buffer.writeln('${reference.position}. ${_referenceLine(reference)}');
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

String _referenceLine(ArticleReference reference) => [
      if (reference.authors != null) reference.authors!,
      reference.title,
      if (reference.publisher != null) reference.publisher!,
      if (reference.year != null) '${reference.year}',
      if (reference.url != null) reference.url!,
    ].join(', ');

String _sourceLine(ArticleDetail article) =>
    'Source : IVOIREPEDIA, l’encyclopédie libre — ${articleUrl(article.slug)}';

// ---------------------------------------------------------------------------
// PDF
// ---------------------------------------------------------------------------

/// Polices nécessaires au PDF. Inter est embarquée : le document garde le
/// même dessin que le site, et accepte les caractères typographiques français
/// (apostrophe courbe, tirets cadratins) que Latin-1 ne couvre pas.
class ArticlePdfFonts {
  const ArticlePdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;

  /// Charge les TTF déclarées dans `pubspec.yaml`.
  static Future<ArticlePdfFonts> load() async {
    final regular = await rootBundle.load('assets/fonts/Inter-400.ttf');
    final bold = await rootBundle.load('assets/fonts/Inter-600.ttf');

    return ArticlePdfFonts(
      regular: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
    );
  }
}

const PdfColor _ink = PdfColor.fromInt(0xFF16211B);
const PdfColor _muted = PdfColor.fromInt(0xFF5B6459);
const PdfColor _faint = PdfColor.fromInt(0xFF828A7E);
const PdfColor _rule = PdfColor.fromInt(0xFFEAE5D9);
const PdfColor _terracotta = PdfColor.fromInt(0xFFB4552C);

/// Construit le PDF d'un article : titre, métadonnées, corps, références,
/// catégories, puis la mention de source et de licence en pied de page.
Future<Uint8List> buildArticlePdf(
  ArticleDetail article, {
  required ArticlePdfFonts fonts,
  DateTime? generatedAt,
}) {
  final document = pw.Document(
    title: article.title,
    author: article.authorName ?? 'IVOIREPEDIA',
    subject: article.summary,
    creator: 'IVOIREPEDIA',
  );

  final blocks = articleBlocks(article.contentOps);
  final generated = generatedAt ?? DateTime.now();
  final text = _PdfText(fonts);

  pw.TextStyle style({
    double size = 10.5,
    PdfColor color = _ink,
    bool bold = false,
    double lineSpacing = 3.6,
  }) =>
      text(size: size, color: color, bold: bold, lineSpacing: lineSpacing);

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(56, 52, 56, 60),
      footer: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(height: 0.6, color: _rule),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'IVOIREPEDIA — ${articleUrl(article.slug)}',
                  style: style(size: 8, color: _faint, lineSpacing: 1),
                ),
              ),
              pw.Text(
                '${context.pageNumber} / ${context.pagesCount}',
                style: style(size: 8, color: _faint, lineSpacing: 1),
              ),
            ],
          ),
        ],
      ),
      build: (context) => [
        // Repères éditoriaux : domaine et type, comme sur la page.
        pw.Text(
          [
            if (article.categoryName != null) article.categoryName!.toUpperCase(),
            article.typeLabel.toUpperCase(),
          ].join('  ·  '),
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 8,
            color: _terracotta,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 7),
        pw.Text(
          article.title,
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 22,
            color: _ink,
            lineSpacing: 2,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 0.8, color: _rule),
        pw.SizedBox(height: 5),
        pw.Text(
          [
            if (article.publishedAt != null)
              'Dernière modification le ${_formatDate(article.publishedAt!)}',
            '${article.readingMinutes} min de lecture',
            'Licence $kContentLicense',
          ].join('  ·  '),
          style: style(size: 8.5, color: _faint, lineSpacing: 1),
        ),
        pw.SizedBox(height: 16),
        if (blocks.isEmpty)
          pw.Paragraph(text: article.summary, style: style(size: 11))
        else
          ..._pdfBlocks(blocks, text),
        if (article.references.isNotEmpty) ...[
          pw.SizedBox(height: 18),
          _pdfHeading('Notes et références', text),
          for (final reference in article.references)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 20,
                    child: pw.Text(
                      '${reference.position}.',
                      style: style(size: 9, color: _muted, lineSpacing: 1),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _referenceLine(reference),
                      style: style(size: 9, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
        ],
        pw.SizedBox(height: 18),
        pw.Container(height: 0.6, color: _rule),
        pw.SizedBox(height: 7),
        pw.Text(
          [
            if (article.categoryName != null) 'Domaine : ${article.categoryName}',
            if (article.tags.isNotEmpty) 'Catégories : ${article.tags.join(', ')}',
          ].join('\n'),
          style: style(size: 8.5, color: _muted, lineSpacing: 1.5),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Texte extrait d’IVOIREPEDIA, l’encyclopédie libre, le '
          '${_formatDate(generated)}. '
          'Reproduction autorisée sous licence $kContentLicense, source citée.',
          style: style(size: 8.5, color: _faint, lineSpacing: 1.5),
        ),
      ],
    ),
  );

  return document.save();
}

/// Styles de texte du PDF, construits une fois à partir des polices.
class _PdfText {
  const _PdfText(this.fonts);

  final ArticlePdfFonts fonts;

  pw.TextStyle call({
    double size = 10.5,
    PdfColor color = _ink,
    bool bold = false,
    double lineSpacing = 3.6,
  }) =>
      pw.TextStyle(
        font: bold ? fonts.bold : fonts.regular,
        fontSize: size,
        color: color,
        lineSpacing: lineSpacing,
      );
}

List<pw.Widget> _pdfBlocks(List<ArticleBlock> blocks, _PdfText text) {
  final widgets = <pw.Widget>[];
  var ordered = 0;

  for (final block in blocks) {
    if (block.isHeading) {
      ordered = 0;
      widgets.add(_pdfHeading(block.text, text));
      continue;
    }

    if (block.list == 'ordered') {
      ordered++;
      widgets.add(_pdfListRow('$ordered.', block.text, text));
      continue;
    }

    if (block.list == 'bullet') {
      ordered = 0;
      widgets.add(_pdfListRow('•', block.text, text));
      continue;
    }

    ordered = 0;

    if (block.blockquote) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 10),
          padding: const pw.EdgeInsets.only(left: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: _rule, width: 2)),
          ),
          child: pw.Text(block.text, style: text(color: _muted)),
        ),
      );
      continue;
    }

    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(block.text, style: text(bold: block.bold)),
      ),
    );
  }

  return widgets;
}

pw.Widget _pdfHeading(String text, _PdfText style) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            text,
            style: pw.TextStyle(
              font: style(bold: true).font,
              fontSize: 13.5,
              color: _ink,
              lineSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 0.5, color: _rule),
        ],
      ),
    );

pw.Widget _pdfListRow(String marker, String text, _PdfText style) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 16,
            child: pw.Text(marker, style: style(color: _muted)),
          ),
          pw.Expanded(child: pw.Text(text, style: style())),
        ],
      ),
    );

String _formatDate(DateTime date) {
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Écrit le fichier chez l'utilisateur. Remplaçable en test : le
/// téléchargement du navigateur n'est pas exerçable hors navigateur.
typedef PdfSaver = Future<void> Function(String name, Uint8List bytes);

Future<void> _saveWithBrowser(String name, Uint8List bytes) =>
    FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );

/// Génère le PDF d'un article et le fait télécharger par le navigateur.
/// Retourne le nom du fichier proposé.
Future<String> downloadArticlePdf(
  ArticleDetail article, {
  PdfSaver save = _saveWithBrowser,
  ArticlePdfFonts? fonts,
}) async {
  final bytes = await buildArticlePdf(
    article,
    fonts: fonts ?? await ArticlePdfFonts.load(),
  );
  final name = article.slug;

  await save(name, bytes);

  return '$name.pdf';
}
