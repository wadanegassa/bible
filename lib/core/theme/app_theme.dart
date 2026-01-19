import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.light,
        surface: const Color(0xFFFAFAFA),
      ),
      textTheme: GoogleFonts.notoSerifTextTheme().copyWith(
        bodyLarge: GoogleFonts.notoSerif(fontSize: fontSize, height: 1.6),
        bodyMedium: GoogleFonts.notoSerif(fontSize: fontSize - 2, height: 1.6),
        titleLarge: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme(double fontSize) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.notoSerifTextTheme().copyWith(
        bodyLarge: GoogleFonts.notoSerif(fontSize: fontSize, height: 1.6, color: Colors.white70),
        bodyMedium: GoogleFonts.notoSerif(fontSize: fontSize - 2, height: 1.6, color: Colors.white60),
        titleLarge: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
