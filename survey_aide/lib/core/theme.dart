import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: false,
    fontFamily: 'SourceSans3',
    scaffoldBackgroundColor: AppTheme.page,
    colorScheme: const ColorScheme.light(
      primary: AppTheme.accent,
      secondary: AppTheme.steel,
      surface: AppTheme.white,
      error: AppTheme.marker,
    ),
    textTheme: GoogleFonts.sourceSans3TextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.ink,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.ink,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.ink,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.ink,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.ink,
      ),
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.ink,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16, fontWeight: FontWeight.normal, color: AppTheme.ink,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.normal, color: AppTheme.ink,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.steel,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.steel,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTheme.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.rule),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.rule),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.brass, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.marker),
      ),
      labelStyle: const TextStyle(color: AppTheme.steel),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accent,
        textStyle: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerColor: AppTheme.rule,
    cardColor: AppTheme.white,
    canvasColor: AppTheme.page,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppTheme.accent,
      unselectedItemColor: AppTheme.steel,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppTheme.white,
      foregroundColor: AppTheme.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.ink,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  const bg = Color(0xFF121212);
  const surface = Color(0xFF1E1E1E);
  const surfaceElevated = Color(0xFF2A2A2A);
  const border = Color(0xFF3C3C3C);
  const textPrimary = Color(0xFFF0EDE8);
  const textSecondary = Color(0xFFA89F94);
  const muted = Color(0xFF7A7266);
  return ThemeData(
    useMaterial3: false,
    fontFamily: 'SourceSans3',
    scaffoldBackgroundColor: bg,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppTheme.brass,
      secondary: Color(0xFFC4B8A8),
      surface: surface,
      error: AppTheme.marker,
    ),
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
        fontSize: 12, fontWeight: FontWeight.normal, color: muted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.brass, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.marker),
      ),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.brass,
        foregroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.brass,
        foregroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.brass,
        textStyle: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerColor: border,
    cardColor: surface,
    canvasColor: bg,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppTheme.brass,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary,
      ),
    ),
  );
}
