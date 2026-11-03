import 'package:flutter/material.dart';

/// Palette IVOIREPEDIA : l'ivoire (le nom, la matière), l'orange et le vert
/// du drapeau ivoirien, un or discret pour les accents éditoriaux.
abstract final class IvoireColors {
  static const ivory = Color(0xFFFDF8EF);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1815);
  static const muted = Color(0xFF6B6555);
  static const orange = Color(0xFFE4630E);
  static const green = Color(0xFF0B6B43);
  static const gold = Color(0xFFC1972B);
  static const sand = Color(0xFFF0E5D2);
  static const line = Color(0xFFE3D8C4);
}

/// Thème Material 3 du site : lecture confortable d'abord (contraste élevé,
/// largeur de ligne limitée côté écrans, échelle typographique sobre).
ThemeData buildIvoireTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IvoireColors.orange,
    brightness: Brightness.light,
  ).copyWith(
    primary: IvoireColors.orange,
    secondary: IvoireColors.green,
    surface: IvoireColors.ivory,
    onSurface: IvoireColors.ink,
    outline: IvoireColors.line,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: IvoireColors.ivory,
    dividerColor: IvoireColors.line,
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
        color: IvoireColors.ink,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
        color: IvoireColors.ink,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: IvoireColors.ink,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: IvoireColors.ink,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: IvoireColors.ink,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.65,
        color: IvoireColors.ink,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        height: 1.55,
        color: IvoireColors.ink,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IvoireColors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IvoireColors.ink,
        side: const BorderSide(color: IvoireColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IvoireColors.paper,
      hintStyle: const TextStyle(color: IvoireColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IvoireColors.orange, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: IvoireColors.sand,
      labelStyle: const TextStyle(color: IvoireColors.ink, fontSize: 13),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
