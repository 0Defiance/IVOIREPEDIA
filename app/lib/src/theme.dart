import 'package:flutter/material.dart';

/// Palette d'encyclopédie : fond blanc, encre presque noire, liens bleus,
/// filets gris — et l'orange ivoirien réservé à la marque et à l'onglet actif.
abstract final class IvoireColors {
  static const ivory = Color(0xFFFFFFFF);
  static const paper = Color(0xFFFFFFFF);
  static const subtle = Color(0xFFF8F9FA);
  static const ink = Color(0xFF202122);
  static const muted = Color(0xFF54595D);
  static const faint = Color(0xFF72777D);
  static const line = Color(0xFFA2A9B1);
  static const lineSoft = Color(0xFFC8CCD1);
  static const link = Color(0xFF3366CC);
  static const linkVisited = Color(0xFF795CB2);
  static const orange = Color(0xFFD9640F);
  static const green = Color(0xFF14866D);
  static const highlight = Color(0xFFFEF6E7);
}

/// Familles de polices : serif pour les titres (comme une encyclopédie
/// imprimée), sans-serif pour le corps de texte.
const String kSerif = 'Georgia';
const List<String> kSerifFallback = ['Times New Roman', 'serif'];
const String kSans = 'Helvetica Neue';

TextStyle serifStyle({
  double size = 20,
  FontWeight weight = FontWeight.w400,
  Color color = IvoireColors.ink,
  double height = 1.3,
  FontStyle style = FontStyle.normal,
}) {
  return TextStyle(
    fontFamily: kSerif,
    fontFamilyFallback: kSerifFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: style,
  );
}

ThemeData buildIvoireTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IvoireColors.link,
    brightness: Brightness.light,
  ).copyWith(
    primary: IvoireColors.link,
    secondary: IvoireColors.orange,
    surface: IvoireColors.paper,
    onSurface: IvoireColors.ink,
    outline: IvoireColors.line,
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: IvoireColors.paper,
    fontFamily: kSans,
  );

  return base.copyWith(
    dividerColor: IvoireColors.lineSoft,
    textTheme: base.textTheme.copyWith(
      // Les titres d'article sont en serif : c'est le repère visuel principal.
      displaySmall: serifStyle(size: 30, height: 1.25),
      headlineMedium: serifStyle(size: 26),
      headlineSmall: serifStyle(size: 22, weight: FontWeight.w600),
      titleLarge: serifStyle(size: 19, weight: FontWeight.w600),
      titleMedium: serifStyle(size: 17, weight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 15, height: 1.65, color: IvoireColors.ink),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.6, color: IvoireColors.ink),
      labelLarge: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: IvoireColors.link,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IvoireColors.link,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IvoireColors.ink,
        side: const BorderSide(color: IvoireColors.lineSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: IvoireColors.link,
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IvoireColors.paper,
      hintStyle: const TextStyle(color: IvoireColors.faint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: IvoireColors.link, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: IvoireColors.subtle,
      labelStyle: const TextStyle(color: IvoireColors.link, fontSize: 13),
      side: const BorderSide(color: IvoireColors.lineSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: IvoireColors.ink,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
