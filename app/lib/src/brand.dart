import 'package:flutter/material.dart';

import 'theme.dart';

/// Marque IVOIREPEDIA : un médaillon aux trois bandes du drapeau ivoirien
/// (orange, blanc, vert), cerclé de vert profond. Dessiné en code : net à
/// toute taille, aucun fichier binaire à maintenir.
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
    final center = Offset(w / 2, w / 2);
    final radius = w * 0.46;

    final clip = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.clipPath(clip);

    // Trois bandes verticales, comme le drapeau.
    final band = radius * 2 / 3;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - radius, center.dy - radius, band, radius * 2),
      Paint()..color = IvoireColors.orange,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - radius + band, center.dy - radius, band, radius * 2),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - radius + band * 2, center.dy - radius, band, radius * 2),
      Paint()..color = IvoireColors.green,
    );

    // Voile haut/bas : donne du relief au médaillon.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, w * 0.34),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = IvoireColors.greenDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marque + nom + devise, dans une seule famille typographique.
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
              style: titleStyle(
                size: size * 0.42,
                weight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              compact ? "L'encyclopédie libre" : "L'encyclopédie ivoirienne libre",
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.2,
                letterSpacing: 0.1,
                color: IvoireColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
