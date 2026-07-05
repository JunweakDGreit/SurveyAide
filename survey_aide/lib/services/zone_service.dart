class PtmZone {
  final int zoneNumber;
  final double centralMeridian;
  final double scaleFactor;
  final double falseNorthing;
  final double falseEasting;
  final String name;

  const PtmZone({
    required this.zoneNumber,
    required this.centralMeridian,
    required this.scaleFactor,
    required this.falseNorthing,
    required this.falseEasting,
    required this.name,
  });

  static const _zones = [
    PtmZone(
      zoneNumber: 1,
      centralMeridian: 117.0,
      scaleFactor: 0.99995,
      falseNorthing: 0.0,
      falseEasting: 500000.0,
      name: 'PTM Zone 1 (116\u00B0E \u2013 118\u00B0E)',
    ),
    PtmZone(
      zoneNumber: 2,
      centralMeridian: 119.0,
      scaleFactor: 0.99995,
      falseNorthing: 0.0,
      falseEasting: 500000.0,
      name: 'PTM Zone 2 (118\u00B0E \u2013 120\u00B0E)',
    ),
    PtmZone(
      zoneNumber: 3,
      centralMeridian: 121.0,
      scaleFactor: 0.99995,
      falseNorthing: 0.0,
      falseEasting: 500000.0,
      name: 'PTM Zone 3 (120\u00B0E \u2013 122\u00B0E)',
    ),
    PtmZone(
      zoneNumber: 4,
      centralMeridian: 123.0,
      scaleFactor: 0.99995,
      falseNorthing: 0.0,
      falseEasting: 500000.0,
      name: 'PTM Zone 4 (122\u00B0E \u2013 124\u00B0E)',
    ),
    PtmZone(
      zoneNumber: 5,
      centralMeridian: 125.0,
      scaleFactor: 0.99995,
      falseNorthing: 0.0,
      falseEasting: 500000.0,
      name: 'PTM Zone 5 (124\u00B0E \u2013 126\u00B0E)',
    ),
  ];

  static PtmZone fromZoneNumber(int zone) {
    return _zones.firstWhere(
      (z) => z.zoneNumber == zone,
      orElse: () => throw ArgumentError('Invalid PTM zone: $zone. Valid zones: 1-5'),
    );
  }

  static PtmZone fromLongitude(double lonDeg) {
    final normalizedLon = ((lonDeg % 360.0) + 360.0) % 360.0;
    return switch (normalizedLon) {
      _ when normalizedLon >= 116.0 && normalizedLon < 118.0 => _zones[0],
      _ when normalizedLon >= 118.0 && normalizedLon < 120.0 => _zones[1],
      _ when normalizedLon >= 120.0 && normalizedLon < 122.0 => _zones[2],
      _ when normalizedLon >= 122.0 && normalizedLon < 124.0 => _zones[3],
      _ when normalizedLon >= 124.0 && normalizedLon <= 126.0 => _zones[4],
      _ => throw ArgumentError(
          'Longitude $lonDeg\u00B0 is outside PTM coverage (116\u00B0E \u2013 126\u00B0E)'),
    };
  }

  static int detectUtmZone(double longitudeDeg) {
    final normalizedLon = ((longitudeDeg % 360.0) + 360.0) % 360.0;
    return ((normalizedLon + 180.0) / 6.0).ceil();
  }

  static (int ptmZone, int utmZone, String ptmName) detectAll(
      double lat, double lon) {
    final ptm = fromLongitude(lon);
    final utm = detectUtmZone(lon);
    return (ptm.zoneNumber, utm, ptm.name);
  }

  static List<PtmZone> getAllZones() => List.unmodifiable(_zones);

  static bool isValidZone(int zone) => zone >= 1 && zone <= 5;
}
