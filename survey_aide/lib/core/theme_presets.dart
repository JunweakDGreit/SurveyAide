import 'package:flutter/material.dart';

enum ThemePreset {
  classic,
  catppuccin,
  rosePine,
  dracula,
  nord,
  tokyoNight,
}

class PresetColors {
  final ColorScheme scheme;
  final Color scaffoldBg;
  final Color cardColor;
  final Color canvasColor;
  final Color inputFill;
  final Color appBarBg;
  final Color navSelected;
  final Color navUnselected;

  const PresetColors({
    required this.scheme,
    required this.scaffoldBg,
    required this.cardColor,
    required this.canvasColor,
    required this.inputFill,
    required this.appBarBg,
    required this.navSelected,
    required this.navUnselected,
  });
}

extension ThemePresetData on ThemePreset {
  String get label {
    return switch (this) {
      ThemePreset.classic => 'Classic',
      ThemePreset.catppuccin => 'Catppuccin',
      ThemePreset.rosePine => 'Rosé Pine',
      ThemePreset.dracula => 'Dracula',
      ThemePreset.nord => 'Nord',
      ThemePreset.tokyoNight => 'Tokyo Night',
    };
  }

  Color chipColor(bool isDark) {
    return switch (this) {
      ThemePreset.classic => isDark ? const Color(0xFFE8A06B) : const Color(0xFFC4813B),
      ThemePreset.catppuccin => isDark ? const Color(0xFFB4BEFE) : const Color(0xFF1E66F5),
      ThemePreset.rosePine => isDark ? const Color(0xFFC4A7E7) : const Color(0xFFD7827E),
      ThemePreset.dracula => const Color(0xFFBD93F9),
      ThemePreset.nord => const Color(0xFF88C0D0),
      ThemePreset.tokyoNight => isDark ? const Color(0xFF7AA2F7) : const Color(0xFF3760BF),
    };
  }

  PresetColors light() {
    return switch (this) {
      ThemePreset.classic => _classicLight(),
      ThemePreset.catppuccin => _catppuccinLight(),
      ThemePreset.rosePine => _rosePineLight(),
      ThemePreset.dracula => _draculaLight(),
      ThemePreset.nord => _nordLight(),
      ThemePreset.tokyoNight => _tokyoNightLight(),
    };
  }

  PresetColors dark() {
    return switch (this) {
      ThemePreset.classic => _classicDark(),
      ThemePreset.catppuccin => _catppuccinDark(),
      ThemePreset.rosePine => _rosePineDark(),
      ThemePreset.dracula => _draculaDark(),
      ThemePreset.nord => _nordDark(),
      ThemePreset.tokyoNight => _tokyoNightDark(),
    };
  }
}

PresetColors _classicLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFFC4813B),
    secondary: Color(0xFF6D6355),
    surface: Color(0xFFFBF9F2),
    error: Color(0xFFC84A1E),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1E1D),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFE0DACB),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFF2EFE6),
    cardColor: const Color(0xFFFBF9F2),
    canvasColor: const Color(0xFFF2EFE6),
    inputFill: const Color(0xFFFBF9F2),
    appBarBg: const Color(0xFFFBF9F2),
    navSelected: const Color(0xFFC4813B),
    navUnselected: const Color(0xFF6D6355),
  );
}

PresetColors _classicDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFE8A06B),
    secondary: Color(0xFFC4B8A8),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFC84A1E),
    onPrimary: Color(0xFF121212),
    onSecondary: Color(0xFF121212),
    onSurface: Color(0xFFF0EDE8),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF3C3C3C),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    canvasColor: const Color(0xFF121212),
    inputFill: const Color(0xFF1E1E1E),
    appBarBg: const Color(0xFF1E1E1E),
    navSelected: const Color(0xFFE8A06B),
    navUnselected: const Color(0xFFA89F94),
  );
}

PresetColors _catppuccinLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFF1E66F5),
    secondary: Color(0xFF8839EF),
    surface: Color(0xFFEFF1F5),
    error: Color(0xFFD20F39),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF4C4F69),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFDCE0E8),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFE6E9EF),
    cardColor: const Color(0xFFEFF1F5),
    canvasColor: const Color(0xFFE6E9EF),
    inputFill: const Color(0xFFEFF1F5),
    appBarBg: const Color(0xFFEFF1F5),
    navSelected: const Color(0xFF1E66F5),
    navUnselected: const Color(0xFF9CA0B0),
  );
}

PresetColors _catppuccinDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFB4BEFE),
    secondary: Color(0xFFCBA6F7),
    surface: Color(0xFF1E1E2E),
    error: Color(0xFFF38BA8),
    onPrimary: Color(0xFF11111B),
    onSecondary: Color(0xFF11111B),
    onSurface: Color(0xFFCDD6F4),
    onError: Color(0xFF11111B),
    outline: Color(0xFF45475A),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF181825),
    cardColor: const Color(0xFF1E1E2E),
    canvasColor: const Color(0xFF181825),
    inputFill: const Color(0xFF1E1E2E),
    appBarBg: const Color(0xFF1E1E2E),
    navSelected: const Color(0xFFB4BEFE),
    navUnselected: const Color(0xFF6C7086),
  );
}

