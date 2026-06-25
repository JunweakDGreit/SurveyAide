import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/reference_database.dart';

final referenceDatabaseProvider = Provider<ReferenceDatabase>((ref) {
  final db = ReferenceDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final regionListProvider = FutureProvider<List<AdminRegion>>((ref) {
  final db = ref.watch(referenceDatabaseProvider);
  return db.select(db.regions).get();
});

final provinceListProvider = FutureProvider.family<List<AdminProvince>, String>((ref, regionCode) {
  final db = ref.watch(referenceDatabaseProvider);
  return (db.select(db.provinces)..where((t) => t.regionCode.equals(regionCode))).get();
});

final municipalityListProvider = FutureProvider.family<List<AdminMunicipality>, String>((ref, provinceCode) {
  final db = ref.watch(referenceDatabaseProvider);
  return (db.select(db.municipalities)..where((t) => t.provinceCode.equals(provinceCode))).get();
});

final barangayListProvider = FutureProvider.family<List<AdminBarangay>, String>((ref, municipalityCode) {
  final db = ref.watch(referenceDatabaseProvider);
  return (db.select(db.barangays)..where((t) => t.municipalityCode.equals(municipalityCode))).get();
});
