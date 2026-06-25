import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import 'region_provider.dart';

final servicesProvider = FutureProvider<RegionData>((ref) async {
  final region = ref.watch(regionProvider);
  return loadServices(region.displayName);
});
