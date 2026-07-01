import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFE67E22);
  static const Color secondary = Color(0xFF2C3E50);
  static const Color tertiary = Color(0xFF7D9D85);
  static const Color neutral = Color(0xFFF9F4EE);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: tertiary,
        onTertiary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: neutral,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: neutral,
      fontFamily: 'Inter', // Default font family
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Literata', color: secondary),
        displayMedium: TextStyle(fontFamily: 'Literata', color: secondary),
        displaySmall: TextStyle(fontFamily: 'Literata', color: secondary),
        headlineLarge: TextStyle(fontFamily: 'Literata', color: secondary),
        headlineMedium: TextStyle(fontFamily: 'Literata', color: secondary),
        headlineSmall: TextStyle(fontFamily: 'Literata', color: secondary),
        titleLarge: TextStyle(fontFamily: 'Literata', color: secondary),
        titleMedium: TextStyle(fontFamily: 'Literata', color: secondary),
        titleSmall: TextStyle(fontFamily: 'Literata', color: secondary),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.black87),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.black87),
        bodySmall: TextStyle(fontFamily: 'Inter', color: Colors.black87),
        labelLarge: TextStyle(fontFamily: 'Inter', color: Colors.black54),
        labelMedium: TextStyle(fontFamily: 'Inter', color: Colors.black54),
        labelSmall: TextStyle(fontFamily: 'Inter', color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
  static const Color darkNeutral = Color(0xFF1E1916);
  static const Color darkSurface = Color(0xFF2C221E);
  static const Color darkText = Color(0xFFECE6DD);
  static const Color darkTextMuted = Color(0xFF9C8F84);

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFFF3D2C1),
        onSecondary: Color(0xFF2C221E),
        tertiary: tertiary,
        onTertiary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkNeutral,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Literata', color: darkText),
        displayMedium: TextStyle(fontFamily: 'Literata', color: darkText),
        displaySmall: TextStyle(fontFamily: 'Literata', color: darkText),
        headlineLarge: TextStyle(fontFamily: 'Literata', color: darkText),
        headlineMedium: TextStyle(fontFamily: 'Literata', color: darkText),
        headlineSmall: TextStyle(fontFamily: 'Literata', color: darkText),
        titleLarge: TextStyle(fontFamily: 'Literata', color: darkText),
        titleMedium: TextStyle(fontFamily: 'Literata', color: darkText),
        titleSmall: TextStyle(fontFamily: 'Literata', color: darkText),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: darkText),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: darkText),
        bodySmall: TextStyle(fontFamily: 'Inter', color: darkText),
        labelLarge: TextStyle(fontFamily: 'Inter', color: darkTextMuted),
        labelMedium: TextStyle(fontFamily: 'Inter', color: darkTextMuted),
        labelSmall: TextStyle(fontFamily: 'Inter', color: darkTextMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
      ),
      useMaterial3: true,
    );
  }
}
