import 'package:flutter/material.dart';

/// Palette IVOIREPEDIA : ivoire chaud, terre, orange et vert du drapeau,
/// or des tissus. Le bleu encyclopédique est remplacé par un vert forêt
/// pour les liens, l'orange portant l'accent éditorial.
abstract final class IvoireColors {
  static const sand = Color(0xFFF7EEDC);
  static const ivory = Color(0xFFFFFBF2);
  static const paper = Color(0xFFFFFDF7);
  static const subtle = Color(0xFFF3E8D4);
  static const ink = Color(0xFF241F19);
  static const muted = Color(0xFF5E5444);
  static const faint = Color(0xFF847A68);
  static const line = Color(0xFFC9B695);
  static const lineSoft = Color(0xFFE4D7BF);
  static const link = Color(0xFF0B5B34);
  static const linkVisited = Color(0xFF7A3E1D);
  static const orange = Color(0xFFE2661B);
  static const orangeDeep = Color(0xFFB8480E);
  static const green = Color(0xFF0B7A42);
  static const gold = Color(0xFFE5B13C);
  static const terracotta = Color(0xFFA9502C);
  static const highlight = Color(0xFFFFEFD6);

  /// Dégradé de tissu (orange → or → vert) pour les filets d'accent.
  static const List<Color> weave = [orange, gold, green];
}

/// Familles de polices : serif pour les titres, sans-serif pour le corps.
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

/// Petite ligne au-dessus d'un titre : domaine + type, en capitales orange.
TextStyle kickerStyle({Color color = IvoireColors.terracotta}) {
  return TextStyle(
    fontSize: 11,
    height: 1.2,
    letterSpacing: 1.1,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

ThemeData buildIvoireTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IvoireColors.green,
    brightness: Brightness.light,
  ).copyWith(
    primary: IvoireColors.green,
    secondary: IvoireColors.orange,
    surface: IvoireColors.paper,
    onSurface: IvoireColors.ink,
    outline: IvoireColors.line,
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: IvoireColors.sand,
    fontFamily: kSans,
  );

  return base.copyWith(
    dividerColor: IvoireColors.lineSoft,
    textTheme: base.textTheme.copyWith(
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
        backgroundColor: IvoireColors.orangeDeep,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IvoireColors.link,
        backgroundColor: IvoireColors.ivory,
        side: const BorderSide(color: IvoireColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
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
      fillColor: IvoireColors.ivory,
      hintStyle: const TextStyle(color: IvoireColors.faint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      prefixIconColor: IvoireColors.terracotta,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: IvoireColors.orange, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: IvoireColors.subtle,
      labelStyle: const TextStyle(color: IvoireColors.link, fontSize: 13),
      side: const BorderSide(color: IvoireColors.lineSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: IvoireColors.ink,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
