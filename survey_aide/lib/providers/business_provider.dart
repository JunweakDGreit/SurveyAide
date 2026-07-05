import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class BusinessInfo {
  final String company;
  final String address;
  final String phone;
  final String email;
  final String tin;
  final String prcLicense;
  final String prcDate;
  final String ptr;
  final String ptrDate;

  const BusinessInfo({
    this.company = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.tin = '',
    this.prcLicense = '',
    this.prcDate = '',
    this.ptr = '',
    this.ptrDate = '',
  });

  BusinessInfo copyWith({
    String? company,
    String? address,
    String? phone,
    String? email,
    String? tin,
    String? prcLicense,
    String? prcDate,
    String? ptr,
    String? ptrDate,
  }) {
    return BusinessInfo(
      company: company ?? this.company,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      tin: tin ?? this.tin,
      prcLicense: prcLicense ?? this.prcLicense,
      prcDate: prcDate ?? this.prcDate,
      ptr: ptr ?? this.ptr,
      ptrDate: ptrDate ?? this.ptrDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'company': company,
    'address': address,
    'phone': phone,
    'email': email,
    'tin': tin,
    'prcLicense': prcLicense,
    'prcDate': prcDate,
    'ptr': ptr,
    'ptrDate': ptrDate,
  };

  factory BusinessInfo.fromJson(Map<String, dynamic> json) => BusinessInfo(
    company: json['company'] as String? ?? '',
    address: json['address'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    tin: json['tin'] as String? ?? '',
    prcLicense: json['prcLicense'] as String? ?? '',
    prcDate: json['prcDate'] as String? ?? '',
    ptr: json['ptr'] as String? ?? '',
    ptrDate: json['ptrDate'] as String? ?? '',
  );

  static BusinessInfo fromStorage() {
    final json = StorageService().getString('gep_business_info');
    if (json.isNotEmpty) {
      try {
        return BusinessInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const BusinessInfo();
  }
}

final businessInfoProvider = StateNotifierProvider<BusinessNotifier, BusinessInfo>((ref) {
  return BusinessNotifier();
});

class BusinessNotifier extends StateNotifier<BusinessInfo> {
  BusinessNotifier() : super(const BusinessInfo()) {
    _load();
  }

  static const _key = 'gep_business_info';

  void _load() {
    final json = StorageService().getString(_key);
    if (json.isNotEmpty) {
      try {
        state = BusinessInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  void save(BusinessInfo info) {
    state = info;
    StorageService().setString(_key, jsonEncode(info.toJson()));
  }
}
