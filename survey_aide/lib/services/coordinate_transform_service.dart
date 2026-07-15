import 'crs_service.dart';
import 'zone_service.dart';

class GeoCoord {
  final double latDeg, lonDeg, height;
  const GeoCoord(this.latDeg, this.lonDeg, this.height);
}

class GeoCoordDms {
  final int latDeg, latMin, lonDeg, lonMin;
  final double latSec, lonSec;
  final double latDecimal, lonDecimal;

  const GeoCoordDms({
    required this.latDeg,
    required this.latMin,
    required this.latSec,
    required this.lonDeg,
    required this.lonMin,
    required this.lonSec,
    required this.latDecimal,
    required this.lonDecimal,
  });

  String get latDms =>
      '${latDeg.abs()}\u00B0 $latMin\' ${latSec.toStringAsFixed(1)}"${latDeg >= 0 ? 'N' : 'S'}';
  String get lonDms =>
      '${lonDeg.abs()}\u00B0 $lonMin\' ${lonSec.toStringAsFixed(1)}"${lonDeg >= 0 ? 'E' : 'W'}';
  String get dms => '$latDms  $lonDms';
  String get decimalDegrees =>
      '${latDecimal.toStringAsFixed(7)}\u00B0, ${lonDecimal.toStringAsFixed(7)}\u00B0';
}

class CoordinateTransform {
  static GeoCoord prs92GridToGeodetic(
    double northing,
    double easting,
    int ptmZone,
  ) {
    final result = CrsService.instance.transform(
      easting,
      northing,
      'PRS92_PTM_$ptmZone',
      'PRS92_GEO',
    );
    return GeoCoord(result.$2, result.$1, 0);
  }

  static (double n, double e) geodeticToPrs92Grid(
    double latDeg,
    double lonDeg,
    int ptmZone,
  ) {
    final result = CrsService.instance.transform(
      lonDeg,
      latDeg,
      'PRS92_GEO',
      'PRS92_PTM_$ptmZone',
    );
    return (result.$2, result.$1);
  }

  static GeoCoord prs92GridToWgs84Geodetic(
    double northing,
    double easting,
    int ptmZone,
  ) {
    final result = CrsService.instance.transform(
      easting,
      northing,
      'PRS92_PTM_$ptmZone',
      'WGS84',
    );
    return GeoCoord(result.$2, result.$1, 0);
  }

  static (double n, double e) wgs84GeodeticToPrs92Grid(
    double latDeg,
    double lonDeg,
    int ptmZone,
  ) {
    final result = CrsService.instance.transform(
      lonDeg,
      latDeg,
      'WGS84',
      'PRS92_PTM_$ptmZone',
    );
    return (result.$2, result.$1);
  }

  static GeoCoord prs92ToWgs84(double latDeg, double lonDeg, double h) {
    final result = CrsService.instance.transform(
      lonDeg,
      latDeg,
      'PRS92_GEO',
      'WGS84',
    );
    return GeoCoord(result.$2, result.$1, h);
  }

  static GeoCoord wgs84ToPrs92(double latDeg, double lonDeg, double h) {
    final result = CrsService.instance.transform(
      lonDeg,
      latDeg,
      'WGS84',
      'PRS92_GEO',
    );
    return GeoCoord(result.$2, result.$1, h);
  }

  static GeoCoordDms formatDms(double latDeg, double lonDeg) {
    final latAbs = latDeg.abs();
    final lonAbs = lonDeg.abs();
    final latD = latAbs.toInt();
    final latMRem = (latAbs - latD) * 60.0;
    final latM = latMRem.toInt();
    final latS = (latMRem - latM) * 60.0;
    final lonD = lonAbs.toInt();
    final lonMRem = (lonAbs - lonD) * 60.0;
    final lonM = lonMRem.toInt();
    final lonS = (lonMRem - lonM) * 60.0;
    return GeoCoordDms(
      latDeg: latDeg >= 0 ? latD : -latD,
      latMin: latM,
      latSec: latS,
      lonDeg: lonDeg >= 0 ? lonD : -lonD,
      lonMin: lonM,
      lonSec: lonS,
      latDecimal: latDeg,
      lonDecimal: lonDeg,
    );
  }
}

class UtmCoord {
  final int zone;
  final bool isNorthern;
  final double easting;
  final double northing;

  const UtmCoord({
    required this.zone,
    required this.isNorthern,
    required this.easting,
    required this.northing,
  });

  String get label =>
      '$zone${isNorthern ? 'N' : 'S'} ${easting.toStringAsFixed(3)}E ${northing.toStringAsFixed(3)}N';
}

class UtmTransform {
  static UtmCoord geodeticToUtm(double latDeg, double lonDeg) {
    final zone = PtmZone.detectUtmZone(lonDeg);
    final isNorthern = latDeg >= 0;
    final code = 'UTM_$zone';
    if (!CrsService.isRegistered(code)) {
      CrsService.register(
        code,
        '+proj=utm +zone=$zone +datum=WGS84 +units=m +no_defs',
      );
    }
    final result = CrsService.instance.transform(lonDeg, latDeg, 'WGS84', code);
    var northing = result.$2;
    if (northing < 0 && isNorthern) {
      northing += 10000000.0;
    }
    return UtmCoord(
      zone: zone,
      isNorthern: isNorthern,
      easting: result.$1,
      northing: northing,
    );
  }
}
