import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryDark = Color(0xFF020617);
  static const Color primaryLight = Color(0xFF334155);

  static const Color accent = Color(0xFF3B82F6); // Blue 500
  static const Color accentDark = Color(0xFF2563EB); // Blue 600

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF0EA5E9); // Sky 500

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;

  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        error: error,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimaryLight),
        bodyMedium: TextStyle(color: textPrimaryLight),
        labelLarge: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primary.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: textSecondaryLight, fontWeight: FontWeight.normal, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textSecondaryLight);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondaryLight),
        hintStyle: const TextStyle(color: textSecondaryLight),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: accent,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        error: error,
      ),
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimaryDark),
        bodyMedium: TextStyle(color: textPrimaryDark),
        labelLarge: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryLight.withValues(alpha: 0.5),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: textSecondaryDark, fontWeight: FontWeight.normal, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: textSecondaryDark);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: primaryDark,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondaryDark),
        hintStyle: const TextStyle(color: textSecondaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
