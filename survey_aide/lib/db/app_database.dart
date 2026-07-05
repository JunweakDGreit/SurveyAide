import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Quotes, QuoteItems, RateOverrides, Payments, Appointments,
  ServiceCategories, Services, ServiceFields, ServiceRates, RateLabels,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedServicesData();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(serviceCategories);
          await m.createTable(services);
          await m.createTable(serviceFields);
          await m.createTable(serviceRates);
          await m.createTable(rateLabels);
        }
        if (from < 5) {
          await m.deleteTable('service_rates');
          await m.deleteTable('rate_labels');
          await m.deleteTable('service_fields');
          await m.deleteTable('services');
          await m.deleteTable('service_categories');
          await m.createTable(serviceCategories);
          await m.createTable(services);
          await m.createTable(serviceFields);
          await m.createTable(serviceRates);
          await m.createTable(rateLabels);
          await _seedServicesData();
        }
        if (from < 6) {
          await m.deleteTable('service_rates');
          await m.deleteTable('rate_labels');
          await m.deleteTable('service_fields');
          await m.deleteTable('services');
          await m.deleteTable('service_categories');
          await m.createTable(serviceCategories);
          await m.createTable(services);
          await m.createTable(serviceFields);
          await m.createTable(serviceRates);
          await m.createTable(rateLabels);
          await _seedServicesData();
        }
        if (from < 7) {
          await m.deleteTable('service_rates');
          await m.deleteTable('rate_labels');
          await m.deleteTable('service_fields');
          await m.deleteTable('services');
          await m.deleteTable('service_categories');
          await m.createTable(serviceCategories);
          await m.createTable(services);
          await m.createTable(serviceFields);
          await m.createTable(serviceRates);
          await m.createTable(rateLabels);
          await _seedServicesData();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        final count = await (selectOnly(services)..addColumns([services.code.count()])).map((r) => r.read(services.code.count())!).getSingle();
        if (count == 0) {
          await _seedServicesData();
        }
      },
    );
  }

  Future<void> _seedServicesData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/services.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final regions = data['regions'] as Map<String, dynamic>;

      final seenServices = <String>{};

      for (final regionEntry in regions.entries) {
        final regionCode = regionEntry.key;
        final rd = regionEntry.value as Map<String, dynamic>;

        final catsList = rd['categories'] as List;
        for (final c in catsList) {
          final cm = c as Map<String, dynamic>;
          await into(serviceCategories).insert(
            ServiceCategoriesCompanion.insert(
              key: cm['key'] as String,
              label: cm['label'] as String,
              color: cm['color'] as String,
              iconName: (cm['icon'] as String?) ?? '',
            ),
            mode: InsertMode.insertOrReplace,
          );
        }

        final svcsList = rd['services'] as List;
        for (final s in svcsList) {
          try {
            final sm = s as Map<String, dynamic>;
            final code = sm['code'] as String;

            if (!seenServices.contains(code)) {
              await into(services).insert(
                ServicesCompanion.insert(
                  code: code,
                  name: sm['name'] as String,
                  cat: sm['cat'] as String,
                  group: Value((sm['group'] as String?) ?? ''),
                  shortDescription: Value((sm['shortDescription'] as String?)),
                  note: Value((sm['note'] as String?)),
                ),
                mode: InsertMode.insertOrReplace,
              );
              seenServices.add(code);

              final fieldsList = sm['fields'] as List? ?? [];
              for (final f in fieldsList) {
                final fm = f as Map<String, dynamic>;
                await into(serviceFields).insert(
                  ServiceFieldsCompanion.insert(
                    serviceCode: code,
                    key: fm['key'] as String,
                    label: fm['label'] as String,
                    type: fm['type'] as String? ?? 'number',
                    step: Value((fm['step'] as num?)?.toDouble()),
                    min: Value((fm['min'] as num?)?.toDouble()),
                    def: Value(fm['def'] is num ? (fm['def'] as num).toDouble() : null),
                    optionsJson: Value(fm['options'] != null ? json.encode(fm['options']) : null),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
              }
            }

            final rates = sm['rates'] as Map<String, dynamic>? ?? {};
            for (final rateEntry in rates.entries) {
              await into(serviceRates).insert(
                ServiceRatesCompanion.insert(
                  serviceCode: code,
                  regionCode: regionCode,
                  rateKey: rateEntry.key,
                  value: (rateEntry.value as num).toDouble(),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          } catch (e) {
            debugPrint('Failed to seed service ${(s as Map)['code']}: $e');
          }
        }
      }

      for (final codeEntry in _rateLabelSeeds.entries) {
        for (final keyEntry in codeEntry.value.entries) {
          await into(rateLabels).insert(
            RateLabelsCompanion.insert(
              serviceCode: codeEntry.key,
              rateKey: keyEntry.key,
              label: keyEntry.value,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to seed services data: $e');
    }
  }

  static const _rateLabelSeeds = <String, Map<String, String>>{
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

  Future<List<ServiceCategory>> getCategories() async {
    final rows = await select(serviceCategories).get();
    return rows.map((r) => ServiceCategory(
      key: r.key,
      label: r.label,
      color: Color(int.parse(r.color.replaceFirst('#', '0xFF'))),
      iconName: r.iconName,
    )).toList();
  }

  Future<List<Service>> getServices(String regionCode) async {
    final svcRows = await select(services).get();
    final allFields = await select(serviceFields).get();
    final allRates = await (select(serviceRates)..where((t) => t.regionCode.equals(regionCode))).get();

    final fieldsByCode = <String, List<ServiceField>>{};
    for (final f in allFields) {
      final opts = f.optionsJson != null
          ? (json.decode(f.optionsJson!) as List).map((o) {
              final om = o as Map<String, dynamic>;
              return ServiceFieldOption(value: om['value'] as String, label: om['label'] as String);
            }).toList()
          : <ServiceFieldOption>[];
      fieldsByCode.putIfAbsent(f.serviceCode, () => []).add(ServiceField(
        key: f.key,
        label: f.label,
        type: f.type,
        step: f.step ?? 0,
        min: f.min ?? 0,
        def: f.def ?? 0,
        options: opts,
      ));
    }

    final ratesByCode = <String, Map<String, double>>{};
    for (final r in allRates) {
      ratesByCode.putIfAbsent(r.serviceCode, () => {})[r.rateKey] = r.value;
    }

    final allLabels = await select(rateLabels).get();
    final labelsByCode = <String, Map<String, String>>{};
    for (final lbl in allLabels) {
      labelsByCode.putIfAbsent(lbl.serviceCode, () => {})[lbl.rateKey] = lbl.label;
    }

    return svcRows.map((s) => Service(
      code: s.code,
      name: s.name,
      cat: s.cat,
      group: s.group ?? '',
      note: s.note,
      shortDescription: s.shortDescription,
      fields: fieldsByCode[s.code] ?? [],
      rates: ratesByCode[s.code] ?? {},
      labels: labelsByCode[s.code] ?? {},
    )).toList();
  }

  Future<Map<String, double>> getServiceRates(String serviceCode, String regionCode) async {
    final rows = await (select(serviceRates)
      ..where((t) => t.serviceCode.equals(serviceCode) & t.regionCode.equals(regionCode)))
      .get();
    return {for (final r in rows) r.rateKey: r.value};
  }

  Future<Map<String, String>> getRateLabels(String serviceCode) async {
    final rows = await (select(rateLabels)
      ..where((t) => t.serviceCode.equals(serviceCode)))
      .get();
    return {for (final r in rows) r.rateKey: r.label};
  }

  Future<Map<String, int>> getRegionsWithRates() async {
    final result = await customSelect(
      'SELECT region_code, COUNT(DISTINCT service_code) AS count FROM service_rates GROUP BY region_code',
    ).get();
    return {for (final r in result) r.read<String>('region_code'): r.read<int>('count')};
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ge_tariff.sqlite'));
    return NativeDatabase(file);
  });
}
