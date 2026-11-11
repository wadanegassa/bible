import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paper-and-ink palette with a single ink-blue accent.
///
/// Semantic roles map onto Material 3 colour slots so every widget can read
/// them from [ColorScheme]:
/// - `surface`                 → cards and sheets
/// - `surfaceContainerLow`     → quiet fills (inputs, segmented controls)
/// - `onSurfaceVariant`        → secondary text
/// - `outlineVariant`          → hairlines and dividers
/// - `primaryContainer`        → soft accent fill (selected rows, chips)
class AppTheme {
  AppTheme._();

  // Light
  static const Color paper = Color(0xFFFAF7F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color paperDeep = Color(0xFFF1ECE4);
  static const Color ink = Color(0xFF1E1C19);
  static const Color inkMuted = Color(0xFF6F685F);
  static const Color hairline = Color(0xFFE6DFD4);
  static const Color accent = Color(0xFF2D5877);
  static const Color accentSoft = Color(0xFFE4ECF2);

  // Dark
  static const Color night = Color(0xFF121110);
  static const Color nightCard = Color(0xFF1B1A18);
  static const Color nightDeep = Color(0xFF242220);
  static const Color moon = Color(0xFFECE7DF);
  static const Color moonMuted = Color(0xFF9D968C);
  static const Color nightLine = Color(0xFF2F2C28);
  static const Color accentNight = Color(0xFF93B6D2);
  static const Color accentNightSoft = Color(0xFF1F2B35);

  static const double radius = 14;

  static List<String> get _serifFallback => [
        GoogleFonts.notoSerifEthiopic().fontFamily!,
      ];

  static List<String> get _sansFallback => [
        GoogleFonts.notoSansEthiopic().fontFamily!,
      ];

  /// Reading serif used for Scripture, chapter headings and page titles.
  static TextStyle serif({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    Color? color,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return GoogleFonts.literata(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _serifFallback);
  }

  static TextStyle sans({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _sansFallback);
  }

  static ThemeData lightTheme(double fontSize) => _build(
        brightness: Brightness.light,
        fontSize: fontSize,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: accent,
          onPrimary: Colors.white,
          primaryContainer: accentSoft,
          onPrimaryContainer: accent,
          secondary: ink,
          onSecondary: paper,
          surface: card,
          onSurface: ink,
          onSurfaceVariant: inkMuted,
          surfaceContainerLowest: card,
          surfaceContainerLow: paperDeep,
          surfaceContainer: paperDeep,
          surfaceContainerHigh: Color(0xFFEAE4DA),
          outline: Color(0xFFCFC6B8),
          outlineVariant: hairline,
          error: Color(0xFFA23B2A),
          onError: Colors.white,
        ),
        background: paper,
      );

  static ThemeData darkTheme(double fontSize) => _build(
        brightness: Brightness.dark,
        fontSize: fontSize,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: accentNight,
          onPrimary: night,
          primaryContainer: accentNightSoft,
          onPrimaryContainer: accentNight,
          secondary: moon,
          onSecondary: night,
          surface: nightCard,
          onSurface: moon,
          onSurfaceVariant: moonMuted,
          surfaceContainerLowest: night,
          surfaceContainerLow: nightDeep,
          surfaceContainer: nightDeep,
          surfaceContainerHigh: Color(0xFF2C2A27),
          outline: Color(0xFF4A4640),
          outlineVariant: nightLine,
          error: Color(0xFFE08A7A),
          onError: night,
        ),
        background: night,
      );

  static ThemeData _build({
    required Brightness brightness,
    required double fontSize,
    required ColorScheme scheme,
    required Color background,
  }) {
    final ink = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;

    final textTheme = TextTheme(
      displaySmall: serif(fontSize: 30, fontWeight: FontWeight.w500, height: 1.15, color: ink, letterSpacing: -0.4),
      headlineMedium: serif(fontSize: 26, fontWeight: FontWeight.w500, height: 1.2, color: ink, letterSpacing: -0.3),
      headlineSmall: serif(fontSize: 22, fontWeight: FontWeight.w500, height: 1.25, color: ink),
      titleLarge: sans(fontSize: 18, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.2),
      titleMedium: sans(fontSize: 16, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.1),
      titleSmall: sans(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      bodyLarge: serif(fontSize: fontSize, height: 1.7, color: ink),
      bodyMedium: sans(fontSize: 15, height: 1.45, color: ink),
      bodySmall: sans(fontSize: 13, height: 1.4, color: muted),
      labelLarge: sans(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      labelMedium: sans(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
      labelSmall: sans(fontSize: 11, fontWeight: FontWeight.w500, color: muted, letterSpacing: 0.2),
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: ink, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: ink, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape.copyWith(side: BorderSide(color: scheme.outlineVariant)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        width: 304,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: muted),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: sans(fontSize: 14, fontWeight: FontWeight.w500, color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          foregroundColor: ink,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
        checkmarkColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHigh,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.08),
        trackHeight: 3,
        showValueIndicator: ShowValueIndicator.never,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: muted,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
