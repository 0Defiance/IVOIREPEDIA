import 'package:flutter/material.dart';

import '../../theme.dart';

/// Titre de section en petites capitales, précédé d'un filet orange.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 22, height: 3, color: IvoireColors.orange),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
              color: IvoireColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}
