import 'package:flutter/material.dart';

ThemeData buildDemoTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D5AFE),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        fontSize: 11,
      ),
      bodyLarge: TextStyle(fontSize: 14, height: 1.5),
      bodyMedium: TextStyle(fontSize: 13, height: 1.4),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.4,
        color: Color(0xFF1A1A2E),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        elevation: 2,
        shadowColor: const Color(0x443D5AFE),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        side: const BorderSide(color: Color(0xFF3D5AFE), width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF8F9FF),
      surfaceTintColor: const Color(0xFF3D5AFE),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F5FA),
  );
}
