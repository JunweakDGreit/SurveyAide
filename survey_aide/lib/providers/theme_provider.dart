import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme_presets.dart';
import '../services/storage_service.dart';

class ThemeState {
  final ThemeMode mode;
  final ThemePreset preset;
  const ThemeState({required this.mode, required this.preset});
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState(mode: ThemeMode.system, preset: ThemePreset.classic)) {
    _load();
  }

  void _load() {
    final presetStr = StorageService().getString('gep_theme_preset', def: 'classic');
    final preset = ThemePreset.values.firstWhere(
      (p) => p.name == presetStr,
      orElse: () => ThemePreset.classic,
    );
    final followSystem = StorageService().getBool('gep_follow_system', def: true);
    if (followSystem) {
      state = ThemeState(mode: ThemeMode.system, preset: preset);
    } else {
      final dark = StorageService().getBool('gep_dark', def: false);
      state = ThemeState(mode: dark ? ThemeMode.dark : ThemeMode.light, preset: preset);
    }
  }

  void setThemeMode(ThemeMode mode) {
    StorageService().setBool('gep_follow_system', mode == ThemeMode.system);
    StorageService().setBool('gep_dark', mode == ThemeMode.dark);
    state = ThemeState(mode: mode, preset: state.preset);
  }

  void setPreset(ThemePreset preset) {
    StorageService().setString('gep_theme_preset', preset.name);
    state = ThemeState(mode: state.mode, preset: preset);
  }
}
