import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class Installment {
  final String label;
  final double pct;
  final DateTime? dueDate;
  final bool paid;

  const Installment({
    required this.label,
    required this.pct,
    this.dueDate,
    this.paid = false,
  });

  Installment copyWith({
    String? label,
    double? pct,
    DateTime? dueDate,
    bool? paid,
  }) {
    return Installment(
      label: label ?? this.label,
      pct: pct ?? this.pct,
      dueDate: dueDate ?? this.dueDate,
      paid: paid ?? this.paid,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'pct': pct,
    'dueDate': dueDate?.toIso8601String(),
    'paid': paid,
  };

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
    label: json['label'] as String,
    pct: (json['pct'] as num).toDouble(),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    paid: json['paid'] as bool? ?? false,
  );
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, Map<String, List<Installment>>>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<Map<String, List<Installment>>> {
  PaymentNotifier() : super({}) {
    loadFromDb();
  }

  static const _storageKey = 'gep_payments';

  void addInstallment(String itemUid, Installment inst) {
    final updated = Map<String, List<Installment>>.from(state);
    updated[itemUid] = [...(updated[itemUid] ?? []), inst];
    state = updated;
    saveToDb();
  }

  void updateInstallment(String itemUid, int index, Installment inst) {
    final updated = Map<String, List<Installment>>.from(state);
    final list = <Installment>[...(updated[itemUid] ?? [])];
    if (index < list.length) {
      list[index] = inst;
      updated[itemUid] = list;
      state = updated;
      saveToDb();
    }
  }

  void removeInstallment(String itemUid, int index) {
    final updated = Map<String, List<Installment>>.from(state);
    final list = <Installment>[...(updated[itemUid] ?? [])];
    if (index < list.length) {
      list.removeAt(index);
      if (list.isEmpty) {
        updated.remove(itemUid);
      } else {
        updated[itemUid] = list;
      }
      state = updated;
      saveToDb();
    }
  }

  Future<void> loadFromDb() async {
    final jsonStr = StorageService().getString(_storageKey);
    if (jsonStr.isEmpty) {
      state = {};
      return;
    }
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      state = map.map((k, v) => MapEntry(
        k,
        (v as List).map((e) => Installment.fromJson(e as Map<String, dynamic>)).toList(),
      ));
    } catch (_) {
      state = {};
    }
  }

  Future<void> saveToDb() async {
    final jsonStr = json.encode(state.map((k, v) => MapEntry(
      k,
      v.map((e) => e.toJson()).toList(),
    )));
    await StorageService().setString(_storageKey, jsonStr);
  }
}
