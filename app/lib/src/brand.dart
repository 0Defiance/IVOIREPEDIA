import 'package:flutter/material.dart';

import 'theme.dart';

/// Marque IVOIREPEDIA : globe stylisé (méridiens et parallèles), puis le nom
/// en serif et la devise « L'encyclopédie ivoirienne libre ». Dessinée en code :
/// nette à toute taille, sans fichier binaire à maintenir.
class IvoireMark extends StatelessWidget {
  const IvoireMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlobePainter()),
    );
  }
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, w / 2);
    final radius = w * 0.46;

    // Corps du globe : l'ivoire et l'orange du drapeau, en deux calottes.
    canvas.drawCircle(center, radius, Paint()..color = IvoireColors.subtle);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, w * 0.42),
      Paint()..color = IvoireColors.orange.withValues(alpha: 0.28),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, w * 0.62, w, w * 0.4),
      Paint()..color = IvoireColors.green.withValues(alpha: 0.24),
    );

    final meridian = Paint()
      ..color = IvoireColors.ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035;

    // Méridiens (ellipses verticales) et parallèles (lignes horizontales).
    for (final factor in [0.35, 0.7, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * factor,
          height: radius * 2,
        ),
        meridian,
      );
    }

    for (final factor in [0.45, 0.0, -0.45]) {
      final y = center.dy + radius * factor;
      final halfWidth = radius * (1 - factor * factor).clamp(0.0, 1.0);
      final chord = ((halfWidth * halfWidth) <= 0)
          ? 0.0
          : (radius * radius - (radius * factor) * (radius * factor));
      final dx = chord <= 0 ? 0.0 : _sqrt(chord);
      canvas.drawLine(
        Offset(center.dx - dx, y),
        Offset(center.dx + dx, y),
        meridian,
      );
    }

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = IvoireColors.ink.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045,
    );
  }

  double _sqrt(double value) {
    var guess = value;
    for (var i = 0; i < 20; i++) {
      guess = 0.5 * (guess + value / guess);
    }
    return guess;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marque + nom + devise, comme l'en-tête d'une encyclopédie.
class IvoireLogo extends StatelessWidget {
  const IvoireLogo({super.key, this.size = 44, this.compact = false});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IvoireMark(size: size),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IVOIREPEDIA',
              style: serifStyle(size: size * 0.46, weight: FontWeight.w600),
            ),
            Text(
              compact ? "L'encyclopédie libre" : "L'encyclopédie ivoirienne libre",
              style: const TextStyle(fontSize: 11, color: IvoireColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}
