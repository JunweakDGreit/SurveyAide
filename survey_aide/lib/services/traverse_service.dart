import 'dart:math' as math;

// ═══════════════════════════════════════════
// ANGLE UTILITIES
// ═══════════════════════════════════════════

class DMSAngle {
  final int degrees;
  final int minutes;
  final double seconds;

  const DMSAngle(this.degrees, this.minutes, this.seconds);

  double toDecimalDegrees() {
    final sign = degrees < 0 ? -1.0 : 1.0;
    return sign * (degrees.abs() + minutes / 60.0 + seconds / 3600.0);
  }

  double toRadians() => toDecimalDegrees() * math.pi / 180.0;

  @override
  String toString() =>
      '${degrees}\u00B0 $minutes\' ${seconds.toStringAsFixed(1)}"';
}

class AngleUtil {
  static DMSAngle dms(double decimalDegrees) {
    final sign = decimalDegrees < 0 ? -1 : 1;
    final abs = decimalDegrees.abs();
    final deg = abs.toInt();
    final minRem = (abs - deg) * 60.0;
    final min = minRem.toInt();
    final sec = (minRem - min) * 60.0;
    return DMSAngle(deg * sign, min, sec);
  }

  static double toRadians(double degrees) => degrees * math.pi / 180.0;
  static double toDegrees(double radians) => radians * 180.0 / math.pi;

  static String formatDMS(double decimalDegrees, {int decimals = 1}) {
    final d = dms(decimalDegrees);
    return '${d.degrees}\u00B0 ${d.minutes}\' ${d.seconds.toStringAsFixed(decimals)}"';
  }
}

// ═══════════════════════════════════════════
// QUADRANT BEARING
// ═══════════════════════════════════════════

enum Quadrant { ne, se, sw, nw }

class QuadrantBearing {
  final int degrees;
  final int minutes;
  final double seconds;
  final Quadrant quadrant;

  const QuadrantBearing(
      this.degrees, this.minutes, this.seconds, this.quadrant);

  double toAzimuthDegrees() {
    final dec = degrees + minutes / 60.0 + seconds / 3600.0;
    return switch (quadrant) {
      Quadrant.ne => dec,
      Quadrant.se => 180.0 - dec,
      Quadrant.sw => 180.0 + dec,
      Quadrant.nw => 360.0 - dec,
    };
  }

  double toAzimuthRadians() => toAzimuthDegrees() * math.pi / 180.0;

  String toFormattedString({bool useQuadrant = true, int decimals = 1}) {
    final secStr = seconds.toStringAsFixed(decimals);
    if (useQuadrant) {
      final qStr = quadrant.name.toUpperCase();
      return '$qStr $degrees\u00B0 $minutes\' $secStr"';
    }
    return '${toAzimuthDegrees().toStringAsFixed(4)}\u00B0';
  }

  static QuadrantBearing fromAzimuthDegrees(double azimuth) {
    final a = ((azimuth % 360.0) + 360.0) % 360.0;
    final (Quadrant quadrant, double angle) = switch (a) {
      _ when a >= 0.0 && a <= 90.0 => (Quadrant.ne, a),
      _ when a > 90.0 && a <= 180.0 => (Quadrant.se, 180.0 - a),
      _ when a > 180.0 && a <= 270.0 => (Quadrant.sw, a - 180.0),
      _ => (Quadrant.nw, 360.0 - a),
    };
    final dms = AngleUtil.dms(angle);
    return QuadrantBearing(dms.degrees, dms.minutes, dms.seconds, quadrant);
  }

  static QuadrantBearing? parseBearing(String quadrantStr, int deg, int min, double sec) {
    final q = switch (quadrantStr.toUpperCase()) {
      'NE' => Quadrant.ne,
      'SE' => Quadrant.se,
      'SW' => Quadrant.sw,
      'NW' => Quadrant.nw,
      _ => null,
    };
    if (q == null) return null;
    return QuadrantBearing(deg, min, sec, q);
  }
}

// ═══════════════════════════════════════════
// DMS PARSER
// ═══════════════════════════════════════════

