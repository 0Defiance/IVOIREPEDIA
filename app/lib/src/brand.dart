import 'package:flutter/material.dart';

import 'theme.dart';

/// Emblème fourni par le propriétaire du site : un « I » de bois vert, dont
/// l'éléphant porte une oreille orange et une oreille verte — les deux
/// couleurs du drapeau, réunies sur l'ivoire.
const String kEmblemAsset = 'assets/images/marque.webp';

/// Le mot-symbole seul, dans la typographie de la marque.
const String kWordmarkAsset = 'assets/images/logo-mot.webp';

/// La signature complète : emblème, nom et devise. Réservée aux grands
/// formats (couverture, pied de page), car la devise y devient illisible en
/// dessous de 120 px de haut.
const String kLockupAsset = 'assets/images/logo.webp';

/// Devise officielle du site, reprise dans l'onglet du navigateur.
const String kTagline = 'Ivoirepedia, l’encyclopédie libre de la Côte d’Ivoire';

/// L'emblème seul, à sa taille d'usage (en-tête, encarts, fond de page).
class IvoireMark extends StatelessWidget {
  const IvoireMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kEmblemAsset,
      key: const ValueKey('brand-emblem'),
      height: size,
      width: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}

/// Marque d'en-tête : l'emblème, puis le mot-symbole et la devise.
///
/// Les deux images sont détourées : elles se posent sur le papier du thème
/// (ivoire, sépia ou nuit) sans rectangle blanc autour.
class IvoireLogo extends StatelessWidget {
  const IvoireLogo({
    super.key,
    this.size = 44,
    this.compact = false,
    this.tagline = true,
  });

  /// Hauteur de l'emblème ; le mot-symbole et la devise suivent son échelle.
  final double size;

  /// Variante resserrée : la devise reste sur une seule ligne courte.
  final bool compact;

  /// Sur un téléphone, la devise allonge la marque sans apporter d'information
  /// nouvelle : le nom seul suffit, et l'en-tête garde ses commandes.
  final bool tagline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IvoireMark(size: size),
        SizedBox(width: size * 0.22),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              kWordmarkAsset,
              key: const ValueKey('brand-wordmark'),
              height: size * 0.46,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              excludeFromSemantics: true,
            ),
            if (tagline) ...[
              SizedBox(height: size * 0.06),
              Text(
                compact ? 'L’encyclopédie libre de la Côte d’Ivoire' : kTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: size * 0.235,
                  height: 1.2,
                  letterSpacing: 0.05,
                  color: IvoireColors.muted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
