import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final gridModeProvider = StateNotifierProvider<GridModeNotifier, bool>((ref) {
  return GridModeNotifier();
});

class GridModeNotifier extends StateNotifier<bool> {
  GridModeNotifier() : super(true) {
    state = StorageService().getBool('gep_grid_mode', def: true);
  }

  void toggle() {
    state = !state;
    StorageService().setBool('gep_grid_mode', state);
  }

  void set(bool value) {
    state = value;
    StorageService().setBool('gep_grid_mode', state);
  }
}