class DmsParser {
  static double? parseDMS(String input) {
    final cleaned = input.trim().replaceAll(' ', '').toUpperCase();
    if (cleaned.isEmpty) return null;

    try {
      final sign = cleaned.startsWith('-') ||
              cleaned.endsWith('S') ||
              cleaned.endsWith('W') ||
              cleaned.endsWith('L')
          ? -1.0
          : 1.0;

      final numberStr = cleaned
          .replaceAll(RegExp(r'[NSEW]'), ' ')
          .replaceAll("'", ' ')
          .replaceAll('"', ' ')
          .replaceAll('`', ' ')
          .replaceAll(RegExp(r'[^0-9.\-]'), ' ')
          .trim();
      final parts =
          numberStr.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
      if (parts.isEmpty) return null;

      final numbers = parts.map((s) => double.tryParse(s)).whereType<double>().toList();
      if (numbers.isEmpty) return null;

      final decDeg = switch (numbers.length) {
        1 => numbers[0],
        2 => numbers[0] + numbers[1] / 60.0,
        3 => numbers[0] + numbers[1] / 60.0 + numbers[2] / 3600.0,
        _ => null,
      };
      if (decDeg == null) return null;
      return sign * decDeg;
    } catch (_) {
      return null;
    }
  }

  static String formatDMS(double decimalDegrees, {int decimals = 1}) {
    final sign = decimalDegrees < 0 ? '-' : '';
    final abs = decimalDegrees.abs();
    final deg = abs.toInt();
    final rem = (abs - deg) * 60.0;
    final min = rem.toInt();
    final sec = (rem - min) * 60.0;
    return '$sign${deg}\u00B0 $min\' ${sec.toStringAsFixed(decimals)}"';
  }
}

// ═══════════════════════════════════════════
// TRAVERSE DATA MODELS
// ═══════════════════════════════════════════

class TraverseLeg {
  final int id;
  final String station;
  final double bearingDeg;
  final double distance;

  const TraverseLeg({
    required this.id,
    required this.station,
    required this.bearingDeg,
    required this.distance,
  });
}

class ComputedLeg {
  final TraverseLeg leg;
  final double azimuthDeg;
  final double latitude;
  final double departure;
  final double northing;
  final double easting;

  const ComputedLeg({
    required this.leg,
    required this.azimuthDeg,
    required this.latitude,
    required this.departure,
    required this.northing,
    required this.easting,
  });
}

class AdjustedLeg {
  final TraverseLeg leg;
  final double unadjustedNorthing;
  final double unadjustedEasting;
  final double latitude;
  final double departure;
  final double adjLatitude;
  final double adjDeparture;
  final double adjNorthing;
  final double adjEasting;

  const AdjustedLeg({
    required this.leg,
    required this.unadjustedNorthing,
    required this.unadjustedEasting,
    required this.latitude,
    required this.departure,
    required this.adjLatitude,
    required this.adjDeparture,
    required this.adjNorthing,
    required this.adjEasting,
  });
}

class TraverseComputeResult {
  final List<ComputedLeg> legs;
  final double startNorthing;
  final double startEasting;
  final double sumLatitude;
  final double sumDeparture;
  final double perimeter;
  final double linearMisclosure;
  final String relativePrecision;
  final String status;

  const TraverseComputeResult({
    required this.legs,
    required this.startNorthing,
    required this.startEasting,
    required this.sumLatitude,
    required this.sumDeparture,
    required this.perimeter,
    required this.linearMisclosure,
    required this.relativePrecision,
    required this.status,
  });
}

class AdjustmentResult {
  final String method;
  final List<AdjustedLeg> adjustedLegs;
  final double errorNorthing;
  final double errorEasting;

  const AdjustmentResult({
    required this.method,
    required this.adjustedLegs,
    required this.errorNorthing,
    required this.errorEasting,
  });
}

// ═══════════════════════════════════════════
// TRAVERSE CALCULATOR
// ═══════════════════════════════════════════

class TraverseCalculator {
  static TraverseComputeResult compute({
    required List<TraverseLeg> legs,
    double startNorthing = 0.0,
    double startEasting = 0.0,
  }) {
    if (legs.isEmpty) {
      return TraverseComputeResult(
        legs: [],
        startNorthing: startNorthing,
        startEasting: startEasting,
        sumLatitude: 0.0,
        sumDeparture: 0.0,
        perimeter: 0.0,
        linearMisclosure: 0.0,
        relativePrecision: '1:0',
        status: 'No legs',
      );
    }

    final computed = <ComputedLeg>[];
    var currentN = startNorthing;
    var currentE = startEasting;

    for (final leg in legs) {
      final azimuthRad = leg.bearingDeg * math.pi / 180.0;
      final lat = leg.distance * math.cos(azimuthRad);
      final dep = leg.distance * math.sin(azimuthRad);

      currentN += lat;
      currentE += dep;

      computed.add(ComputedLeg(
        leg: leg,
        azimuthDeg: leg.bearingDeg,
        latitude: lat,
        departure: dep,
        northing: currentN,
        easting: currentE,
      ));
    }

    final sumLat = computed.fold<double>(0, (s, l) => s + l.latitude);
    final sumDep = computed.fold<double>(0, (s, l) => s + l.departure);
    final perim = computed.fold<double>(0, (s, l) => s + l.leg.distance);
    final misclosure = math.sqrt(sumLat * sumLat + sumDep * sumDep);

    final ratio = (misclosure > 0 && perim > 0)
        ? (perim / misclosure).round()
        : 0;
    final precision = '1:${ratio > 0 ? ratio.toString() : '0'}';

    final status = _closureStatus(perim, misclosure);

    return TraverseComputeResult(
      legs: computed,
      startNorthing: startNorthing,
      startEasting: startEasting,
      sumLatitude: _roundToSig(sumLat, 4),
      sumDeparture: _roundToSig(sumDep, 4),
      perimeter: _roundToSig(perim, 3),
      linearMisclosure: _roundToSig(misclosure, 4),
      relativePrecision: precision,
      status: status,
    );
  }

