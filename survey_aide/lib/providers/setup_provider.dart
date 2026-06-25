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
    this.region = 'CARAGA',
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
    _load();
  }

  void _load() {
    final completed = StorageService().getBool('gep_setup_completed', def: false);
    if (completed) {
      final name = StorageService().getString('gep_name');
      final region = StorageService().getString(
        'gep_admin_region',
        def: StorageService().getString('gep_region', def: 'CARAGA'),
      );
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
