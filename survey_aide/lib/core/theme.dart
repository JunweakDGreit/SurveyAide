import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_presets.dart';

ThemeData buildLightTheme([ThemePreset preset = ThemePreset.classic]) {
  final c = preset.light();
  final scheme = c.scheme;
  final textPrimary = scheme.onSurface;
  final textSecondary = scheme.onSurface.withValues(alpha: 0.6);

  return ThemeData(
    useMaterial3: false,
    fontFamily: 'SourceSans3',
    scaffoldBackgroundColor: c.scaffoldBg,
    colorScheme: scheme,
    textTheme: GoogleFonts.sourceSans3TextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.normal, color: textPrimary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      labelStyle: TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerColor: scheme.outline,
    cardColor: c.cardColor,
    canvasColor: c.canvasColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: c.navSelected,
      unselectedItemColor: c.navUnselected,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.appBarBg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary,
      ),
    ),
  );
}

ThemeData buildDarkTheme([ThemePreset preset = ThemePreset.classic]) {
  final c = preset.dark();
  final scheme = c.scheme;
  final textPrimary = scheme.onSurface;
  final textSecondary = scheme.onSurface.withValues(alpha: 0.6);

  return ThemeData(
    useMaterial3: false,
    fontFamily: 'SourceSans3',
    scaffoldBackgroundColor: c.scaffoldBg,
    brightness: Brightness.dark,
    colorScheme: scheme,
    textTheme: GoogleFonts.sourceSans3TextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.normal, color: textPrimary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      labelStyle: TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerColor: scheme.outline,
    cardColor: c.cardColor,
    canvasColor: c.canvasColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: c.navSelected,
      unselectedItemColor: c.navUnselected,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.appBarBg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary,
      ),
    ),
  );
}