  static AdjustmentResult? adjust(
    TraverseComputeResult result, {
    String method = 'Compass Rule',
    double? startNorthing,
    double? startEasting,
  }) {
    if (result.legs.isEmpty) return null;

    final errorN = -result.sumLatitude;
    final errorE = -result.sumDeparture;
    final sN = startNorthing ?? result.startNorthing;
    final sE = startEasting ?? result.startEasting;

    final adjustedLegs = switch (method) {
      'Transit Rule' => _adjustTransit(result.legs, errorN, errorE, sN, sE),
      _ => _adjustCompass(result.legs, errorN, errorE, result.perimeter, sN, sE),
    };

    return AdjustmentResult(
      method: method,
      adjustedLegs: adjustedLegs,
      errorNorthing: errorN,
      errorEasting: errorE,
    );
  }

  static double computeAreaFromAdjusted(List<AdjustedLeg> adjustedLegs) {
    if (adjustedLegs.length < 3) return 0.0;
    final points = [
      ...adjustedLegs.map((l) => (l.adjNorthing, l.adjEasting)),
    ];
    return AreaCalculator.coordinateMethod(points);
  }

  static double computePerimeterFromAdjusted(List<AdjustedLeg> adjustedLegs) {
    return adjustedLegs.fold<double>(0, (s, l) => s + l.leg.distance);
  }

  static List<AdjustedLeg> _adjustCompass(
    List<ComputedLeg> legs,
    double errorN,
    double errorE,
    double perimeter,
    double startN,
    double startE,
  ) {
    final result = <AdjustedLeg>[];
    var runningAdjN = 0.0;
    var runningAdjE = 0.0;

    for (final leg in legs) {
      final factor = perimeter > 0.0 ? leg.leg.distance / perimeter : 0.0;
      final adjLat = leg.latitude + errorN * factor;
      final adjDep = leg.departure + errorE * factor;
      runningAdjN += adjLat;
      runningAdjE += adjDep;

      result.add(AdjustedLeg(
        leg: leg.leg,
        unadjustedNorthing: leg.northing,
        unadjustedEasting: leg.easting,
        latitude: leg.latitude,
        departure: leg.departure,
        adjLatitude: adjLat,
        adjDeparture: adjDep,
        adjNorthing: startN + runningAdjN,
        adjEasting: startE + runningAdjE,
      ));
    }
    return result;
  }

  static List<AdjustedLeg> _adjustTransit(
    List<ComputedLeg> legs,
    double errorN,
    double errorE,
    double startN,
    double startE,
  ) {
    final sumAbsLat = legs.fold<double>(0, (s, l) => s + l.latitude.abs());
    final sumAbsDep = legs.fold<double>(0, (s, l) => s + l.departure.abs());
    final result = <AdjustedLeg>[];
    var runningAdjN = 0.0;
    var runningAdjE = 0.0;

    for (final leg in legs) {
      final factorLat = sumAbsLat > 0.0 ? leg.latitude.abs() / sumAbsLat : 0.0;
      final factorDep = sumAbsDep > 0.0 ? leg.departure.abs() / sumAbsDep : 0.0;
      final adjLat = leg.latitude + errorN * factorLat;
      final adjDep = leg.departure + errorE * factorDep;
      runningAdjN += adjLat;
      runningAdjE += adjDep;

      result.add(AdjustedLeg(
        leg: leg.leg,
        unadjustedNorthing: leg.northing,
        unadjustedEasting: leg.easting,
        latitude: leg.latitude,
        departure: leg.departure,
        adjLatitude: adjLat,
        adjDeparture: adjDep,
        adjNorthing: startN + runningAdjN,
        adjEasting: startE + runningAdjE,
      ));
    }
    return result;
  }

