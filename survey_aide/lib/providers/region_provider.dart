import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final selectedRegionCodeProvider = StateProvider<String>((ref) {
  final saved = StorageService().getString('gep_admin_region', def: '13');
  return _normalize(saved);
});

class RegionCodeNotifier extends StateNotifier<String> {
  RegionCodeNotifier() : super('13') {
    _load();
  }

  void _load() {
    final saved = StorageService().getString('gep_admin_region', def: '13');
    state = _normalize(saved);
  }

  void setRegionCode(String code) {
    state = code;
    StorageService().setString('gep_admin_region', code);
  }
}

String _normalize(String region) {
  const nameToCode = {
    'Region I': '01', 'Region II': '02', 'Region III': '03',
    'Region IV-A': '04A', 'Region IV-B': '04B',
    'Region V': '05', 'Region VI': '06', 'Region VII': '07',
    'Region VIII': '08', 'Region IX': '09', 'Region X': '10',
    'Region XI': '11', 'Region XII': '12', 'Region XIII': '13',
    'NCR': 'NCR', 'CAR': 'CAR', 'BARMM': 'BARMM',
    'CARAGA': '13', 'Ilocos Region': '01', 'Cagayan Valley': '02',
    'Central Luzon': '03', 'CALABARZON': '04A', 'MIMAROPA': '04B',
    'Bicol Region': '05', 'Western Visayas': '06', 'Central Visayas': '07',
    'Eastern Visayas': '08', 'Zamboanga Peninsula': '09',
    'Northern Mindanao': '10', 'Davao Region': '11',
    'SOCCSKSARGEN': '12', 'Caraga': '13',
    'National Capital Region': 'NCR',
    'Cordillera Administrative Region': 'CAR',
    'Bangsamoro Autonomous Region in Muslim Mindanao': 'BARMM',
  };
  return nameToCode[region] ?? region;
}
