
import 'package:flutter/material.dart';

export 'backdrop.dart';

import '../../theme.dart';

/// Interrupteur global du mouvement décoratif. Les tests le désactivent pour
/// que `pumpAndSettle` ne tourne pas sur une animation infinie.
bool ivoireMotionEnabled = true;

/// Met en pause les animations décoratives si la plateforme le demande
/// (préférence système « réduire les animations »).
bool ivoireMotionAllowed(BuildContext context) {
  if (!ivoireMotionEnabled) {
    return false;
  }

  return !MediaQuery.disableAnimationsOf(context);
}

/// Bandeau tissé (kente) qui défile lentement : le rappel ivoirien le plus
/// visible, peint en code, sans image à charger.
class KenteBand extends StatefulWidget {
  const KenteBand({this.height = 6, super.key});

  final double height;

  @override
  State<KenteBand> createState() => _KenteBandState();
}

class _KenteBandState extends State<KenteBand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final motion = ivoireMotionAllowed(context);

    if (motion && !_running) {
      _controller.repeat();
      _running = true;
    } else if (!motion && _running) {
      _controller.stop();
      _running = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _KentePainter(progress: _controller.value),
        ),
      ),
    );
  }
}

class _KentePainter extends CustomPainter {
  _KentePainter({required this.progress});

  final double progress;

  static const double _period = 132;

  // Largeur + couleur : le rythme irrégulier d'une bande tissée.
  static const List<(double, Color)> _blocks = [
    (14, IvoireColors.orange),
    (4, IvoireColors.ink),
    (22, IvoireColors.green),
    (5, IvoireColors.gold),
    (10, IvoireColors.orange),
    (18, IvoireColors.gold),
    (5, IvoireColors.ink),
    (14, IvoireColors.green),
    (6, IvoireColors.ivory),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = IvoireColors.ivory,
    );

    final shift = -progress * _period;
    final paint = Paint();

    for (double start = shift - _period; start < size.width + _period; start += _period) {
      var x = start;
      for (final block in _blocks) {
        paint.color = block.$2;
        canvas.drawRect(Rect.fromLTWH(x, 0, block.$1, size.height), paint);
        x += block.$1;
      }
    }

    // Petit peigne tissé, comme la trame d'un pagne.
    final weft = Paint()
      ..color = IvoireColors.ink.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;
    for (double x = shift; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), weft);
    }
  }

  @override
  bool shouldRepaint(covariant _KentePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Filet d'accent orange → or → vert.
class WeaveRule extends StatelessWidget {
  const WeaveRule({this.height = 3, this.opacity = 1, super.key});

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            for (final color in IvoireColors.weave) color.withValues(alpha: opacity),
          ],
        ),
      ),
    );
  }
}

/// Petit séparateur à losanges, pour les pieds de page et les blocs.
class MotifDivider extends StatelessWidget {
  const MotifDivider({this.color = IvoireColors.terracotta, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 12,
      child: CustomPaint(painter: _DividerPainter(color: color)),
    );
  }
}

class _DividerPainter extends CustomPainter {
  _DividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final diamond = Paint()..color = color.withValues(alpha: 0.75);

    final mid = size.height / 2;
    canvas.drawLine(Offset(0, mid), Offset(size.width * 0.32, mid), line);
    canvas.drawLine(Offset(size.width * 0.68, mid), Offset(size.width, mid), line);

    for (var i = 0; i < 3; i++) {
      final cx = size.width / 2 + (i - 1) * 16.0;
      final path = Path()
        ..moveTo(cx, mid - 4)
        ..lineTo(cx + 4, mid)
        ..lineTo(cx, mid + 4)
        ..lineTo(cx - 4, mid)
        ..close();
      canvas.drawPath(path, diamond);
    }
  }

  @override
  bool shouldRepaint(covariant _DividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
