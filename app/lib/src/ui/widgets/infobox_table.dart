import 'package:flutter/material.dart';

import '../../theme.dart';
import '../format.dart';

/// Infobox structurée (CONTEXT §8.3) : les clés du JSON sont traduites en
/// libellés français lisibles, et les valeurs vides ne sont pas affichées.
class InfoboxTable extends StatelessWidget {
  const InfoboxTable({required this.infobox, required this.typeLabel, super.key});

  final Map<String, dynamic> infobox;
  final String typeLabel;

  static const Map<String, String> _labels = {
    'fullName': 'Nom complet',
    'birthDate': 'Naissance',
    'birthPlace': 'Lieu de naissance',
    'deathDate': 'Décès',
    'deathPlace': 'Lieu de décès',
    'nationalities': 'Nationalité',
    'occupations': 'Profession',
    'level': 'Niveau administratif',
    'population': 'Population',
    'populationYear': 'Année du recensement',
    'areaKm2': 'Superficie (km²)',
    'ethnicGroups': 'Groupes ethniques',
    'languages': 'Langues',
    'officialName': 'Nom officiel',
    'acronym': 'Sigle',
    'institutionType': 'Type',
    'foundedYear': 'Fondation',
    'headquarters': 'Siège',
  };

  static const Map<String, String> _levels = {
    'DISTRICT': 'District',
    'REGION': 'Région',
    'DEPARTMENT': 'Département',
    'SUB_PREFECTURE': 'Sous-préfecture',
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IvoireColors.paper,
        border: Border.all(color: IvoireColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            typeLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: IvoireColors.orange,
            ),
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.key,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: IvoireColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: IvoireColors.ink,
                    ),
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
      return '${_groupThousands(value.toInt())} habitants';
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
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}
