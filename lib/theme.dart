import 'package:flutter/material.dart';

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
}
