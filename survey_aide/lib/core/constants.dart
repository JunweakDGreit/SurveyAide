import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui' as ui;

class AppTheme {
  static const Color brass = Color(0xFFE8A06B);
  static const Color accent = Color(0xFFC4813B);
  static const Color marker = Color(0xFFC84A1E);
  static const Color ink = Color(0xFF1A1E1D);
  static const Color steel = Color(0xFF6D6355);
  static const Color page = Color(0xFFF2EFE6);
  static const Color white = Color(0xFFFBF9F2);
  static const Color rule = Color(0xFFE0DACB);
  static const Color muted = Color(0xFF6D6355);
}

enum Region {
  caraga('CARAGA'),
  accra('ACCRA');

  final String displayName;
  const Region(this.displayName);

  static Region fromString(String s) {
    return Region.values.firstWhere(
      (r) => r.name == s.toLowerCase() || r.displayName == s.toUpperCase(),
      orElse: () => Region.caraga,
    );
  }
}

class ServiceCategory {
  final String key;
  final String label;
  final Color color;
  final String iconName;
  const ServiceCategory({
    required this.key,
    required this.label,
    required this.color,
    this.iconName = '',
  });
}

class ServiceFieldOption {
  final String value;
  final String label;
  const ServiceFieldOption({required this.value, required this.label});
}

class ServiceField {
  final String key;
  final String label;
  final String type;
  final double step;
  final double min;
  final double def;
  final List<ServiceFieldOption> options;
  const ServiceField({
    required this.key,
    required this.label,
    this.type = 'number',
    this.step = 0.0001,
    this.min = 0,
    this.def = 0,
    this.options = const [],
  });
}

class TallyLine {
  final String label;
  final double amount;
  const TallyLine({required this.label, required this.amount});
}

class Service {
  final String code;
  final String name;
  final String cat;
  final String group;
  final String? note;
  final String? shortDescription;
  final List<ServiceField> fields;
  final Map<String, double> rates;
  const Service({
    required this.code,
    required this.name,
    required this.cat,
    this.group = '',
    this.note,
    this.shortDescription,
    required this.fields,
    required this.rates,
  });
}

class RegionData {
  final List<ServiceCategory> categories;
  final List<Service> services;
  const RegionData({required this.categories, required this.services});
}

BoxDecoration glassDecoration({
  double opacity = 0.35,
  double blur = 10,
  double radius = 12,
  Color background = AppTheme.white,
  bool dark = false,
}) {
  final bg = dark ? const Color(0xFF2A2A2A) : background;
  return BoxDecoration(
    color: bg.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.08),
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.25 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.15 : 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

InputDecoration glassInputDecoration(BuildContext context, {
  String? labelText,
  String? hintText,
  String? prefixText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? suffixText,
  bool isDense = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? const Color(0xFF2A2A2A) : AppTheme.white;
  return InputDecoration(
    filled: true,
    fillColor: bg.withValues(alpha: isDark ? 0.20 : 0.25),
    isDense: isDense,
    contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelText: labelText,
    hintText: hintText,
    prefixText: prefixText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixText: suffixText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
        width: 0.5,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
        width: 0.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.brass, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.marker, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppTheme.marker, width: 1.5),
    ),
  );
}

Widget glassBackdrop(BuildContext context, {required Widget child, double radius = 0}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ClipRect(
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: glassDecoration(
          opacity: isDark ? 0.30 : 0.40,
          blur: 12,
          radius: radius,
          dark: isDark,
        ),
        child: child,
      ),
    ),
  );
}

