import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class SetupState {
  final String name;
  final String region;
  final String firmName;
  final String firmAddress;
  final bool completed;
  const SetupState({
    this.name = '',
    this.region = '13',
    this.firmName = '',
    this.firmAddress = '',
    this.completed = false,
  });

  SetupState copyWith({String? name, String? region, String? firmName, String? firmAddress, bool? completed}) {
    return SetupState(
      name: name ?? this.name,
      region: region ?? this.region,
      firmName: firmName ?? this.firmName,
      firmAddress: firmAddress ?? this.firmAddress,
      completed: completed ?? this.completed,
    );
  }
}

final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  return SetupNotifier();
});

class SetupNotifier extends StateNotifier<SetupState> {
  SetupNotifier() : super(const SetupState()) {
    reloadFromStorage();
  }

  void reloadFromStorage() {
    final completed = StorageService().getBool('gep_setup_completed', def: false);
    if (completed) {
      final name = StorageService().getString('gep_name');
      var region = StorageService().getString(
        'gep_admin_region',
        def: StorageService().getString('gep_region', def: '13'),
      );
      final normalized = _normalizeRegionCode(region);
      if (normalized != region) {
        region = normalized;
        StorageService().setString('gep_admin_region', normalized);
      }
      final firmName = StorageService().getString('gep_firm_name');
      final firmAddress = StorageService().getString('gep_firm_address');
      state = SetupState(
        name: name,
        region: region,
        firmName: firmName,
        firmAddress: firmAddress,
        completed: true,
      );
    }
  }

  String _normalizeRegionCode(String region) {
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
    final normalized = nameToCode[region] ?? region;
    return normalized;
  }

  Future<void> complete(String name, String region, {String firmName = '', String firmAddress = ''}) async {
    await StorageService().setString('gep_name', name);
    await StorageService().setString('gep_admin_region', region);
    await StorageService().setString('gep_firm_name', firmName);
    await StorageService().setString('gep_firm_address', firmAddress);
    await StorageService().setBool('gep_setup_completed', true);
    state = SetupState(
      name: name,
      region: region,
      firmName: firmName,
      firmAddress: firmAddress,
      completed: true,
    );
  }
}
