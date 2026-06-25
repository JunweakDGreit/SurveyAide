import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';

class QuoteEntry {
  final String uid;
  final String code;
  final String name;
  final double total;
  final List<TallyLine> lines;
  final String client;
  final String location;
  final DateTime createdAt;

  QuoteEntry({
    required this.uid,
    required this.code,
    required this.name,
    required this.total,
    required this.lines,
    required this.client,
    this.location = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  QuoteEntry copyWith({
    String? uid,
    String? code,
    String? name,
    double? total,
    List<TallyLine>? lines,
    String? client,
    String? location,
    DateTime? createdAt,
  }) {
    return QuoteEntry(
      uid: uid ?? this.uid,
      code: code ?? this.code,
      name: name ?? this.name,
      total: total ?? this.total,
      lines: lines ?? this.lines,
      client: client ?? this.client,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'code': code,
    'name': name,
    'total': total,
    'lines': lines.map((l) => {'label': l.label, 'amount': l.amount}).toList(),
    'client': client,
    'location': location,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuoteEntry.fromJson(Map<String, dynamic> json) => QuoteEntry(
    uid: json['uid'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    total: (json['total'] as num).toDouble(),
    lines: (json['lines'] as List).map((l) => TallyLine(
      label: l['label'] as String,
      amount: (l['amount'] as num).toDouble(),
    )).toList(),
    client: json['client'] as String,
    location: json['location'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}

final quoteProvider = StateNotifierProvider<QuoteNotifier, List<QuoteEntry>>((ref) {
  return QuoteNotifier();
});

class QuoteNotifier extends StateNotifier<List<QuoteEntry>> {
  QuoteNotifier() : super([]) {
    loadFromDb();
  }

  static const _storageKey = 'gep_quote_items';

  void addItem(QuoteEntry item) {
    state = [...state, item];
    saveToDb();
  }

  void removeItem(String uid) {
    state = state.where((e) => e.uid != uid).toList();
    saveToDb();
  }

  void updateItem(String uid, QuoteEntry updated) {
    state = state.map((e) => e.uid == uid ? updated : e).toList();
    saveToDb();
  }

  void clearAll() {
    state = [];
    saveToDb();
  }

  Future<void> loadFromDb() async {
    final jsonStr = StorageService().getString(_storageKey);
    if (jsonStr.isEmpty) {
      state = [];
      return;
    }
    try {
      final list = json.decode(jsonStr) as List;
      state = list.map((e) => QuoteEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> saveToDb() async {
    final jsonStr = json.encode(state.map((e) => e.toJson()).toList());
    await StorageService().setString(_storageKey, jsonStr);
  }

  static String generateUid() => const Uuid().v4();
}
