import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ExpenseEntry {
  final String label;
  final bool isPercent;
  final double value;
  final String base;

  const ExpenseEntry({
    required this.label,
    required this.isPercent,
    required this.value,
    this.base = 'net',
  });

  double computeAmount(double totalIncome, double priorExpenses) {
    if (!isPercent) return value;
    final reference = base == 'total' ? totalIncome : (totalIncome - priorExpenses);
    return (reference * value / 100).clamp(0, double.infinity);
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'isPercent': isPercent,
    'value': value,
    'base': base,
  };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      label: (json['label'] as String?) ?? '',
      isPercent: (json['isPercent'] as bool?) ?? false,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      base: (json['base'] as String?) ?? 'net',
    );
  }

  ExpenseEntry copyWith({String? label, bool? isPercent, double? value, String? base}) {
    return ExpenseEntry(
      label: label ?? this.label,
      isPercent: isPercent ?? this.isPercent,
      value: value ?? this.value,
      base: base ?? this.base,
    );
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, Map<String, List<ExpenseEntry>>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<Map<String, List<ExpenseEntry>>> {
  static const _key = 'gep_expenses';

  ExpenseNotifier() : super({}) {
    loadFromDb();
  }

  void addExpense(String itemUid, ExpenseEntry entry) {
    final updated = Map<String, List<ExpenseEntry>>.from(state);
    updated.putIfAbsent(itemUid, () => []).add(entry);
    state = updated;
    saveToDb();
  }

  void updateExpense(String itemUid, int index, ExpenseEntry entry) {
    final list = List<ExpenseEntry>.from(state[itemUid] ?? []);
    if (index >= 0 && index < list.length) {
      list[index] = entry;
      state = {...state, itemUid: list};
      saveToDb();
    }
  }

  void removeExpense(String itemUid, int index) {
    final list = List<ExpenseEntry>.from(state[itemUid] ?? []);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      if (list.isEmpty) {
        final updated = Map<String, List<ExpenseEntry>>.from(state);
        updated.remove(itemUid);
        state = updated;
      } else {
        state = {...state, itemUid: list};
      }
      saveToDb();
    }
  }

  void loadFromDb() {
    try {
      final raw = StorageService().getString(_key);
      if (raw.isEmpty) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, List<ExpenseEntry>>{};
      for (final entry in decoded.entries) {
        final list = (entry.value as List)
            .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        map[entry.key] = list;
      }
      state = map;
    } catch (_) {
      state = {};
    }
  }

  void saveToDb() {
    final map = <String, dynamic>{};
    for (final entry in state.entries) {
      map[entry.key] = entry.value.map((e) => e.toJson()).toList();
    }
    StorageService().setString(_key, jsonEncode(map));
  }
}
