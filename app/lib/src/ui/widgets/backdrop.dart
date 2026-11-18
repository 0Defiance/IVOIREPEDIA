import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../brand.dart';
import '../../theme.dart';

/// Interrupteur global du mouvement décoratif (fond, bande tissée). Les tests
/// le désactivent pour que `pumpAndSettle` ne tourne pas sur une animation
/// infinie.
bool ivoireMotionEnabled = true;

/// Met en pause les animations décoratives si la plateforme le demande
/// (préférence système « réduire les animations »).
bool ivoireMotionAllowed(BuildContext context) {
  if (!ivoireMotionEnabled) {
    return false;
  }

  return !MediaQuery.disableAnimationsOf(context);
}

/// Largeur d'une bande de pagne : 10 à 15 cm sur un métier traditionnel, une
/// bande par couture (UNESCO, savoir-faire du tissage du pagne, ICH 01949).
const double kBandWidth = 104;

/// Hauteur d'une maille du motif, dans le rythme des bandes.
const double kCellHeight = 132;

/// Fond du site : un pagne tissé ivoirien, peint en code.
///
/// Le décor n'est pas inventé : il reprend le répertoire documenté du textile
/// ivoirien.
///
/// - La structure vient du **pagne tissé** : des bandes de 10 à 15 cm cousues
///   bord à bord, avec leur couture visible (UNESCO, savoir-faire du tissage
///   du pagne, ICH 01949).
/// - Les **losanges** sont ceux du pagne baoulé, dont le centre est une
///   réserve d'indigo (dossier IG « pagne baoulé », OAPI 2023).
/// - Les **frises à degrés** et le **zigzag du léopard** viennent du Fila,
///   hérités du répertoire de Korhogo.
/// - Les **arêtes de poisson** sont un motif classique du textile de Korhogo.
///
/// Le pagne dérive lentement (80 s), s'incline en légère parallaxe et les
/// mailles proches du pointeur s'éclaircissent : le fond réagit au passage de
/// la souris ou du doigt, sans jamais passer devant le texte (opacité de 5 à
/// 13 %).
class IvorianBackdrop extends StatefulWidget {
  const IvorianBackdrop({required this.child, super.key});

  final Widget child;

  @override
  State<IvorianBackdrop> createState() => _IvorianBackdropState();
}

