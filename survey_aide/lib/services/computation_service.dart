import '../core/constants.dart';
import '../core/helpers.dart';

typedef _ComputeFn = List<TallyLine> Function(Map<String, dynamic>, Map<String, double>, Map<String, String>, bool);

class ComputationService {
  static String _trimNum(double n) {
    return n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
  }

  static List<TallyLine> compute(
    String code,
    Map<String, dynamic> fields,
    Map<String, double> rates,
    Map<String, String> labels, {
    bool interp = false,
  }) {
    final fn = _dispatch[code];
    if (fn == null) throw ArgumentError('Unknown service code: $code');
    return fn(fields, rates, labels, interp);
  }

  static TallyLine _tieredCompute(
    double value,
    List<double> tierLimits,
    String unit,
    Map<String, double> rates,
    bool interp,
  ) {
    double total = 0;
    final parts = <String>[];
    double prev = 0;

    for (int i = 0; i < tierLimits.length; i++) {
      final upper = tierLimits[i];
      if (value <= prev) break;
      final qty = (value < upper ? value : upper) - prev;
      final tierKey = 'tier${i + 1}';
      final rate = rates[tierKey] ?? 0.0;
      if (qty > 0 && rate > 0) {
        total += qty * rate;
        final displayQty = interp ? qty : qty.ceilToDouble();
        parts.add('${interp ? qty.toStringAsFixed(2) : displayQty.toInt()} $unit \u00D7 ${peso(rate)}');
      }
      prev = upper;
      if (value <= upper) break;
    }

    return TallyLine(
      label: parts.join(' + '),
      amount: total,
    );
  }

  static final Map<String, _ComputeFn> _dispatch = {
    'A.1': _computeA1,
    'A.2': _computeA2,
    'A.3': _computeA3,
    'A.4': _computeA4,
    'A.5': _computeA5,
    'A.6': _computeA6,
    'B.1a': _computeB1a,
    'B.1b': _computeB1b,
    'B.2': _computeB2,
    'B.3a': _computeB3a,
    'B.3b': _computeB3b,
    'B.3c': _computeB3c,
    'B.4a': _computeB4a,
    'B.4b': _computeB4b,
    'B.4c': _computeB4c,
    'B.4d': _computeB4d,
    'B.4e': _computeB4e,
    'B.5': _computeB5,
    'B.6': _computeB6,
    'B.7a': _computeB7a,
    'B.7b': _computeB7b,
    'B.8a': _computeB8a,
    'B.8b': _computeB8b,
    'B.8c': _computeB8c,
    'B.8d': _computeB8d,
    'C.1': _computeC1,
    'C.2': _computeC2,
    'C.3': _computeC3,
    'C.4': _computeC4,
    'C.5': _computeC5,
    'D.1': _computeD1,
    'D.2': _computeD2,
    'D.3': _computeD3,
    'D.4': _computeD4,
    'D.5': _computeD5,
  };

