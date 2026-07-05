import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomSheetOpenProvider = StateProvider<bool>((ref) => false);
final modalCountProvider = StateProvider<int>((ref) => 0);
final navBarScrollHiddenProvider = StateProvider<bool>((ref) => false);
final pageViewIndexProvider = StateProvider<int>((ref) => 0);
final surveyReturnsVisibleProvider = StateProvider<bool>((ref) => false);
