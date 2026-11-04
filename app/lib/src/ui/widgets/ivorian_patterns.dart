import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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

/// Fond du site : lavis chaud + champ de motifs de pagne ivoiriens qui dérive
/// très lentement. Un seul `CustomPaint` repeint, le contenu reste net par-dessus.
class IvorianBackdrop extends StatefulWidget {
  const IvorianBackdrop({required this.child, super.key});

  final Widget child;

  @override
  State<IvorianBackdrop> createState() => _IvorianBackdropState();
}

class _IvorianBackdropState extends State<IvorianBackdrop> {
  /// Le motif avance de quelques pixels par seconde : 20 images/s suffisent
  /// et divisent par trois le coût de peinture d'un fond plein écran.
  static const Duration _frame = Duration(milliseconds: 50);
  static const int _loopMs = 150000;

  final Stopwatch _clock = Stopwatch();
  Timer? _timer;
  double _progress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ivoireMotionAllowed(context)) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    if (_timer != null) {
      return;
    }

    _clock.start();
    _timer = Timer.periodic(_frame, (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _progress = (_clock.elapsedMilliseconds % _loopMs) / _loopMs;
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _clock.stop();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

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
              colors: [IvoireColors.sand, IvoireColors.ivory, IvoireColors.sand],
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _BackdropPainter(progress: _progress),
            isComplex: true,
            willChange: true,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Lavis de couleur : orange en haut, vert en bas, comme un tissu teint.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x1FE2661B), Color(0x00FFFFFF), Color(0x1A0B7A42)],
        ).createShader(rect),
    );

    _field(
      canvas,
      size,
      color: IvoireColors.orange.withValues(alpha: 0.13),
      tile: 164,
      shift: Offset(progress * 500, -progress * 320),
      seed: 0,
      strokeWidth: 1.3,
    );
    _field(
      canvas,
      size,
      color: IvoireColors.green.withValues(alpha: 0.11),
      tile: 232,
      shift: Offset(-progress * 420, progress * 260),
      seed: 2,
      strokeWidth: 1.1,
    );
  }

  void _field(
    Canvas canvas,
    Size size, {
    required Color color,
    required double tile,
    required Offset shift,
    required int seed,
    required double strokeWidth,
  }) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: color.a * 0.45);

    final startX = -tile + shift.dx % tile;
    final startY = -tile + shift.dy % tile;

    var row = 0;
    for (double y = startY; y < size.height + tile; y += tile, row++) {
      var col = 0;
      for (double x = startX; x < size.width + tile; x += tile, col++) {
        final center = Offset(x + tile / 2, y + tile / 2);
        _motif(canvas, center, tile * 0.26, (row * 5 + col * 3 + seed) % 6, stroke, fill);
      }
    }
  }

  void _motif(
    Canvas canvas,
    Offset center,
    double r,
    int kind,
    Paint stroke,
    Paint fill,
  ) {
    switch (kind) {
      case 0: // losange (pagne baoulé)
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r, center.dy)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawPath(path, fill);
      case 1: // cercles concentriques (grains de korhogo)
        canvas.drawCircle(center, r * 0.75, stroke);
        canvas.drawCircle(center, r * 0.4, stroke);
        canvas.drawCircle(center, r * 0.14, fill);
      case 2: // chevrons tissés
        final path = Path();
        for (var i = -1; i <= 1; i++) {
          final y = center.dy + i * r * 0.7;
          path.moveTo(center.dx - r, y);
          path.lineTo(center.dx - r * 0.5, y - r * 0.35);
          path.lineTo(center.dx, y);
          path.lineTo(center.dx + r * 0.5, y - r * 0.35);
          path.lineTo(center.dx + r, y);
        }
        canvas.drawPath(path, stroke);
      case 3: // sablier (tambour)
        final path = Path()
          ..moveTo(center.dx - r * 0.7, center.dy - r * 0.7)
          ..lineTo(center.dx + r * 0.7, center.dy - r * 0.7)
          ..lineTo(center.dx, center.dy)
          ..lineTo(center.dx + r * 0.7, center.dy + r * 0.7)
          ..lineTo(center.dx - r * 0.7, center.dy + r * 0.7)
          ..lineTo(center.dx, center.dy)
          ..close();
        canvas.drawPath(path, stroke);
      case 4: // croix de Korhogo
        for (final angle in [0.0, math.pi / 2, math.pi / 4, -math.pi / 4]) {
          final dx = math.cos(angle) * r;
          final dy = math.sin(angle) * r;
          canvas.drawLine(
            Offset(center.dx - dx, center.dy - dy),
            Offset(center.dx + dx, center.dy + dy),
            stroke,
          );
        }
        canvas.drawCircle(center, r * 0.16, fill);
      default: // spirale
        final path = Path();
        for (var i = 0; i < 3; i++) {
          final radius = r * (0.3 + i * 0.3);
          path.addArc(
            Rect.fromCircle(center: center, radius: radius),
            i * 1.1,
            4.4,
          );
        }
        canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
