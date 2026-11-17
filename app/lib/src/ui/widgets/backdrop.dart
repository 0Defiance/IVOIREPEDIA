import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Fond du site : un lavis de couleur très pâle et un grain de papier.
///
/// Les motifs dessinés en code (losanges « baoulé », frise « Korhogo ») ont
/// été retirés : ils imitaient des motifs réels sans en être. La matière
/// visuelle vient désormais des photographies sourcées des articles, pas
/// d'un décor inventé.
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

    // Lavis : orange brûlé en haut à gauche, vert forêt en bas à droite.
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

    _grain(canvas, size);
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
