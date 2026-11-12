import 'package:flutter/material.dart';

import '../../theme.dart';
import '../format.dart';

/// Infobox structurée (CONTEXT §8.3), présentée comme un tableau d'encyclopédie :
/// titre encadré, libellés en petites capitales, valeurs en clair.
class InfoboxTable extends StatelessWidget {
  const InfoboxTable({
    required this.infobox,
    required this.typeLabel,
    this.title,
    super.key,
  });

  final Map<String, dynamic> infobox;
  final String typeLabel;
  final String? title;

  static const Map<String, String> _labels = {
    'fullName': 'Nom complet',
    'birthDate': 'Naissance',
    'birthPlace': 'Lieu de naissance',
    'deathDate': 'Décès',
    'deathPlace': 'Lieu de décès',
    'nationalities': 'Nationalité',
    'occupations': 'Profession',
    'level': 'Statut',
    'population': 'Population',
    'populationYear': 'Recensement',
    'areaKm2': 'Superficie',
    'ethnicGroups': 'Groupes ethniques',
    'languages': 'Langues',
    'officialName': 'Nom officiel',
    'acronym': 'Sigle',
    'institutionType': 'Type',
    'foundedYear': 'Fondation',
    'headquarters': 'Siège',
  };

  static const Map<String, String> _levels = {
    'DISTRICT': 'District autonome',
    'REGION': 'Région',
    'DEPARTMENT': 'Département',
    'SUB_PREFECTURE': 'Sous-préfecture',
    'CITY': 'Ville',
    'VILLAGE': 'Village',
  };

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[];

    for (final entry in infobox.entries) {
      final label = _labels[entry.key];
      final value = _format(entry.key, entry.value);

      if (label != null && value.isNotEmpty) {
        rows.add(MapEntry(label, value));
      }
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: IvoireColors.subtle,
        border: Border.all(color: IvoireColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: IvoireColors.highlight,
            child: Column(
              children: [
                Text(
                  title ?? typeLabel,
                  textAlign: TextAlign.center,
                  style: titleStyle(size: 16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  typeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: IvoireColors.muted),
                ),
              ],
            ),
          ),
          for (final row in rows)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: IvoireColors.lineSoft)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.key,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: IvoireColors.muted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    row.value,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _format(String key, dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is List) {
      return value.map((item) => '$item').join(', ');
    }

    if (key == 'level') {
      return _levels['$value'] ?? '$value';
    }

    if (key == 'birthDate' || key == 'deathDate') {
      return formatDate(DateTime.tryParse('$value'));
    }

    if (key == 'population' && value is num) {
      return '${_groupThousands(value.toInt())} hab.';
    }

    if (key == 'areaKm2') {
      return '$value km²';
    }

    return '$value';
  }

  String _groupThousands(int value) {
    final text = '$value';
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('\u202F');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}
