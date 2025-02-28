import 'package:flutter/material.dart';

class AppTheme {
  static final TextTheme _textTheme = TextTheme(
    displayLarge: const TextStyle(fontFamily: 'Product Sans'),
    displayMedium: const TextStyle(fontFamily: 'Product Sans'),
    displaySmall: const TextStyle(fontFamily: 'Product Sans'),
    headlineLarge: const TextStyle(fontFamily: 'Product Sans'),
    headlineMedium: const TextStyle(fontFamily: 'Product Sans'),
    headlineSmall: const TextStyle(fontFamily: 'Product Sans'),
    titleLarge: const TextStyle(fontFamily: 'Product Sans'),
    titleMedium: const TextStyle(fontFamily: 'Product Sans'),
    titleSmall: const TextStyle(fontFamily: 'Product Sans'),
    bodyLarge: const TextStyle(fontFamily: 'Product Sans'),
    bodyMedium: const TextStyle(fontFamily: 'Product Sans'),
    bodySmall: const TextStyle(fontFamily: 'Product Sans'),
    labelLarge: const TextStyle(fontFamily: 'Product Sans'),
    labelMedium: const TextStyle(fontFamily: 'Product Sans'),
    labelSmall: const TextStyle(fontFamily: 'Product Sans'),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 