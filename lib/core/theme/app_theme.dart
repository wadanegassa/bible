import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Refined Color Palette
  static const Color midnight = Color(0xFF08080C); // Deeper, cooler black
  static const Color charcoal = Color(0xFF12121A); // Cool dark gray
  static const Color coolGray = Color(0xFFCBCBCB);
  static const Color softIvory = Color(0xFFFFFFE3);
  static const Color mutedBlue = Color(0xFF386087); // More saturated cool blue

  static ThemeData lightTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: mutedBlue,
        onPrimary: softIvory,
        surface: softIvory,
        onSurface: charcoal,
        secondary: charcoal,
        onSecondary: softIvory,
        outline: coolGray,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: softIvory,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.notoSerif(
          fontSize: fontSize,
          height: 1.6,
          color: charcoal.withValues(alpha: 0.9),
        ),
        bodyMedium: GoogleFonts.notoSerif(
          fontSize: fontSize - 2,
          height: 1.6,
          color: charcoal.withValues(alpha: 0.7),
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: mutedBlue,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: softIvory,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: charcoal,
        ),
        iconTheme: const IconThemeData(color: charcoal),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: coolGray),
        ),
        color: softIvory,
      ),
    );
  }

  static ThemeData darkTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: mutedBlue,
        onPrimary: softIvory,
        surface: midnight,
        onSurface: softIvory,
        secondary: softIvory,
        onSecondary: midnight,
        outline: charcoal,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: midnight,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.notoSerif(
          fontSize: fontSize,
          height: 1.5, // Tighter leading
          color: softIvory.withValues(alpha: 0.95),
        ),
        bodyMedium: GoogleFonts.notoSerif(
          fontSize: fontSize - 2,
          height: 1.6,
          color: softIvory.withValues(alpha: 0.7),
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: softIvory,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: softIvory,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: charcoal,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: softIvory,
        ),
        iconTheme: const IconThemeData(color: softIvory),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: coolGray),
        ),
        color: charcoal,
      ),
    );
  }
}
