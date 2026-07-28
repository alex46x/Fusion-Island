import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeModeOption {
  glass,
  dark,
  amoled,
  materialYou,
  rgbCyberpunk,
}

class AppTheme {
  // Brand Color Tokens
  static const Color primaryCyan = Color(0xFF00F2FE);
  static const Color primaryBlue = Color(0xFF4FACFE);
  static const Color accentPurple = Color(0xFF7F00FF);
  static const Color accentNeonGreen = Color(0xFF00FF87);
  
  // Dark & AMOLED Surface Tokens
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);

  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledCard = Color(0xFF121212);

  // Glassmorphism Overlay Colors
  static const Color glassBackground = Color(0x33000000);
  static const Color glassBorder = Color(0x40FFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryBlue,
        tertiary: accentPurple,
        surface: darkSurface,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x1FAFFFFF), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get amoledTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: amoledBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryBlue,
        tertiary: accentNeonGreen,
        surface: amoledSurface,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: amoledCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33333333), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: amoledBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
