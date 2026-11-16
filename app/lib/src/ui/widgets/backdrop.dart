import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Peint le fond du site : un tissu ivoirien discret, composé de quatre
/// couches — lavis de couleur, lisière tissée sur les bords, treillis de
/// losanges, rosaces de pagne et frise Korhogo en bas. Tout est peint en
/// code : aucun asset à charger, et l'opacité reste faible pour que le texte
/// garde la priorité visuelle.
class IvorianBackdrop extends StatelessWidget {
  const IvorianBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [IvoireColors.sand, IvoireColors.ivory, IvoireColors.canvas],
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _BackdropPainter(),
            isComplex: true,
            willChange: false,
          ),
        ),
        child,
      ],
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Lavis : orange brûlé en haut à gauche, vert forêt en bas à droite.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.9, -1.0),
          radius: 1.5,
          colors: [Color(0x1AE2661B), Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(1.0, 1.1),
          radius: 1.6,
          colors: [Color(0x170B7A42), Color(0x00FFFFFF)],
        ).createShader(rect),
    );

    _lattice(canvas, size);
    _rosettes(canvas, size);
    _selvedge(canvas, size);
    _korhogoBand(canvas, size);
    _grain(canvas, size);
  }

  /// Treillis de losanges, très pâle : la trame d'un pagne baoulé.
  void _lattice(Canvas canvas, Size size) {
    const step = 46.0;
    final paint = Paint()
      ..color = IvoireColors.green.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x, y - step * 0.5)
          ..lineTo(x + step * 0.5, y)
          ..lineTo(x, y + step * 0.5)
          ..lineTo(x - step * 0.5, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Quatre grandes rosaces de pagne « wax », posées aux angles de la page.
  void _rosettes(Canvas canvas, Size size) {
    final spots = <(double, double, double, Color)>[
      (0.06, 0.04, 120, IvoireColors.orange),
      (0.97, 0.12, 150, IvoireColors.green),
      (0.02, 0.72, 140, IvoireColors.terracotta),
      (0.94, 0.86, 130, IvoireColors.gold),
    ];

    for (final (fx, fy, radius, color) in spots) {
      final center = Offset(size.width * fx, size.height * fy);
      final stroke = Paint()
        ..color = color.withValues(alpha: 0.055)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(center, radius, stroke);
      canvas.drawCircle(center, radius * 0.62, stroke);

      // Pétales : huit lobes autour du cœur, comme un motif imprimé.
      final petal = Path();
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final tip = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.86;
        petal.moveTo(center.dx, center.dy);
        petal.quadraticBezierTo(
          center.dx + math.cos(angle - 0.35) * radius * 0.5,
          center.dy + math.sin(angle - 0.35) * radius * 0.5,
          tip.dx,
          tip.dy,
        );
      }
      canvas.drawPath(petal, stroke);
      canvas.drawCircle(center, radius * 0.16, Paint()..color = color.withValues(alpha: 0.07));
    }
  }

  /// Lisière tissée sur les deux bords : petits blocs orange, or et vert.
  void _selvedge(Canvas canvas, Size size) {
    const width = 22.0;
    const block = 26.0;
    final colors = [IvoireColors.orange, IvoireColors.gold, IvoireColors.green];

    for (var side = 0; side < 2; side++) {
      final left = side == 0 ? 0.0 : size.width - width;
      final bg = Paint()..color = IvoireColors.sand.withValues(alpha: 0.55);
      canvas.drawRect(Rect.fromLTWH(left, 0, width, size.height), bg);

      var index = 0;
      for (double y = 0; y < size.height; y += block, index++) {
        final color = colors[index % colors.length];
        canvas.drawRect(
          Rect.fromLTWH(left + 4, y + 5, width - 8, block * 0.42),
          Paint()..color = color.withValues(alpha: 0.10),
        );
      }

      final edge = Paint()
        ..color = IvoireColors.terracotta.withValues(alpha: 0.10)
        ..strokeWidth = 1;
      final x = side == 0 ? width + 1 : left - 1;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), edge);
    }
  }

  /// Frise Korhogo en bas de page : triangles, cercles et traits gravés.
  void _korhogoBand(Canvas canvas, Size size) {
    if (size.height < 260) {
      return;
    }

    final top = size.height - 92;
    final stroke = Paint()
      ..color = IvoireColors.ink.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final fill = Paint()..color = IvoireColors.terracotta.withValues(alpha: 0.05);

    canvas.drawLine(
      Offset(0, top),
      Offset(size.width, top),
      Paint()
        ..color = IvoireColors.ink.withValues(alpha: 0.05)
        ..strokeWidth = 1,
    );

    const step = 74.0;
    var index = 0;
    for (double x = 30; x < size.width; x += step, index++) {
      final center = Offset(x, top + 34);
      if (index.isEven) {
        // Triangle gravé.
        final path = Path()
          ..moveTo(center.dx, center.dy - 16)
          ..lineTo(center.dx + 18, center.dy + 14)
          ..lineTo(center.dx - 18, center.dy + 14)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawPath(path, fill);
      } else {
        // Cercles concentriques et points, comme sur les toiles de Korhogo.
        canvas.drawCircle(center, 15, stroke);
        canvas.drawCircle(center, 8, stroke);
        canvas.drawCircle(center, 2.4, Paint()..color = IvoireColors.ink.withValues(alpha: 0.10));
      }
    }
  }

  /// Grain fin : casse l'aplat du fond et donne un rendu papier.
  void _grain(Canvas canvas, Size size) {
    final paint = Paint()..color = IvoireColors.ink.withValues(alpha: 0.018);
    final random = math.Random(7);

    for (double y = 0; y < size.height; y += 14) {
      for (double x = 0; x < size.width; x += 14) {
        final dx = (random.nextDouble() - 0.5) * 8;
        final dy = (random.nextDouble() - 0.5) * 8;
        canvas.drawCircle(Offset(x + dx, y + dy), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}
