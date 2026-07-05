import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import 'app_database_provider.dart';
import 'region_provider.dart';

final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getCategories();
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final regionCode = ref.watch(selectedRegionCodeProvider);
  return db.getServices(regionCode);
});

final serviceRatesProvider = FutureProvider.family<Map<String, double>, String>((ref, code) async {
  final db = ref.watch(appDatabaseProvider);
  final regionCode = ref.watch(selectedRegionCodeProvider);
  return db.getServiceRates(code, regionCode);
});

final rateLabelsProvider = FutureProvider.family<Map<String, String>, String>((ref, code) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getRateLabels(code);
});

final regionRatesProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getRegionsWithRates();
});
