import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand.dart';
import '../theme.dart';
import 'widgets/backdrop.dart';

/// Couverture de lancement. La même signature est servie par l'écran de
/// chargement HTML (`web/logo.png`, voir `web/index.html`) : le visiteur voit
/// la marque immédiatement, puis Flutter la reprend le temps que la première
/// page se pose.
///
/// Aucune image fournie par l'ancienne version n'est réutilisée : la marque,
/// les couleurs et la devise viennent désormais du logo du propriétaire.
const Duration kCoverHold = Duration(milliseconds: 800);

const Duration _fadeOut = Duration(milliseconds: 320);

/// Affiche [child] sous une couverture, retirée en fondu après [hold].
class LaunchCover extends StatefulWidget {
  const LaunchCover({required this.child, this.hold = kCoverHold, super.key});

  final Widget child;
  final Duration hold;

  @override
  State<LaunchCover> createState() => _LaunchCoverState();
}

class _LaunchCoverState extends State<LaunchCover> {
  Timer? _timer;
  bool _visible = true;
  bool _gone = false;

  @override
  void initState() {
    super.initState();

    // Le décompte part de la première image peinte, pas de `initState` : sur
    // une connexion lente, le moteur met plus longtemps que `hold` à afficher
    // quoi que ce soit, et la couverture passait sans avoir été vue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _timer = Timer(widget.hold, _hide);
      }
    });
  }

  void _hide() {
    if (mounted) {
      setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Alignement explicite : la couverture enveloppe l'application depuis la
    // racine, donc au-dessus du `Directionality` fourni par MaterialApp.
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_gone)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: _fadeOut,
              curve: Curves.easeInOut,
              onEnd: () {
                if (mounted && !_visible) {
                  setState(() => _gone = true);
                }
              },
              child: const CoverSheet(),
            ),
          ),
      ],
    );
  }
}

/// La couverture elle-même : le pagne documenté, très pâle, la signature au
/// centre, et le filet orange → or → vert en bas.
class CoverSheet extends StatelessWidget {
  const CoverSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // La couverture enveloppe l'application depuis la racine, au-dessus du
    // `Directionality` de MaterialApp : elle doit fournir le sien.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: IvoireColors.ivory,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // La signature est très large (1 200 × 298) : c'est la largeur
            // qui contraint, sinon elle déborderait d'un téléphone. Elle est
            // contenue dans cette boîte, jamais rognée.
            final boxWidth = math.max(
              0.0,
              math.min(constraints.maxWidth - 56, 760.0),
            );
            final boxHeight = math.min(constraints.maxHeight * 0.34, 240.0);

            return Stack(
              alignment: Alignment.topLeft,
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  key: Key('cover-backdrop'),
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
                    painter: IvorianMotifPainter(progress: 0.18),
                    isComplex: true,
                    willChange: false,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: boxWidth,
                          height: boxHeight,
                          child: Image.asset(
                            kLockupAsset,
                            key: const Key('cover-image'),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            semanticLabel: kTagline,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 64,
                          height: 1,
                          color: IvoireColors.line,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Articles sourcés · Lecture libre · CC BY-SA 4.0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 11.5,
                            height: 1.5,
                            letterSpacing: 0.2,
                            color: IvoireColors.faint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 3,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: IvoireColors.weave),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
