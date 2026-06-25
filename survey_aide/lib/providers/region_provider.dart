import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';

final regionProvider = StateNotifierProvider<RegionNotifier, Region>((ref) {
  return RegionNotifier();
});

class RegionNotifier extends StateNotifier<Region> {
  RegionNotifier() : super(Region.caraga) {
    _load();
  }

  void _load() {
    final saved = StorageService().getString('gep_region', def: 'caraga');
    state = Region.fromString(saved);
  }

  void setRegion(Region region) {
    state = region;
    StorageService().setString('gep_region', region.name);
  }
}