  static String _closureStatus(double perimeter, double misclosure) {
    if (misclosure == 0.0) return 'Perfect closure';
    final ratio = perimeter / misclosure;
    if (ratio >= 10000) return 'Within tolerance (\u22651:10,000)';
    if (ratio >= 5000) return 'Below tolerance (1:5,000 \u2013 1:10,000)';
    return 'Exceeds tolerance (<1:5,000)';
  }

  static double _roundToSig(double v, int decimals) {
    final factor = math.pow(10.0, decimals);
    return (v * factor).roundToDouble() / factor;
  }
}

// ═══════════════════════════════════════════
// AREA CALCULATOR
// ═══════════════════════════════════════════

class AreaResult {
  final double areaSqM;
  final double areaHectares;
  final double perimeterM;

  const AreaResult({
    required this.areaSqM,
    required this.areaHectares,
    required this.perimeterM,
  });
}

class AreaCalculator {
  static AreaResult? compute(List<(double n, double e)> points) {
    if (points.length < 3) return null;

    final perimeter = computePerimeter(points);
    final area = coordinateMethod(points);

    return AreaResult(
      areaSqM: area,
      areaHectares: area / 10000.0,
      perimeterM: perimeter,
    );
  }

  static double coordinateMethod(List<(double n, double e)> points) {
    final n = points.length;
    if (n < 3) return 0.0;

    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      sum += points[i].$2 * points[j].$1;
      sum -= points[j].$2 * points[i].$1;
    }
    return sum.abs() / 2.0;
  }

  static double dmdMethod(List<(double n, double e)> points) {
    final n = points.length;
    if (n < 3) return 0.0;

    final lats = <double>[];
    final deps = <double>[];
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      lats.add(points[j].$1 - points[i].$1);
      deps.add(points[j].$2 - points[i].$2);
    }

    final dmd = List.filled(n, 0.0);
    dmd[0] = deps[0];
    for (var i = 1; i < n; i++) {
      dmd[i] = dmd[i - 1] + deps[i - 1] + deps[i];
    }

    var doubleArea = 0.0;
    for (var i = 0; i < n; i++) {
      doubleArea += dmd[i] * lats[i];
    }
    return doubleArea.abs() / 2.0;
  }

  static double computePerimeter(List<(double n, double e)> points) {
    final n = points.length;
    if (n < 2) return 0.0;

    var perim = 0.0;
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final dx = points[j].$2 - points[i].$2;
      final dy = points[j].$1 - points[i].$1;
      perim += math.sqrt(dx * dx + dy * dy);
    }
    return perim;
  }
}

// ═══════════════════════════════════════════
// DENR ROUNDING
// ═══════════════════════════════════════════

class DenrRounding {
  static double gridCoordinate(double meters) =>
      _roundToDec(meters, 3);

  static double distance(double meters, {bool isBaseline = false}) =>
      _roundToDec(meters, isBaseline ? 4 : 3);

  static double area(double sqMeters) => _roundToDec(sqMeters, 2);

  static double areaHectares(double hectares) => _roundToDec(hectares, 4);

  static double bearing(double decimalDegrees) =>
      _roundToDec(decimalDegrees, 4);

  static double scaleFactor(double value) => _roundToDec(value, 6);

  static double elevation(double meters) => _roundToDec(meters, 3);

  static double technicalDescriptionDistance(double meters) =>
      _roundToDec(meters, 2);

  static double _roundToDec(double value, int decimals) {
    final factor = math.pow(10.0, decimals);
    return (value * factor).roundToDouble() / factor;
  }
}

// ═══════════════════════════════════════════
// SURVEY UNIT CONVERSIONS
// ═══════════════════════════════════════════

class SurveyUnits {
  static const double meterToUsSurveyFeet = 39.37 / 12.0;
  static const double meterToIntlFeet = 1.0 / 0.3048;
  static const double chainToMeters = 20.1168;
  static const double linkToMeters = 0.201168;
  static const double varaToMeters = 0.835905;

  static double mToUsFt(double m) => m * meterToUsSurveyFeet;
  static double usFtToM(double ft) => ft / meterToUsSurveyFeet;
  static double mToIntlFt(double m) => m * meterToIntlFeet;
  static double intlFtToM(double ft) => ft / meterToIntlFeet;
  static double mToChains(double m) => m / chainToMeters;
  static double chainsToM(double ch) => ch * chainToMeters;
  static double mToLinks(double m) => m / linkToMeters;
  static double linksToM(double l) => l * linkToMeters;
  static double mToVaras(double m) => m / varaToMeters;
  static double varasToM(double v) => v * varaToMeters;
  static double sqmToHa(double sqm) => sqm / 10000.0;
  static double haToSqm(double ha) => ha * 10000.0;
}