PresetColors _rosePineLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFFD7827E),
    secondary: Color(0xFF56949F),
    surface: Color(0xFFFFF3E3),
    error: Color(0xFFB4637A),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF575279),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFF2E9DE),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFFAF4ED),
    cardColor: const Color(0xFFFFF3E3),
    canvasColor: const Color(0xFFFAF4ED),
    inputFill: const Color(0xFFFFF3E3),
    appBarBg: const Color(0xFFFFF3E3),
    navSelected: const Color(0xFFD7827E),
    navUnselected: const Color(0xFF9893A5),
  );
}

PresetColors _rosePineDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFC4A7E7),
    secondary: Color(0xFF9CCFD8),
    surface: Color(0xFF1F1D2E),
    error: Color(0xFFEB6F92),
    onPrimary: Color(0xFF191724),
    onSecondary: Color(0xFF191724),
    onSurface: Color(0xFFE0DEF4),
    onError: Color(0xFF191724),
    outline: Color(0xFF26233A),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF191724),
    cardColor: const Color(0xFF1F1D2E),
    canvasColor: const Color(0xFF191724),
    inputFill: const Color(0xFF1F1D2E),
    appBarBg: const Color(0xFF1F1D2E),
    navSelected: const Color(0xFFC4A7E7),
    navUnselected: const Color(0xFF6E6A86),
  );
}

PresetColors _draculaLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFFBD93F9),
    secondary: Color(0xFF6272A4),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFFF5555),
    onPrimary: Color(0xFF282A36),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF282A36),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFE5E5E5),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFF8F8F2),
    cardColor: const Color(0xFFFFFFFF),
    canvasColor: const Color(0xFFF8F8F2),
    inputFill: const Color(0xFFFFFFFF),
    appBarBg: const Color(0xFFFFFFFF),
    navSelected: const Color(0xFFBD93F9),
    navUnselected: const Color(0xFF6272A4),
  );
}

PresetColors _draculaDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFBD93F9),
    secondary: Color(0xFF8BE9FD),
    surface: Color(0xFF44475A),
    error: Color(0xFFFF5555),
    onPrimary: Color(0xFF282A36),
    onSecondary: Color(0xFF282A36),
    onSurface: Color(0xFFF8F8F2),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF555770),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF282A36),
    cardColor: const Color(0xFF44475A),
    canvasColor: const Color(0xFF282A36),
    inputFill: const Color(0xFF44475A),
    appBarBg: const Color(0xFF44475A),
    navSelected: const Color(0xFFBD93F9),
    navUnselected: const Color(0xFF6272A4),
  );
}

PresetColors _nordLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFF5E81AC),
    secondary: Color(0xFF8FBCBB),
    surface: Color(0xFFECEFF4),
    error: Color(0xFFBF616A),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2E3440),
    onSurface: Color(0xFF2E3440),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFD8DEE9),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFE5E9F0),
    cardColor: const Color(0xFFECEFF4),
    canvasColor: const Color(0xFFE5E9F0),
    inputFill: const Color(0xFFECEFF4),
    appBarBg: const Color(0xFFECEFF4),
    navSelected: const Color(0xFF5E81AC),
    navUnselected: const Color(0xFF7C8DA6),
  );
}

PresetColors _nordDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFF88C0D0),
    secondary: Color(0xFF81A1C1),
    surface: Color(0xFF3B4252),
    error: Color(0xFFBF616A),
    onPrimary: Color(0xFF2E3440),
    onSecondary: Color(0xFF2E3440),
    onSurface: Color(0xFFD8DEE9),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF4C566A),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF2E3440),
    cardColor: const Color(0xFF3B4252),
    canvasColor: const Color(0xFF2E3440),
    inputFill: const Color(0xFF3B4252),
    appBarBg: const Color(0xFF3B4252),
    navSelected: const Color(0xFF88C0D0),
    navUnselected: const Color(0xFF6C7A92),
  );
}

PresetColors _tokyoNightLight() {
  const scheme = ColorScheme.light(
    primary: Color(0xFF3760BF),
    secondary: Color(0xFF9C7DD4),
    surface: Color(0xFFCCCCDC),
    error: Color(0xFFF7768E),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1B26),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFB7B9CC),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFFE1E2E7),
    cardColor: const Color(0xFFCCCCDC),
    canvasColor: const Color(0xFFE1E2E7),
    inputFill: const Color(0xFFCCCCDC),
    appBarBg: const Color(0xFFCCCCDC),
    navSelected: const Color(0xFF3760BF),
    navUnselected: const Color(0xFF8B8FA3),
  );
}

PresetColors _tokyoNightDark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFF7AA2F7),
    secondary: Color(0xFFBB9AF7),
    surface: Color(0xFF24283B),
    error: Color(0xFFF7768E),
    onPrimary: Color(0xFF1A1B26),
    onSecondary: Color(0xFF1A1B26),
    onSurface: Color(0xFFA9B1D6),
    onError: Color(0xFF1A1B26),
    outline: Color(0xFF363B54),
  );
  return PresetColors(
    scheme: scheme,
    scaffoldBg: const Color(0xFF1A1B26),
    cardColor: const Color(0xFF24283B),
    canvasColor: const Color(0xFF1A1B26),
    inputFill: const Color(0xFF24283B),
    appBarBg: const Color(0xFF24283B),
    navSelected: const Color(0xFF7AA2F7),
    navUnselected: const Color(0xFF565A78),
  );
}
