import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final rateProvider = StateNotifierProvider<RateNotifier, Map<String, Map<String, double>>>((ref) {
  return RateNotifier();
});

class RateNotifier extends StateNotifier<Map<String, Map<String, double>>> {
  RateNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final overrides = await StorageService().getRateOverrides();
    final map = <String, Map<String, double>>{};
    for (final o in overrides) {
      map.putIfAbsent(o.code, () => {})[o.key] = o.value;
    }
    state = map;
  }

  double getRate(Map<String, double> baseRates, String code, String key) {
    return state[code]?[key] ?? baseRates[key] ?? 0;
  }

  Future<void> setRate(String code, String key, double value) async {
    final updated = Map<String, Map<String, double>>.from(state);
    updated.putIfAbsent(code, () => {});
    updated[code] = Map<String, double>.from(updated[code]!);
    updated[code]![key] = value;
    state = updated;
    await StorageService().setRateOverride(code, key, value);
  }

  Future<void> resetRate(String code, String key) async {
    if (state[code] == null) return;
    final updated = Map<String, Map<String, double>>.from(state);
    updated[code] = Map<String, double>.from(updated[code]!);
    updated[code]!.remove(key);
    if (updated[code]!.isEmpty) updated.remove(code);
    state = updated;
    await StorageService().deleteRateOverride(code, key);
  }

  Future<void> resetAll() async {
    state = {};
    await StorageService().deleteAllRateOverrides();
  }
}
