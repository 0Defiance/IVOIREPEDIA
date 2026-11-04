import 'package:flutter/material.dart';

import '../../theme.dart';
import 'ivorian_patterns.dart';

/// Lien texte réactif : soulignement et changement de teinte au survol,
/// curseur main, effet d'appui.
class HoverLink extends StatefulWidget {
  const HoverLink({
    required this.label,
    required this.onTap,
    this.style,
    this.color = IvoireColors.link,
    this.hoverColor = IvoireColors.green,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle? style;
  final Color color;
  final Color hoverColor;

  @override
  State<HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<HoverLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? const TextStyle(fontSize: 13.5);
    final color = _hovered ? widget.hoverColor : widget.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: base.copyWith(
            color: color,
            decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: color,
            decorationThickness: 1.4,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

/// Surface réactive : se soulève légèrement au survol, bord et ombre animés.
class HoverSurface extends StatefulWidget {
  const HoverSurface({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.radius = 10,
    this.background = IvoireColors.paper,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color background;

  @override
  State<HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<HoverSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: _hovered ? IvoireColors.green.withValues(alpha: 0.55) : IvoireColors.lineSoft,
            ),
            boxShadow: [
              BoxShadow(
                color: IvoireColors.ink.withValues(alpha: _hovered ? 0.10 : 0.03),
                blurRadius: _hovered ? 18 : 6,
                offset: Offset(0, _hovered ? 6 : 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Bouton qui s'enfonce légèrement à l'appui (retour tactile immédiat).
class Pressable extends StatefulWidget {
  const Pressable({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Bloc de chargement pulsé : remplace le rond qui tourne, plus lisible.
class Skeleton extends StatefulWidget {
  const Skeleton({
    this.width = double.infinity,
    this.height = 14,
    this.radius = 6,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;

    if (ivoireMotionAllowed(context)) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(IvoireColors.lineSoft, IvoireColors.subtle, _controller.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Paragraphe factice (trois lignes) pour les états de chargement.
class SkeletonParagraph extends StatelessWidget {
  const SkeletonParagraph({this.lines = 3, super.key});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Skeleton(height: 12, width: i == lines - 1 ? 240 : double.infinity),
          ),
      ],
    );
  }
}

/// Compteur animé (les chiffres montent une fois à l'affichage).
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    required this.label,
    this.suffix = '',
    super.key,
  });

  final int value;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${current.round()}$suffix',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: IvoireColors.greenDeep,
              ),
            ),
            TextSpan(
              text: '  $label',
              style: const TextStyle(fontSize: 12.5, color: IvoireColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