// ═══════════════════════════════════════════
// DMD LOT DATA COMPUTATION (GSD-B-11)
// ═══════════════════════════════════════════

class DmdRow {
  final String station;
  final String bearingDms;
  final double distance;
  final double latitude;
  final double departure;
  final double dmd;
  final double doubleArea;
  final double northing;
  final double easting;

  const DmdRow({
    required this.station,
    required this.bearingDms,
    required this.distance,
    required this.latitude,
    required this.departure,
    required this.dmd,
    required this.doubleArea,
    required this.northing,
    required this.easting,
  });
}

class LotDataResult {
  final List<DmdRow> rows;
  final double sumLatitude;
  final double sumDeparture;
  final double totalDmd;
  final double doubleAreaTotal;
  final double areaSqM;
  final double areaHa;
  final double perimeter;

  const LotDataResult({
    required this.rows,
    required this.sumLatitude,
    required this.sumDeparture,
    required this.totalDmd,
    required this.doubleAreaTotal,
    required this.areaSqM,
    required this.areaHa,
    required this.perimeter,
  });

  String get areaSqMRounded => areaSqM.toStringAsFixed(2);
  String get areaHaRounded => areaHa.toStringAsFixed(4);
}

class LotDataComputer {
  /// Compute lot data from adjusted coordinates.
  /// [points] is a list of (northing, easting) tuples in order (closed loop).
  /// [stations] is optional list of station labels.
  /// [bearings] is optional list of bearing DMS strings.
  /// [distances] is optional list of distances.
  ///
  /// Uses DMD method for area.
  static LotDataResult compute(
    List<(double n, double e)> points, {
    List<String>? stations,
    List<String>? bearings,
    List<double>? distances,
  }) {
    final n = points.length;
    if (n < 3) {
      return LotDataResult(
        rows: [], sumLatitude: 0, sumDeparture: 0, totalDmd: 0,
        doubleAreaTotal: 0, areaSqM: 0, areaHa: 0, perimeter: 0,
      );
    }

    // Compute lat, dep for each line (j→(j+1)%n)
    final lats = <double>[];
    final deps = <double>[];
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      lats.add(points[j].$1 - points[i].$1);
      deps.add(points[j].$2 - points[i].$2);
    }

    // DMD
    final dmd = List.filled(n, 0.0);
    dmd[0] = deps[0];
    for (var i = 1; i < n; i++) {
      dmd[i] = dmd[i - 1] + deps[i - 1] + deps[i];
    }

    // Double area
    final doubleAreas = List.filled(n, 0.0);
    for (var i = 0; i < n; i++) {
      doubleAreas[i] = dmd[i] * lats[i];
    }

    final doubleAreaTotal = doubleAreas.fold<double>(0, (s, v) => s + v).abs();
    final areaSqM = doubleAreaTotal / 2.0;
    final areaHa = areaSqM / 10000.0;

    final perim = AreaCalculator.computePerimeter(points);

    // Build rows
    final rows = <DmdRow>[];
    for (var i = 0; i < n; i++) {
      final azRad = math.atan2(deps[i], lats[i]);
      final azDeg = (azRad * 180.0 / math.pi + 360.0) % 360.0;
      final qb = QuadrantBearing.fromAzimuthDegrees(azDeg);
      final dist = (distances != null && i < distances!.length)
          ? distances![i]
          : math.sqrt(lats[i] * lats[i] + deps[i] * deps[i]);

      rows.add(DmdRow(
        station: (stations != null && i < stations!.length)
            ? stations![i]
            : '${i + 1}',
        bearingDms: (bearings != null && i < bearings!.length)
            ? bearings![i]
            : qb.toFormattedString(),
        distance: dist,
        latitude: lats[i],
        departure: deps[i],
        dmd: dmd[i],
        doubleArea: doubleAreas[i],
        northing: points[i].$1,
        easting: points[i].$2,
      ));
    }

    return LotDataResult(
      rows: rows,
      sumLatitude: lats.fold(0, (s, v) => s + v),
      sumDeparture: deps.fold(0, (s, v) => s + v),
      totalDmd: dmd.last,
      doubleAreaTotal: doubleAreaTotal,
      areaSqM: areaSqM,
      areaHa: areaHa,
      perimeter: perim,
    );
  }
}
