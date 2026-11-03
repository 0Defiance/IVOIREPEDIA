import 'package:flutter/material.dart';

import 'theme.dart';

/// Marque IVOIREPEDIA : un carré ivoire cerclé d'orange et de vert, traversé
/// d'une tige dorée — « la défense d'ivoire » stylisée. Dessinée en code, donc
/// nette à toutes les tailles et sans fichier binaire (le dépôt n'en contient
/// pas encore).
class IvoireMark extends StatelessWidget {
  const IvoireMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final radius = Radius.circular(w * 0.28);
    final rect = Offset.zero & size;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = IvoireColors.ink,
    );

    // Bande orange (haut) et verte (bas) : rappel du drapeau.
    final orange = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, w * 0.34)
      ..lineTo(0, w * 0.52)
      ..close();
    canvas.drawPath(orange, Paint()..color = IvoireColors.orange);

    final green = Path()
      ..moveTo(0, w * 0.72)
      ..lineTo(w, w * 0.56)
      ..lineTo(w, w)
      ..lineTo(0, w)
      ..close();
    canvas.drawPath(green, Paint()..color = IvoireColors.green);

    // Tige ivoire, légèrement courbée : la « défense ».
    final tusk = Path()
      ..moveTo(w * 0.34, w * 0.22)
      ..quadraticBezierTo(w * 0.78, w * 0.42, w * 0.52, w * 0.82);
    canvas.drawPath(
      tusk,
      Paint()
        ..color = IvoireColors.ivory
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.11
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(w * 0.36, w * 0.24),
      w * 0.055,
      Paint()..color = IvoireColors.gold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marque + nom. `compact` réduit le sous-titre pour les barres étroites.
class IvoireLogo extends StatelessWidget {
  const IvoireLogo({super.key, this.size = 40, this.compact = false});

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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                fontSize: size * 0.42,
                color: IvoireColors.ink,
              ),
            ),
            if (!compact)
              Text(
                "L'encyclopédie ivoirienne",
                style: TextStyle(
                  fontSize: size * 0.24,
                  color: IvoireColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