  static List<TallyLine> _computeA1(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final totalHa = f['totalHa'] ?? 1.0;
    final excessHa = (totalHa - 1).clamp(0.0, double.infinity);
    final marks = f['marks'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    if (excessHa > 0) {
      final qty = interp ? excessHa : excessHa.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(totalHa)} total (${fmtArea(excessHa)} excess) \u00D7 ${peso(r['excessHaPerHa'] ?? 0.0)}/ha'
            : '+ ${fmtArea(totalHa)} total (${qty.toInt()} ha excess) @ ${peso(r['excessHaPerHa'] ?? 0.0)}/ha',
        amount: qty * (r['excessHaPerHa'] ?? 0.0),
      ));
    }

    if (marks > 0) {
      items.add(TallyLine(
        label: '+ ${marks.toInt()} intermediate mark(s) @ ${peso(r['marksEach'] ?? 0.0)}',
        amount: marks * (r['marksEach'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeA2(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final totalHa = f['totalHa'] ?? 1.0;
    final excessHa = (totalHa - 1).clamp(0.0, double.infinity);
    final distanceKm = f['distanceKm'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    if (excessHa > 0) {
      final qty = interp ? excessHa : excessHa.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(totalHa)} total (${fmtArea(excessHa)} excess) \u00D7 ${peso(r['excessHaPerHa'] ?? 0.0)}/ha'
            : '+ ${fmtArea(totalHa)} total (${qty.toInt()} ha excess) @ ${peso(r['excessHaPerHa'] ?? 0.0)}/ha',
        amount: qty * (r['excessHaPerHa'] ?? 0.0),
      ));
    }

    if (distanceKm > 0) {
      final qty = interp ? distanceKm : distanceKm.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${_trimNum(distanceKm)} km \u00D7 ${peso(r['distPerKm'] ?? 0.0)}/km'
            : '+ ${qty.toInt()} km from reference @ ${peso(r['distPerKm'] ?? 0.0)}/km',
        amount: qty * (r['distPerKm'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeA3(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final lots = f['lots'] ?? 0.0;
    final resultantHa = f['resultantHa'] ?? 0.0;
    final marks = f['marks'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    final extraLots = (lots - 2).clamp(0.0, double.infinity);
    if (extraLots > 0) {
      items.add(TallyLine(
        label: '+ ${extraLots.toInt()} additional lot(s) @ ${peso(r['extraLot'] ?? 0.0)}',
        amount: extraLots * (r['extraLot'] ?? 0.0),
      ));
    }

    final raw = (resultantHa - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHaPerHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHaPerHa'] ?? 0.0)}',
        amount: qty * (r['excessHaPerHa'] ?? 0.0),
      ));
    }

    if (marks > 0) {
      items.add(TallyLine(
        label: '+ ${marks.toInt()} intermediate mark(s) @ ${peso(r['marksEach'] ?? 0.0)}',
        amount: marks * (r['marksEach'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeA4(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final lots = f['lots'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(_tieredCompute(lots, [10, 20, 30, 40, 50, double.infinity], 'lot', r, interp));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeA5(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final motherLots = f['motherLots'] ?? 0.0;
    final consolidatedHa = f['consolidatedHa'] ?? 0.0;
    final marks = f['marks'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    final extraLots = (motherLots - 2).clamp(0.0, double.infinity);
    if (extraLots > 0) {
      items.add(TallyLine(
        label: '+ ${extraLots.toInt()} additional mother lot(s) @ ${peso(r['extraLot'] ?? 0.0)}',
        amount: extraLots * (r['extraLot'] ?? 0.0),
      ));
    }

    final raw = (consolidatedHa - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    if (marks > 0) {
      items.add(TallyLine(
        label: '+ ${marks.toInt()} intermediate mark(s) @ ${peso(r['marksEach'] ?? 0.0)}',
        amount: marks * (r['marksEach'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeA6(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    final raw = (ha - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB1a(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(_tieredCompute(ha, [1, 10, 30, 50, double.infinity], 'hectare', r, interp));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB1b(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(_tieredCompute(ha, [1, 10, 30, 50, double.infinity], 'hectare', r, interp));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB2(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(label: l['base']!, amount: r['base'] ?? 0.0));

    final raw = (ha - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB3a(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(r['perKm'] ?? 0.0)}/km \u2014 location & centerline profile',
      amount: km * (r['perKm'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB3b(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final sections = f['sections'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${sections.toInt()} section(s) @ ${peso(r['perSection'] ?? 0.0)}',
      amount: sections * (r['perSection'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB3c(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(r['perKm'] ?? 0.0)}/km',
      amount: km * (r['perKm'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB4a(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final terrain = (f['terrain'] ?? 0.0).toString(); // select field returns value string
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    // For select fields, the value is passed as the string "flat" or "hilly"
    // But the field value is stored as double in some cases. Check actual value.
    final isFlat = terrain == 'flat';
    final rate = isFlat ? (r['flat'] ?? 0.0) : (r['hilly'] ?? 0.0);

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(rate)}/km \u2014 ${isFlat ? 'nearly flat' : 'hilly/mountainous'}',
      amount: km * rate,
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB4b(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final terrain = (f['terrain'] ?? 0.0).toString();
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    final isFlat = terrain == 'flat';
    final rate = isFlat ? (r['flat'] ?? 0.0) : (r['hilly'] ?? 0.0);

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(rate)}/km \u2014 ${isFlat ? 'nearly flat' : 'hilly/mountainous'}',
      amount: km * rate,
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB4c(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final terrain = (f['terrain'] ?? 0.0).toString();
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    final isFlat = terrain == 'flat';
    final rate = isFlat ? (r['flat'] ?? 0.0) : (r['hilly'] ?? 0.0);

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(rate)}/km \u2014 ${isFlat ? 'nearly flat' : 'hilly/mountainous'}',
      amount: km * rate,
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB4d(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final terrain = (f['terrain'] ?? 0.0).toString();
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    final isFlat = terrain == 'flat';
    final prelimRate = isFlat ? (r['prelimFlat'] ?? 0.0) : (r['prelimHilly'] ?? 0.0);
    final prelim = km * prelimRate;
    final recon = 0.4 * prelim;
    final finalSurvey = km * (r['finalPerKm'] ?? 0.0);

    items.add(TallyLine(label: 'Reconnaissance survey (40% of preliminary)', amount: recon));
    items.add(TallyLine(
      label: 'Preliminary survey \u2014 ${isFlat ? 'nearly flat' : 'hilly/mountainous'} @ ${peso(prelimRate)}/km',
      amount: prelim,
    ));
    items.add(TallyLine(
      label: 'Final survey @ ${peso(r['finalPerKm'] ?? 0.0)}/km',
      amount: finalSurvey,
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB4e(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final km = f['km'] ?? 0.0;

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(r['perKm'] ?? 0.0)}/km \u2014 location planning',
      amount: km * (r['perKm'] ?? 0.0),
    ));

    return items;
  }

  static List<TallyLine> _computeB5(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final km = f['km'] ?? 0.0;
    final totalLots = f['totalLots'] ?? 0.0;
    final untitledLots = f['untitledLots'] ?? 0.0;

    final base = km * (r['perKm'] ?? 0.0);
    final allowed = 5 * km;
    items.add(TallyLine(
      label: 'Base \u2014 ${peso(r['perKm'] ?? 0.0)}/km \u00D7 ${_trimNum(km)} km (covers up to ${allowed.toInt()} lots)',
      amount: base,
    ));

    final excess = (totalLots - allowed).clamp(0.0, double.infinity);
    if (excess > 0) {
      final e = excess.ceilToDouble();
      items.add(TallyLine(
        label: '+ ${e.toInt()} lot(s) beyond included @ ${peso(r['excessLot'] ?? 0.0)}',
        amount: e * (r['excessLot'] ?? 0.0),
      ));
    }

    if (untitledLots > 0) {
      items.add(TallyLine(
        label: '+ ${untitledLots.toInt()} untitled mother lot(s) \u2014 CENRO fee @ ${peso(r['untitledLot'] ?? 0.0)}',
        amount: untitledLots * (r['untitledLot'] ?? 0.0),
      ));
    }

    return items;
  }

  static List<TallyLine> _computeB6(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final sites = f['sites'] ?? 0.0;

    items.add(TallyLine(
      label: '${sites.toInt()} site(s) with CAAP approval @ ${peso(r['perSite'] ?? 0.0)}',
      amount: sites * (r['perSite'] ?? 0.0),
    ));

    return items;
  }

  static List<TallyLine> _computeB7a(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final km = f['km'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${_trimNum(km)} km @ ${peso(r['perKm'] ?? 0.0)}/km',
      amount: km * (r['perKm'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeB7b(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final buildings = f['buildings'] ?? 0.0;
    final areaSqm = f['areaSqm'] ?? 0.0;

    items.add(TallyLine(
      label: '${buildings.toInt()} building(s) @ ${peso(r['basePerBldg'] ?? 0.0)} base (\u22641,000 sqm)',
      amount: (r['basePerBldg'] ?? 0.0) * buildings,
    ));

    final excess = (areaSqm - 1000).clamp(0.0, double.infinity);
    final units = (excess / 500).ceilToDouble();
    if (units > 0) {
      items.add(TallyLine(
        label: '+ ${units.toInt()} \u00D7 500 sqm excess @ ${peso(r['excessPer500sqm'] ?? 0.0)} \u00D7 ${buildings.toInt()} building(s)',
        amount: units * (r['excessPer500sqm'] ?? 0.0) * buildings,
      ));
    }

    return items;
  }

  static List<TallyLine> _computeB8a(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final addon = f['addon'] ?? 0.0;

    items.add(TallyLine(label: 'Base \u2014 first 81 ha (1 meridional block)', amount: r['base'] ?? 0.0));

    final raw = (ha - 81).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    if (addon > 0) {
      items.add(TallyLine(label: '+ Accommodation, transport, food & security', amount: addon));
    }

    return items;
  }

  static List<TallyLine> _computeB8b(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final interval = (f['interval'] ?? 0.0).toString();
    final points = f['points'] ?? 0.0;
    final addon = f['addon'] ?? 0.0;

    final gridKey = interval == '50' ? 'grid50' : (interval == '20' ? 'grid20' : 'grid100');
    final pts = points < 20 ? 20.0 : points;
    final rate = r[gridKey] ?? 0.0;

    items.add(TallyLine(
      label: '${pts.toInt()} borehole/drilling point(s) @ ${peso(rate)} (${interval}m interval)',
      amount: pts * rate,
    ));
    items.add(TallyLine(label: '+ Drilling plan', amount: r['drillPlan'] ?? 0.0));

    if (addon > 0) {
      items.add(TallyLine(label: '+ Accommodation, transport, food & security', amount: addon));
    }

    return items;
  }

  static List<TallyLine> _computeB8c(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;

    items.add(TallyLine(label: 'Base \u2014 first hectare or less', amount: r['base'] ?? 0.0));

    final raw = (ha - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    return items;
  }

  static List<TallyLine> _computeB8d(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;

    items.add(TallyLine(label: 'Base \u2014 first hectare or less', amount: r['base'] ?? 0.0));

    final raw = (ha - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} succeeding hectare(s) @ ${peso(r['excessHa'] ?? 0.0)}',
        amount: qty * (r['excessHa'] ?? 0.0),
      ));
    }

    return items;
  }

  static List<TallyLine> _computeC1(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final planType = (f['planType'] ?? 0.0).toString();
    final qty = f['qty'] ?? 0.0;

    final isLot = planType == 'lot';
    final rate = isLot ? (r['lotPlan'] ?? 0.0) : (r['vicinityMap'] ?? 0.0);
    final label = isLot ? 'Lot plan only' : 'Lot plan with vicinity map';

    items.add(TallyLine(
      label: '${qty.toInt()} \u00D7 $label @ ${peso(rate)}',
      amount: qty * rate,
    ));

    return items;
  }

  static List<TallyLine> _computeC2(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final qty = f['qty'] ?? 0.0;

    items.add(TallyLine(
      label: '${qty.toInt()} \u00D7 Lot plan with NAMRIA map @ ${peso(r['perQty'] ?? 0.0)}',
      amount: qty * (r['perQty'] ?? 0.0),
    ));

    return items;
  }

  static List<TallyLine> _computeC3(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final classes = f['classes'] ?? 0.0;
    final haPerClass = f['haPerClass'] ?? 0.0;

    items.add(TallyLine(
      label: '${classes.toInt()} classification(s) \u00D7 base ${peso(r['basePerClass'] ?? 0.0)} (\u22641 ha each)',
      amount: classes * (r['basePerClass'] ?? 0.0),
    ));

    final raw = (haPerClass - 1).clamp(0.0, double.infinity);
    if (raw > 0) {
      final qty = interp ? raw : raw.ceilToDouble();
      items.add(TallyLine(
        label: interp
            ? '+ ${fmtArea(raw)} \u00D7 ${classes.toInt()} class(es) \u00D7 ${peso(r['excessHa'] ?? 0.0)}/ha'
            : '+ ${qty.toInt()} ha excess \u00D7 ${classes.toInt()} class(es) @ ${peso(r['excessHa'] ?? 0.0)}/ha',
        amount: classes * qty * (r['excessHa'] ?? 0.0),
      ));
    }

    return items;
  }

  static List<TallyLine> _computeC4(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final qty = f['qty'] ?? 0.0;

    items.add(TallyLine(
      label: '${qty.toInt()} \u00D7 Subdivision scheme @ ${peso(r['perScheme'] ?? 0.0)}',
      amount: qty * (r['perScheme'] ?? 0.0),
    ));

    return items;
  }

  static List<TallyLine> _computeC5(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ha = f['ha'] ?? 0.0;
    final minHa = r['minHa'] ?? 0.0;
    final perHa = r['perHa'] ?? 0.0;

    final billHa = ha < minHa ? minHa : ha;
    final label = ha < minHa
        ? 'Minimum billable area applied \u2014 ${minHa.toInt()} ha @ ${peso(perHa)}/ha'
        : '${billHa.toInt()} ha @ ${peso(perHa)}/ha';

    items.add(TallyLine(label: label, amount: billHa * perHa));

    return items;
  }

  static List<TallyLine> _computeD1(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final appearances = f['appearances'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${appearances.toInt()} appearance(s) as expert witness @ ${peso(r['perAppear'] ?? 0.0)}',
      amount: appearances * (r['perAppear'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation & lodging', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeD2(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final qty = f['qty'] ?? 0.0;

    items.add(TallyLine(
      label: '${qty.toInt()} \u00D7 Technical consultation @ ${peso(r['perQty'] ?? 0.0)}',
      amount: qty * (r['perQty'] ?? 0.0),
    ));

    return items;
  }

  static List<TallyLine> _computeD3(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final areas = f['areas'] ?? 0.0;
    final transport = f['transport'] ?? 0.0;

    items.add(TallyLine(
      label: '${areas.toInt()} area inspection(s) @ ${peso(r['perArea'] ?? 0.0)}',
      amount: areas * (r['perArea'] ?? 0.0),
    ));

    if (transport > 0) {
      items.add(TallyLine(label: '+ Transportation cost', amount: transport));
    }

    return items;
  }

  static List<TallyLine> _computeD4(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final ts = f['totalStationDays'] ?? 0.0;
    final gps = f['gpsDays'] ?? 0.0;
    final echo = f['echoDays'] ?? 0.0;
    final level = f['levelDays'] ?? 0.0;
    final uav = f['uavDays'] ?? 0.0;

    if (ts > 0) {
      items.add(TallyLine(
        label: 'Total Station \u00D7 ${ts.toInt()} day(s) @ ${peso(r['totalStationPerDay'] ?? 0.0)}',
        amount: ts * (r['totalStationPerDay'] ?? 0.0),
      ));
    }
    if (gps > 0) {
      items.add(TallyLine(
        label: 'GPS Receiver \u00D7 ${gps.toInt()} day(s) @ ${peso(r['gpsPerDay'] ?? 0.0)}',
        amount: gps * (r['gpsPerDay'] ?? 0.0),
      ));
    }
    if (echo > 0) {
      items.add(TallyLine(
        label: 'Echo Sounder (w/ operator) \u00D7 ${echo.toInt()} day(s) @ ${peso(r['echoPerDay'] ?? 0.0)}',
        amount: echo * (r['echoPerDay'] ?? 0.0),
      ));
    }
    if (level > 0) {
      items.add(TallyLine(
        label: 'Automatic Digital Level \u00D7 ${level.toInt()} day(s) @ ${peso(r['levelPerDay'] ?? 0.0)}',
        amount: level * (r['levelPerDay'] ?? 0.0),
      ));
    }
    if (uav > 0) {
      items.add(TallyLine(
        label: 'UAV (w/ operator) \u00D7 ${uav.toInt()} day(s) @ ${peso(r['uavPerDay'] ?? 0.0)}',
        amount: uav * (r['uavPerDay'] ?? 0.0),
      ));
    }

    if (items.isEmpty) {
      items.add(const TallyLine(label: 'No equipment days entered', amount: 0));
    }

    return items;
  }

  static List<TallyLine> _computeD5(Map<String, dynamic> f, Map<String, double> r, Map<String, String> l, bool interp) {
    final items = <TallyLine>[];
    final withATP = f['withATP'] ?? 0.0;
    final withoutATP = f['withoutATP'] ?? 0.0;

    if (withATP > 0) {
      items.add(TallyLine(
        label: '${withATP.toInt()} print(s) with ATP @ ${peso(r['withATP'] ?? 0.0)}',
        amount: withATP * (r['withATP'] ?? 0.0),
      ));
    }
    if (withoutATP > 0) {
      items.add(TallyLine(
        label: '${withoutATP.toInt()} print(s) without ATP @ ${peso(r['withoutATP'] ?? 0.0)}',
        amount: withoutATP * (r['withoutATP'] ?? 0.0),
      ));
    }

    if (items.isEmpty) {
      items.add(const TallyLine(label: 'No prints entered', amount: 0));
    }

    return items;
  }
}
