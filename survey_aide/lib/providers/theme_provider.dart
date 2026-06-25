import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    final followSystem = StorageService().getBool('gep_follow_system', def: true);
    if (followSystem) {
      state = ThemeMode.system;
    } else {
      final dark = StorageService().getBool('gep_dark', def: false);
      state = dark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void setDark(bool dark) {
    StorageService().setBool('gep_dark', dark);
    StorageService().setBool('gep_follow_system', false);
    state = dark ? ThemeMode.dark : ThemeMode.light;
  }

  void setFollowSystem(bool follow) {
    StorageService().setBool('gep_follow_system', follow);
    if (follow) {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }
}