class _IvorianBackdropState extends State<IvorianBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 80),
  );

  /// Position du pointeur dans le repère du fond. Une `ValueNotifier` évite de
  /// reconstruire tout le site à chaque déplacement : seul le peintre écoute.
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final motion = ivoireMotionAllowed(context);

    if (motion && !_running) {
      _drift.repeat();
      _running = true;
    } else if (!motion && _running) {
      _drift.stop();
      _running = false;
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    _pointer.dispose();
    super.dispose();
  }

  void _track(PointerEvent event) => _pointer.value = event.localPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: _track,
      onPointerDown: _track,
      onPointerMove: _track,
      child: MouseRegion(
        onExit: (_) => _pointer.value = null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    IvoireColors.sand,
                    IvoireColors.ivory,
                    IvoireColors.canvas,
                  ],
                ),
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                painter: _WashPainter(),
                isComplex: true,
                willChange: false,
              ),
            ),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([_drift, _pointer]),
                builder: (context, _) => CustomPaint(
                  painter: IvorianMotifPainter(
                    progress: _drift.value,
                    pointer: _pointer.value,
                  ),
                  isComplex: true,
                  willChange: true,
                ),
              ),
            ),
            // L'emblème veille au fond, très pâle et en léger mouvement : la
            // marque habite le site sans jamais passer devant le texte.
            Positioned(
              right: -46,
              bottom: -38,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _drift,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      math.sin(_drift.value * 2 * math.pi) * 8,
                    ),
                    child: child,
                  ),
                  child: const Opacity(
                    opacity: 0.05,
                    child: Image(
                      image: AssetImage(kEmblemAsset),
                      key: ValueKey('backdrop-emblem'),
                      width: 400,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// Le pagne lui-même. Public : les tests lisent le pointeur et la dérive qu'il
/// reçoit pour vérifier que le fond réagit.
class IvorianMotifPainter extends CustomPainter {
  IvorianMotifPainter({required this.progress, this.pointer});

  /// Avancement de la dérive, de 0 à 1 sur un cycle complet.
  final double progress;

  /// Pointeur en coordonnées locales, `null` quand la souris a quitté le site.
  final Offset? pointer;

  /// Opacité d'une maille au repos puis sous le pointeur.
  static const double baseAlpha = 0.055;
  static const double pointerAlpha = 0.13;
  static const double highlightRadius = 260;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final drift = progress * kBandWidth;
    final parallax = _parallax(size);

    _weave(canvas, size, drift, parallax);

    // Chaque maille reçoit un motif du répertoire, choisi de façon stable
    // (même colonne, même rangée, même motif à chaque rendu).
    var column = 0;
    for (double x = drift % kBandWidth - kBandWidth;
        x < size.width + kBandWidth;
        x += kBandWidth, column++) {
      var row = math.max(0, ((drift * 0.15) / kCellHeight).floor() - 1);
      for (double y = drift * 0.15 - row * kCellHeight - kCellHeight;
          y < size.height + kCellHeight;
          y += kCellHeight, row++) {
        final center = Offset(
          x + kBandWidth / 2 + parallax.dx,
          y + kCellHeight / 2 + parallax.dy,
        );
        final alpha = alphaAt(center);
        final motif = (column * 5 + row * 3) % 4;

        if (motif == 0) {
          _diamonds(canvas, center, IvoireColors.greenDeep, alpha);
        } else if (motif == 1) {
          _fret(canvas, center, IvoireColors.terracotta, alpha);
        } else if (motif == 2) {
          _leopard(canvas, center, IvoireColors.orange, alpha);
        } else {
          _fishBones(canvas, center, IvoireColors.green, alpha);
        }
      }
    }
  }

  /// Les coutures des bandes et la trame du tissage : ce qui distingue un
  /// pagne cousu d'un motif posé à plat.
  void _weave(Canvas canvas, Size size, double drift, Offset parallax) {
    final seam = Paint()
      ..color = IvoireColors.ink.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    final weft = Paint()
      ..color = IvoireColors.ink.withValues(alpha: 0.014)
      ..strokeWidth = 0.8;

    for (double x = drift % kBandWidth - kBandWidth;
        x < size.width + kBandWidth;
        x += kBandWidth) {
      final seamX = x + parallax.dx;
      canvas.drawLine(Offset(seamX, 0), Offset(seamX, size.height), seam);
    }

    for (double y = parallax.dy % 7; y < size.height; y += 7) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), weft);
    }
  }

  /// Décalage de parallaxe : quelques pixels, dans le sens opposé au pointeur.
  Offset _parallax(Size size) {
    final p = pointer;

    if (p == null) {
      return Offset.zero;
    }

    final dx = (p.dx / math.max(size.width, 1) - 0.5) * -12;
    final dy = (p.dy / math.max(size.height, 1) - 0.5) * -7;

    return Offset(dx, dy);
  }

  /// Une maille proche du pointeur s'éclaircit, sans jamais dépasser [pointerAlpha].
  double alphaAt(Offset center) {
    final p = pointer;

    if (p == null) {
      return baseAlpha;
    }

    final distance = (center - p).distance;

    if (distance >= highlightRadius) {
      return baseAlpha;
    }

    final t = 1 - distance / highlightRadius;

    return baseAlpha + (pointerAlpha - baseAlpha) * t * t;
  }

  Paint _stroke(Color color, double alpha, [double width = 2.3]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color.withValues(alpha: alpha);

  /// Losange baoulé : deux losanges imbriqués, centre en réserve d'indigo.
  void _diamonds(Canvas canvas, Offset center, Color color, double alpha) {
    final paint = _stroke(color, alpha);

    for (var i = 0; i < 2; i++) {
      final r = 34.0 - i * 13;

      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r * 0.72, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r * 0.72, center.dy)
          ..close(),
        paint,
      );
    }

    canvas.drawRect(
      Rect.fromCenter(center: center, width: 7, height: 7),
      Paint()..color = color.withValues(alpha: alpha * 1.15),
    );
  }

  /// Frise à degrés : la ligne crénelée des bordures de pagne.
  void _fret(Canvas canvas, Offset center, Color color, double alpha) {
    final paint = _stroke(color, alpha, 2.1);
    final path = Path();
    final left = center.dx - 42;
    final base = center.dy + 20;
    final top = center.dy - 4;
    const step = 12.0;

    path.moveTo(left, base);

    for (var i = 0; i < 7; i++) {
      final x = left + i * step;
      path
        ..lineTo(x, top)
        ..lineTo(x + step / 2, top)
        ..lineTo(x + step / 2, base)
        ..lineTo(x + step, base);
    }

    canvas.drawPath(path, paint);
  }

  /// Zigzag du léopard, double filet comme sur une bande tissée.
  void _leopard(Canvas canvas, Offset center, Color color, double alpha) {
    const width = 76.0;
    const height = 15.0;
    const segments = 4;
    const step = width / segments;

    for (var line = 0; line < 2; line++) {
      final y = center.dy + (line - 0.5) * 13;
      final path = Path()..moveTo(center.dx - width / 2, y + height);

      for (var i = 0; i < segments; i++) {
        path
          ..lineTo(center.dx - width / 2 + step * (i + 0.5), y - height)
          ..lineTo(center.dx - width / 2 + step * (i + 1), y + height);
      }

      canvas.drawPath(path, _stroke(color, alpha * (line == 0 ? 0.9 : 0.6), 2));
    }
  }

  /// Arêtes de poisson : chevrons empilés du textile de Korhogo.
  void _fishBones(Canvas canvas, Offset center, Color color, double alpha) {
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * 13.0;
      final inset = i.abs() * 3.0;

      canvas.drawPath(
        Path()
          ..moveTo(center.dx - 22 + inset, y - 8)
          ..lineTo(center.dx + 26 - inset * 0.4, y)
          ..lineTo(center.dx - 22 + inset, y + 8),
        _stroke(color, alpha * (1 - i.abs() * 0.12), 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant IvorianMotifPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.pointer != pointer;
}

/// Lavis de couleur et grain de papier, sous le pagne.
class _WashPainter extends CustomPainter {
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
  bool shouldRepaint(covariant _WashPainter oldDelegate) => false;
}
