import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class Appointment {
  final String title;
  final DateTime date;
  final String note;
  final String? itemUid;
  final String? serviceLabel;

  const Appointment({
    required this.title,
    required this.date,
    this.note = '',
    this.itemUid,
    this.serviceLabel,
  });

  Appointment copyWith({
    String? title,
    DateTime? date,
    String? note,
    String? itemUid,
    String? serviceLabel,
  }) {
    return Appointment(
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      itemUid: itemUid ?? this.itemUid,
      serviceLabel: serviceLabel ?? this.serviceLabel,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'note': note,
    if (itemUid != null) 'itemUid': itemUid,
    if (serviceLabel != null) 'serviceLabel': serviceLabel,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    title: (json['title'] as String?) ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    note: (json['note'] as String?) ?? '',
    itemUid: (json['itemUid'] as String?),
    serviceLabel: (json['serviceLabel'] as String?),
  );
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier();
});

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]) {
    loadFromDb();
  }

  static const _storageKey = 'gep_appointments';

  List<Appointment> appointmentsForItem(String itemUid) {
    return state.where((a) => a.itemUid == itemUid).toList();
  }

  void add(Appointment a) {
    state = [...state, a];
    saveToDb();
  }

  void update(int index, Appointment a) {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated[index] = a;
    state = updated;
    saveToDb();
  }

  void remove(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
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
      state = list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> saveToDb() async {
    final jsonStr = json.encode(state.map((e) => e.toJson()).toList());
    await StorageService().setString(_storageKey, jsonStr);
  }
}
