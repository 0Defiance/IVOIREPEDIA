import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Couverture de lancement. La même image sert d'écran de chargement HTML
/// (voir `web/index.html`) : le visiteur voit la couverture immédiatement,
/// puis Flutter la reprend le temps que la première page se pose.
const String kCoverAsset = 'assets/images/couverture.webp';

/// Durée minimale d'affichage : le temps du chargement de l'application.
const Duration kCoverHold = Duration(milliseconds: 2200);

const Duration _fadeOut = Duration(milliseconds: 520);

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
    _timer = Timer(widget.hold, _hide);
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

/// La couverture elle-même : l'image, plein cadre, et le filet de la marque.
class CoverSheet extends StatelessWidget {
  const CoverSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: IvoireColors.ivory,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // En portrait, l’image entière doit rester visible : `cover`
          // rognerait le grand titre à gauche. Elle est donc contenue, et la
          // même illustration, très atténuée, remplit les bandes libres.
          final portrait = constraints.maxWidth / constraints.maxHeight < 0.8;

          return Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: [
              if (portrait)
                const DecoratedBox(
                  key: Key('cover-backdrop'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [IvoireColors.sand, IvoireColors.ivory],
                    ),
                    image: DecorationImage(
                      image: AssetImage(kCoverAsset),
                      fit: BoxFit.cover,
                      opacity: 0.22,
                    ),
                  ),
                ),
              Image.asset(
                kCoverAsset,
                key: const Key('cover-image'),
                fit: portrait ? BoxFit.contain : BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: IvoireColors.ivory),
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
    );
  }
}
