import 'package:flutter/material.dart';

/// Palette IVOIREPEDIA : neutres chauds, vert et orange du drapeau ivoirien,
/// or et terre cuite pour les tissus. Le vert porte l'action principale,
/// l'orange l'accent éditorial.
abstract final class IvoireColors {
  static const canvas = Color(0xFFF7F4ED);
  static const sand = Color(0xFFF3EDE0);
  static const ivory = Color(0xFFFDFBF6);
  static const paper = Color(0xFFFFFFFF);
  static const subtle = Color(0xFFF5F1E8);
  static const ink = Color(0xFF16211B);
  static const muted = Color(0xFF5B6459);
  static const faint = Color(0xFF828A7E);
  static const line = Color(0xFFD9D3C5);
  static const lineSoft = Color(0xFFEAE5D9);
  static const link = Color(0xFF0D6B3E);
  static const linkVisited = Color(0xFF8A4B2A);
  static const orange = Color(0xFFF07C00);
  static const orangeDeep = Color(0xFFC35F00);
  static const green = Color(0xFF0E7B45);
  static const greenDeep = Color(0xFF0A5C34);
  static const gold = Color(0xFFE7B34A);
  static const terracotta = Color(0xFFB4552C);
  static const highlight = Color(0xFFFFF3E0);

  /// Dégradé de tissu (orange → or → vert) pour les filets d'accent.
  static const List<Color> weave = [orange, gold, green];
}

/// Une seule famille typographique pour tout le site : Inter, embarquée.
const String kFont = 'Inter';

TextStyle titleStyle({
  double size = 20,
  FontWeight weight = FontWeight.w600,
  Color color = IvoireColors.ink,
  double height = 1.25,
  FontStyle style = FontStyle.normal,
  double letterSpacing = -0.2,
}) {
  return TextStyle(
    fontFamily: kFont,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: style,
    letterSpacing: letterSpacing,
  );
}

/// Petite ligne au-dessus d'un titre : domaine + type, en capitales.
TextStyle kickerStyle({Color color = IvoireColors.terracotta}) {
  return TextStyle(
    fontFamily: kFont,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 1.2,
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
    scaffoldBackgroundColor: IvoireColors.canvas,
    fontFamily: kFont,
  );

  return base.copyWith(
    dividerColor: IvoireColors.lineSoft,
    textTheme: base.textTheme.copyWith(
      displaySmall: titleStyle(size: 32, weight: FontWeight.w700, height: 1.15),
      headlineMedium: titleStyle(size: 26, weight: FontWeight.w700),
      headlineSmall: titleStyle(size: 21, weight: FontWeight.w700),
      titleLarge: titleStyle(size: 18, weight: FontWeight.w600),
      titleMedium: titleStyle(size: 16, weight: FontWeight.w600),
      bodyLarge: const TextStyle(
        fontFamily: kFont,
        fontSize: 15.5,
        height: 1.7,
        color: IvoireColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontFamily: kFont,
        fontSize: 14,
        height: 1.65,
        color: IvoireColors.ink,
      ),
      labelLarge: const TextStyle(
        fontFamily: kFont,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: IvoireColors.link,
      ),
    ),
    cardTheme: base.cardTheme.copyWith(
      color: IvoireColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: IvoireColors.lineSoft),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IvoireColors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: kFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: const WidgetStatePropertyAll(Color(0x1FFFFFFF)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IvoireColors.link,
        backgroundColor: IvoireColors.paper,
        side: const BorderSide(color: IvoireColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        textStyle: const TextStyle(
          fontFamily: kFont,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: IvoireColors.link,
        textStyle: const TextStyle(fontFamily: kFont, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IvoireColors.subtle,
      hintStyle: const TextStyle(
        fontFamily: kFont,
        color: IvoireColors.faint,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIconColor: IvoireColors.green,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: IvoireColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: IvoireColors.green, width: 1.6),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: IvoireColors.subtle,
      labelStyle: const TextStyle(
        fontFamily: kFont,
        color: IvoireColors.link,
        fontSize: 13,
      ),
      side: const BorderSide(color: IvoireColors.lineSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: IvoireColors.ink,
      contentTextStyle: TextStyle(fontFamily: kFont, color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
    tooltipTheme: const TooltipThemeData(
      textStyle: TextStyle(fontFamily: kFont, fontSize: 12, color: Colors.white),
      decoration: BoxDecoration(
        color: IvoireColors.ink,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    ),
  );
}