Future<RegionData> loadServices(String regionCode) async {
  final jsonString = await rootBundle.loadString('assets/services.json');
  final data = json.decode(jsonString) as Map<String, dynamic>;
  final regions = data['regions'] as Map<String, dynamic>;
  final regionData = regions[regionCode] as Map<String, dynamic>;
  final catsList = regionData['categories'] as List;
  final srvsList = regionData['services'] as List;

  final categories = catsList.map((c) {
    final cm = c as Map<String, dynamic>;
    return ServiceCategory(
      key: cm['key'] as String,
      label: cm['label'] as String,
      color: Color(int.parse((cm['color'] as String).replaceFirst('#', '0xFF'))),
      iconName: cm['icon'] as String? ?? '',
    );
  }).toList();

  final services = <Service>[];
  for (final s in srvsList) {
    final sm = s as Map<String, dynamic>;
    services.add(Service(
      code: sm['code'] as String,
      name: sm['name'] as String,
      cat: sm['cat'] as String,
      group: sm['group'] as String? ?? '',
      note: sm['note'] as String?,
      shortDescription: sm['shortDescription'] as String?,
      fields: (sm['fields'] as List?)?.map((f) {
        final fm = f as Map<String, dynamic>;
        final rawOpts = fm['options'] as List?;
        return ServiceField(
          key: fm['key'] as String,
          label: fm['label'] as String,
          type: fm['type'] as String? ?? 'number',
          step: (fm['step'] as num?)?.toDouble() ?? 0.0001,
          min: (fm['min'] as num?)?.toDouble() ?? 0,
          def: fm['def'] is num ? (fm['def'] as num).toDouble() : 0,
          options: rawOpts?.map((o) {
            final om = o as Map<String, dynamic>;
            return ServiceFieldOption(
              value: om['value'] as String,
              label: om['label'] as String,
            );
          }).toList() ?? [],
        );
      }).toList() ?? [],
      rates: (sm['rates'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ) ?? {},
    ));
  }

  return RegionData(categories: categories, services: services);
}

const Map<String, Map<String, double>> defaultRates = {
  'A.1': {'base': 16000, 'excessHaPerHa': 10000, 'marksEach': 2000},
  'A.2': {'base': 25000, 'excessHaPerHa': 10000, 'distPerKm': 5000},
  'A.3': {'base': 30000, 'extraLot': 10000, 'excessHaPerHa': 5000, 'marksEach': 2000},
  'A.4': {'tier1': 15000, 'tier2': 9000, 'tier3': 8500, 'tier4': 8000, 'tier5': 7500, 'tier6': 7000},
  'A.5': {'base': 30000, 'extraLot': 10000, 'excessHa': 5000, 'marksEach': 2000},
  'A.6': {'base': 20000, 'excessHa': 5000},
  'B.1a': {'tier1': 30000, 'tier2': 25000, 'tier3': 20000, 'tier4': 15000, 'tier5': 10000},
  'B.1b': {'tier1': 40000, 'tier2': 35000, 'tier3': 30000, 'tier4': 25000, 'tier5': 20000},
  'B.2': {'base': 60000, 'excessHa': 30000},
  'B.3a': {'perKm': 40000},
  'B.3b': {'perSection': 600},
  'B.3c': {'perKm': 4000},
  'B.4a': {'flat': 40000, 'hilly': 60000},
  'B.4b': {'flat': 30000, 'hilly': 50000},
  'B.4c': {'flat': 40000, 'hilly': 60000},
  'B.4d': {'prelimFlat': 80000, 'prelimHilly': 120000, 'finalPerKm': 13000},
  'B.4e': {'perKm': 25000},
  'B.5': {'perKm': 180000, 'excessLot': 10000, 'untitledLot': 10000},
  'B.6': {'perSite': 40000},
  'B.7a': {'perKm': 20000},
  'B.7b': {'basePerBldg': 20000, 'excessPer500sqm': 5000},
  'B.8a': {'base': 250000, 'excessHa': 2000},
  'B.8b': {'grid100': 9500, 'grid50': 5000, 'grid20': 3500, 'drillPlan': 30000},
  'B.8c': {'base': 30000, 'excessHa': 10000},
  'B.8d': {'base': 30000, 'excessHa': 10000},
  'C.1': {'lotPlan': 2500, 'vicinityMap': 3500},
  'C.2': {'perQty': 30000},
  'C.3': {'basePerClass': 20000, 'excessHa': 10000},
  'C.4': {'perScheme': 25000},
  'C.5': {'perHa': 2000, 'minHa': 100},
  'D.1': {'perAppear': 5000},
  'D.2': {'perQty': 1500},
  'D.3': {'perArea': 1500},
  'D.4': {'totalStationPerDay': 1500, 'gpsPerDay': 2500, 'echoPerDay': 20000, 'levelPerDay': 1000, 'uavPerDay': 30000},
  'D.5': {'withATP': 220, 'withoutATP': 180},
};

const Map<String, Map<String, String>> rateLabels = {
  'A.1': {'base': 'Base fee (\u22641 ha)', 'excessHaPerHa': 'Per addl. hectare', 'marksEach': 'Per intermediate mark'},
  'A.2': {'base': 'Base fee (\u22641 ha)', 'excessHaPerHa': 'Per addl. hectare', 'distPerKm': 'Per km from reference'},
  'A.3': {'base': 'Base fee (first 2 lots)', 'extraLot': 'Per addl. lot', 'excessHaPerHa': 'Per addl. hectare', 'marksEach': 'Per intermediate mark'},
  'A.4': {'tier1': 'Tier 1 (\u226410 lots)', 'tier2': 'Tier 2 (\u226420 lots)', 'tier3': 'Tier 3 (\u226430 lots)', 'tier4': 'Tier 4 (\u226440 lots)', 'tier5': 'Tier 5 (\u226450 lots)', 'tier6': 'Tier 6 (>50 lots)'},
  'A.5': {'base': 'Base fee (first 2 lots)', 'extraLot': 'Per addl. mother lot', 'excessHa': 'Per addl. hectare', 'marksEach': 'Per intermediate mark'},
  'A.6': {'base': 'Base fee (first ha)', 'excessHa': 'Per addl. hectare'},
  'B.1a': {'tier1': 'Tier 1 (\u22641 ha)', 'tier2': 'Tier 2 (\u226410 ha)', 'tier3': 'Tier 3 (\u226430 ha)', 'tier4': 'Tier 4 (\u226450 ha)', 'tier5': 'Tier 5 (>50 ha)'},
  'B.1b': {'tier1': 'Tier 1 (\u22641 ha)', 'tier2': 'Tier 2 (\u226410 ha)', 'tier3': 'Tier 3 (\u226430 ha)', 'tier4': 'Tier 4 (\u226450 ha)', 'tier5': 'Tier 5 (>50 ha)'},
  'B.2': {'base': 'Base fee (first ha)', 'excessHa': 'Per addl. hectare'},
  'B.3a': {'perKm': 'Per kilometer'},
  'B.3b': {'perSection': 'Per section'},
  'B.3c': {'perKm': 'Per kilometer'},
  'B.4a': {'flat': 'Nearly flat (/km)', 'hilly': 'Hilly/mountainous (/km)'},
  'B.4b': {'flat': 'Nearly flat (/km)', 'hilly': 'Hilly/mountainous (/km)'},
  'B.4c': {'flat': 'Nearly flat (/km)', 'hilly': 'Hilly/mountainous (/km)'},
  'B.4d': {'prelimFlat': 'Prelim \u2014 flat (/km)', 'prelimHilly': 'Prelim \u2014 hilly (/km)', 'finalPerKm': 'Final survey (/km)'},
  'B.4e': {'perKm': 'Per kilometer'},
  'B.5': {'perKm': 'Per kilometer', 'excessLot': 'Per lot beyond included', 'untitledLot': 'Per untitled mother lot'},
  'B.6': {'perSite': 'Per site'},
  'B.7a': {'perKm': 'Per kilometer'},
  'B.7b': {'basePerBldg': 'Base per building (\u22641,000 sqm)', 'excessPer500sqm': 'Per 500 sqm excess'},
  'B.8a': {'base': 'Base fee (first 81 ha)', 'excessHa': 'Per addl. hectare'},
  'B.8b': {'grid100': '100m\u00D7100m per point', 'grid50': '50m\u00D750m per point', 'grid20': '20m\u00D720m per point', 'drillPlan': 'Drilling plan'},
  'B.8c': {'base': 'Base fee (first ha)', 'excessHa': 'Per addl. hectare'},
  'B.8d': {'base': 'Base fee (first ha)', 'excessHa': 'Per addl. hectare'},
  'C.1': {'lotPlan': 'Lot plan only', 'vicinityMap': 'Lot plan w/ vicinity map'},
  'C.2': {'perQty': 'Per copy'},
  'C.3': {'basePerClass': 'Base per classification (\u22641 ha)', 'excessHa': 'Per addl. ha per class'},
  'C.4': {'perScheme': 'Per scheme'},
  'C.5': {'perHa': 'Per hectare', 'minHa': 'Minimum billable ha'},
  'D.1': {'perAppear': 'Per appearance'},
  'D.2': {'perQty': 'Per consultation'},
  'D.3': {'perArea': 'Per inspection'},
  'D.4': {'totalStationPerDay': 'Total Station / day', 'gpsPerDay': 'GPS Receiver / day', 'echoPerDay': 'Echo Sounder (w/ op) / day', 'levelPerDay': 'Auto Digital Level / day', 'uavPerDay': 'UAV (w/ op) / day'},
  'D.5': {'withATP': 'With ATP', 'withoutATP': 'Without ATP'},
};
