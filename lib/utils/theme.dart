import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0D1B2A);
  static const Color accent = Color(0xFF7B61FF);
  
  static const Color cardText = Color(0xFF1E2A38);
  static const Color cardVoice = Color(0xFF0D2E2E);
  static const Color cardScanned = Color(0xFF0D1E38);
  static const Color cardCapsule = Color(0xFF1A0D2E);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      background: background,
      surface: cardText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter', // Fallback to sans-serif if not added
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: accent,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      color: cardText,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
