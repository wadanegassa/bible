import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Royal Color Palette
  static const Color onyxBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color royalGold = Color(0xFFD4AF37);
  static const Color metallicGold = Color(0xFFFFD700);
  static const Color deepGold = Color(0xFF996515);
  static const Color surfaceBlack = Color(0xFF121212);

  static ThemeData lightTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalGold,
        brightness: Brightness.light,
        surface: pureWhite,
        onSurface: onyxBlack,
        primary: deepGold,
        onPrimary: pureWhite,
        secondary: onyxBlack,
        onSecondary: pureWhite,
      ),
      scaffoldBackgroundColor: pureWhite,
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        bodyLarge: GoogleFonts.notoSerif(
          fontSize: fontSize,
          height: 1.8,
          color: onyxBlack.withValues(alpha: 0.9),
          letterSpacing: 0.2,
        ),
        bodyMedium: GoogleFonts.notoSerif(
          fontSize: fontSize - 2,
          height: 1.8,
          color: onyxBlack.withValues(alpha: 0.7),
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w900,
          color: deepGold,
          letterSpacing: -0.5,
          fontSize: 24,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w800,
          color: onyxBlack,
          letterSpacing: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: onyxBlack,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: pureWhite,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: deepGold.withValues(alpha: 0.1),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: onyxBlack,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: onyxBlack),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: deepGold.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: royalGold.withValues(alpha: 0.2), width: 1.5),
        ),
        color: pureWhite,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: onyxBlack,
          selectedForegroundColor: royalGold,
          side: const BorderSide(color: onyxBlack),
        ),
      ),
    );
  }

  static ThemeData darkTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalGold,
        brightness: Brightness.dark,
        surface: onyxBlack,
        onSurface: pureWhite,
        primary: metallicGold,
        onPrimary: onyxBlack,
        secondary: royalGold,
        onSecondary: onyxBlack,
      ),
      scaffoldBackgroundColor: onyxBlack,
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        bodyLarge: GoogleFonts.notoSerif(
          fontSize: fontSize,
          height: 1.8,
          color: pureWhite.withValues(alpha: 0.9),
          letterSpacing: 0.2,
        ),
        bodyMedium: GoogleFonts.notoSerif(
          fontSize: fontSize - 2,
          height: 1.8,
          color: pureWhite.withValues(alpha: 0.7),
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w900,
          color: royalGold,
          letterSpacing: -0.5,
          fontSize: 24,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w800,
          color: royalGold,
          letterSpacing: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: royalGold,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: onyxBlack,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: royalGold.withValues(alpha: 0.2),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: royalGold,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: royalGold),
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: onyxBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: royalGold.withValues(alpha: 0.3), width: 1.5),
        ),
        color: surfaceBlack,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: royalGold,
          selectedForegroundColor: onyxBlack,
          side: const BorderSide(color: royalGold),
        ),
      ),
    );
  }
}
