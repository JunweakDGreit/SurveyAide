import 'package:proj4dart/proj4dart.dart' as p4;

class RegisteredCrs {
  final String code;
  final String label;
  final bool isProjected;

  const RegisteredCrs({
    required this.code,
    required this.label,
    required this.isProjected,
  });
}

class CrsService {
  CrsService._();
  static final CrsService _instance = CrsService._();
  static CrsService get instance => _instance;

  static final List<RegisteredCrs> _crsList = [
    const RegisteredCrs(
      code: 'WGS84',
      label: 'WGS84 (Geographic)',
      isProjected: false,
    ),
    const RegisteredCrs(
      code: 'PRS92_GEO',
      label: 'PRS92 Geographic (Clarke 1866)',
      isProjected: false,
    ),
    const RegisteredCrs(
      code: 'PRS92_PTM_1',
      label: 'PTM Zone 1 (116\u00B0E \u2013 118\u00B0E)',
      isProjected: true,
    ),
    const RegisteredCrs(
      code: 'PRS92_PTM_2',
      label: 'PTM Zone 2 (118\u00B0E \u2013 120\u00B0E)',
      isProjected: true,
    ),
    const RegisteredCrs(
      code: 'PRS92_PTM_3',
      label: 'PTM Zone 3 (120\u00B0E \u2013 122\u00B0E)',
      isProjected: true,
    ),
    const RegisteredCrs(
      code: 'PRS92_PTM_4',
      label: 'PTM Zone 4 (122\u00B0E \u2013 124\u00B0E)',
      isProjected: true,
    ),
    const RegisteredCrs(
      code: 'PRS92_PTM_5',
      label: 'PTM Zone 5 (124\u00B0E \u2013 126\u00B0E)',
      isProjected: true,
    ),
  ];

  static const _towgs84Clarke =
      '-127.62,-67.24,-47.04,3.068,4.903,1.578,-1.06';

  static List<RegisteredCrs> get availableCrs => List.unmodifiable(_crsList);

  static void init() {
    _registerDefaults();
  }

  static void _registerDefaults() {
    p4.Projection.add(
      'PRS92_GEO',
      '+proj=longlat +ellps=clrk66 '
      '+towgs84=$_towgs84Clarke +no_defs',
    );

    const cms = [117.0, 119.0, 121.0, 123.0, 125.0];
    const k0 = 0.99995;
    const fe = 500000.0;
    for (var i = 0; i < 5; i++) {
      p4.Projection.add(
        'PRS92_PTM_${i + 1}',
        '+proj=tmerc +lat_0=0 +lon_0=${cms[i]} +k=$k0 '
        '+x_0=$fe +y_0=0 +ellps=clrk66 '
        '+towgs84=$_towgs84Clarke +units=m +no_defs',
      );
    }
  }

  static bool isRegistered(String code) {
    return p4.Projection.get(code) != null;
  }

  static void register(String code, String proj4String) {
    p4.Projection.add(code, proj4String);
  }

  static void registerFromEpsg(int epsgCode) {
    throw UnimplementedError(
      'Download from epsg.io not yet implemented. '
      'Use register(code, proj4String) for custom CRS definitions.',
    );
  }

  (double x, double y) transform(
    double x,
    double y,
    String fromCode,
    String toCode,
  ) {
    final src = p4.Projection.get(fromCode);
    final dst = p4.Projection.get(toCode);
    if (src == null) throw ArgumentError('Unknown source CRS: $fromCode');
    if (dst == null) throw ArgumentError('Unknown target CRS: $toCode');
    final result = src.transform(dst, p4.Point(x: x, y: y));
    return (result.x, result.y);
  }

  static RegisteredCrs? findByCode(String code) {
    for (final crs in _crsList) {
      if (crs.code == code) return crs;
    }
    return null;
  }

  static String labelFor(String code) {
    final found = findByCode(code);
    if (found != null) return found.label;
    final codeNum = code.replaceAll(RegExp(r'[^0-9]'), '');
    if (codeNum.isNotEmpty) return 'EPSG:$codeNum';
    return code;
  }

  static String geographicFor(String code) {
    if (code.startsWith('PRS92_PTM_')) return 'PRS92_GEO';
    return code;
  }
}
