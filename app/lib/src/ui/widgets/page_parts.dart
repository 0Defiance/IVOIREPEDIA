import 'package:flutter/material.dart';

import '../../theme.dart';
import '../display_settings.dart';
import 'ivorian_patterns.dart';

/// Pastille d'ouverture : le domaine de la page, en capitales, dans une puce
/// arrondie. Elle remplace le simple sur-titre et donne un repère constant
/// d'une page à l'autre.
class PageKicker extends StatelessWidget {
  const PageKicker(this.label, {this.color = IvoireColors.greenDeep, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(label, style: kickerStyle(color: color)),
    );
  }
}

/// En-tête de page : pastille, titre, chapeau, puis filet à losanges.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.kicker,
    required this.title,
    this.intro,
    this.color = IvoireColors.greenDeep,
    this.maxWidth = 720,
    super.key,
  });

  final String kicker;
  final String title;
  final String? intro;
  final Color color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageKicker(kicker, color: color),
        const SizedBox(height: 10),
        Text(
          title,
          style: titleStyle(size: 31, weight: FontWeight.w600, color: tone.ink),
        ),
        if (intro != null) ...[
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              intro!,
              style: TextStyle(fontSize: 14.5, height: 1.65, color: tone.muted),
            ),
          ),
        ],
        const SizedBox(height: 14),
        const DiamondRule(),
      ],
    );
  }
}

/// Filet de section : trois losanges puis un trait, comme les motifs du fond.
class DiamondRule extends StatelessWidget {
  const DiamondRule({this.color = IvoireColors.terracotta, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Row(
      children: [
        MotifDivider(color: color),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: tone.lineSoft)),
      ],
    );
  }
}

/// Titre de section : libellé, compteur éventuel, puis filet à losanges.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    this.count,
    this.trailing,
    this.color = IvoireColors.terracotta,
    super.key,
  });

  final String title;
  final int? count;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle(size: 18, weight: FontWeight.w600, color: tone.ink),
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: TextStyle(fontSize: 12, color: tone.faint),
              ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 7),
        DiamondRule(color: color),
      ],
    );
  }
}

/// Carte arrondie de la maison : papier clair, filet fin, ombre douce, liseré
/// d'accent optionnel. Toutes les pages l'utilisent pour rester cohérentes.
class MotifCard extends StatelessWidget {
  const MotifCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.accent,
    this.color,
    this.radius = 14,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.from(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? tone.paper,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: tone.lineSoft),
        boxShadow: [
          BoxShadow(
            color: tone.ink.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (accent != null) Container(height: 3, color: accent),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
