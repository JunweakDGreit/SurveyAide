import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/uiprovider.dart';
import '../../services/traverse_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/press_scale.dart';
import '../../widgets/sketch_plan_painter.dart';
import '../../widgets/toast.dart';
import '../../widgets/traverse_dialogs.dart';
import '../../services/crs_service.dart';


enum _InputMode { bd, ne, geographic }

class _PointEntry {
  int id;
  double? northing;
  double? easting;
  Quadrant? quadrant;
  int bearingDeg;
  int bearingMin;
  double bearingSec;
  double? distance;

  // Geographic (lat/lon) fields
  int latDeg;
  int latMin;
  double latSec;
  bool latNorth;
  int lonDeg;
  int lonMin;
  double lonSec;
  bool lonEast;

  _PointEntry({
    required this.id,
    this.northing,
    this.easting,
    this.quadrant,
    this.bearingDeg = 0,
    this.bearingMin = 0,
    this.bearingSec = 0.0,
    this.distance,
    this.latDeg = 0,
    this.latMin = 0,
    this.latSec = 0.0,
    this.latNorth = true,
    this.lonDeg = 0,
    this.lonMin = 0,
    this.lonSec = 0.0,
    this.lonEast = true,
  });
}

class _NeLeg {
  final String label;
  final double bearingDeg;
  final double distance;
  final double dN;
  final double dE;
  final double northing;
  final double easting;

  _NeLeg({
    required this.label,
    required this.bearingDeg,
    required this.distance,
    required this.dN,
    required this.dE,
    required this.northing,
    required this.easting,
  });
}

class TraverseScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool embedded;

  const TraverseScreen({super.key, this.initialData, this.embedded = false});

  @override
  State<TraverseScreen> createState() => TraverseScreenState();
}

class TraverseScreenState extends State<TraverseScreen> {
  final _points = <_PointEntry>[];
  final _startNCtrl = TextEditingController();
  final _startECtrl = TextEditingController();
  final _traverseNameCtrl = TextEditingController();

  TraverseComputeResult? _computeResult;
  AdjustmentResult? _adjustResult;
  AreaResult? _areaResult;
  _InputMode _mode = _InputMode.bd;
  bool _hasTiePoint = false;
  bool get _effectiveTiePoint => _hasTiePoint && _tieQuadrant != null && (_tieDistance ?? 0) > 0;
  Quadrant? _tieQuadrant;
  int _tieBearingDeg = 0;
  int _tieBearingMin = 0;
  double _tieBearingSec = 0.0;
  double? _tieDistance;
  String? _crsFrom;
  String? _crsTo;
  int? _prs92FromZone;
  int? _prs92ToZone;
  bool _showResults = false;
  bool _processing = false;
  bool _showDetailedTable = false;
  int _nextId = 1;
  List<_NeLeg> _neLegs = [];
  String _adjustmentMethod = 'Compass Rule';
  TraverseComputeResult? _perimeterResult;
  TraverseLeg? _tieLeg;
  double _tieCp1N = 0;
  double _tieCp1E = 0;
  String? _loadedDataHash;
  final _horizontalScrollCtrl = ScrollController();

  static const _storageKey = 'gep_traverse_data';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _loadFromData(widget.initialData!);
      WidgetsBinding.instance.addPostFrameCallback((_) => _compute());
    } else {
      _loadFromStorage();
      if (_points.isEmpty) _addPoint();
    }
  }

  @override
  void dispose() {
    _startNCtrl.dispose();
    _startECtrl.dispose();
    _traverseNameCtrl.dispose();
    _horizontalScrollCtrl.dispose();
    super.dispose();
  }

  void _addPoint() {
    setState(() {
      _points.add(_PointEntry(id: _nextId++));
      _showResults = false;
    });
  }

  void _removePoint(int index) {
    if (_points.length <= 1) return;
    setState(() {
      _points.removeAt(index);
      _showResults = false;
    });
  }

  String _stationLabel(int index) {
    if (_effectiveTiePoint) return (index + 2).toString();
    return (index + 1).toString();
  }

  String _badgeLabel(int index) {
    if (_mode == _InputMode.ne || _mode == _InputMode.geographic) {
      return '${index + 1}';
    }
    final from = index + 1;
    final to = index == _points.length - 1 ? 1 : from + 1;
    return '$from→$to';
  }

  String _legLabel(int index, int totalLegs) {
    if (_effectiveTiePoint) {
      if (index == 0) return 'TP→1';
      if (index < totalLegs - 1) return '$index→${index + 1}';
      return '${totalLegs - 1}→1';
    }
    if (index < totalLegs - 1) return '${index + 1}→${index + 2}';
    return '$totalLegs→1';
  }

  Future<void> _compute() async {
    setState(() => _processing = true);

    if (_mode == _InputMode.bd) {
      final startN = double.tryParse(_startNCtrl.text) ?? 0.0;
      final startE = double.tryParse(_startECtrl.text) ?? 0.0;

      // Build tie leg and perimeter legs separately
      TraverseLeg? tieLeg;
      if (_effectiveTiePoint) {
        final qb = QuadrantBearing(
          _tieBearingDeg, _tieBearingMin, _tieBearingSec, _tieQuadrant!);
        tieLeg = TraverseLeg(
          id: -1, station: '1', bearingDeg: qb.toAzimuthDegrees(),
          distance: _tieDistance!,
        );
      }

      final perimeterLegs = <TraverseLeg>[];
      for (var i = 0; i < _points.length; i++) {
        final point = _points[i];
        if (point.quadrant == null || (point.distance ?? 0) <= 0) continue;
        final qb = QuadrantBearing(
          point.bearingDeg, point.bearingMin, point.bearingSec, point.quadrant!,
        );
        perimeterLegs.add(TraverseLeg(
          id: point.id,
          station: _stationLabel(i),
          bearingDeg: qb.toAzimuthDegrees(),
          distance: point.distance!,
        ));
      }

      TraverseComputeResult? result;
      AdjustmentResult? adjust;
      AreaResult? area;

      if (_effectiveTiePoint && tieLeg != null) {
        // Compute CP1 from tie leg
        final tieRad = tieLeg.bearingDeg * math.pi / 180.0;
        final tieLat = tieLeg.distance * math.cos(tieRad);
        final tieDep = tieLeg.distance * math.sin(tieRad);
        final cp1N = startN + tieLat;
        final cp1E = startE + tieDep;

        if (perimeterLegs.isEmpty) {
          setState(() => _processing = false);
          if (mounted) showToast(context, 'Add at least one bearing-distance leg');
          return;
        }

        // Compute and adjust perimeter only
        final pResult = TraverseCalculator.compute(
            legs: perimeterLegs, startNorthing: cp1N, startEasting: cp1E);
        final pAdjust = TraverseCalculator.adjust(pResult, method: _adjustmentMethod);

        _perimeterResult = pResult;
        _tieLeg = tieLeg;
        _tieCp1N = cp1N;
        _tieCp1E = cp1E;

        // MERGE tie leg into results for display
        // Un-adjusted merge
        final tieComputed = ComputedLeg(
          leg: tieLeg, azimuthDeg: tieLeg.bearingDeg,
          latitude: tieLat, departure: tieDep,
          northing: cp1N, easting: cp1E,
        );
        result = TraverseComputeResult(
          legs: [tieComputed, ...pResult.legs],
          startNorthing: startN, startEasting: startE,
          sumLatitude: tieLat + pResult.sumLatitude,
          sumDeparture: tieDep + pResult.sumDeparture,
          perimeter: tieLeg.distance + pResult.perimeter,
          linearMisclosure: pResult.linearMisclosure,
          relativePrecision: pResult.relativePrecision,
          status: pResult.status,
        );

        // Adjusted merge
        if (pAdjust != null) {
          final tieAdjusted = AdjustedLeg(
            leg: tieLeg,
            unadjustedNorthing: cp1N, unadjustedEasting: cp1E,
            latitude: tieLat, departure: tieDep,
            adjLatitude: tieLat, adjDeparture: tieDep,
            adjNorthing: cp1N, adjEasting: cp1E,
          );
          adjust = AdjustmentResult(
            method: pAdjust.method,
            adjustedLegs: [tieAdjusted, ...pAdjust.adjustedLegs],
            errorNorthing: pAdjust.errorNorthing,
            errorEasting: pAdjust.errorEasting,
          );
        }

        // Area from perimeter only
        final perimeterCoords = <(double, double)>[];
        if (pAdjust != null) {
          for (final l in pAdjust.adjustedLegs) {
            perimeterCoords.add((l.adjNorthing, l.adjEasting));
          }
        } else {
          var n = cp1N;
          var e = cp1E;
          for (final leg in pResult.legs) {
            n += leg.latitude;
            e += leg.departure;
            perimeterCoords.add((n, e));
          }
        }
        if (perimeterCoords.length >= 3) {
          area = AreaCalculator.compute(perimeterCoords);
        }

      } else {
        // No tie point — original behavior
        if (perimeterLegs.isEmpty) {
          setState(() => _processing = false);
          if (mounted) showToast(context, 'Add at least one bearing-distance leg');
          return;
        }

        result = TraverseCalculator.compute(
            legs: perimeterLegs, startNorthing: startN, startEasting: startE);
        adjust = TraverseCalculator.adjust(result, method: _adjustmentMethod);

        final coords = <(double, double)>[];
        if (adjust != null) {
          for (final l in adjust.adjustedLegs) {
            coords.add((l.adjNorthing, l.adjEasting));
          }
        } else {
          var n = startN;
          var e = startE;
          for (final leg in result.legs) {
            n += leg.latitude;
            e += leg.departure;
            coords.add((n, e));
          }
        }
        if (coords.length >= 3) area = AreaCalculator.compute(coords);
      }

      setState(() {
        _computeResult = result;
        _adjustResult = adjust;
        _areaResult = area;
        _showResults = true;
        _processing = false;
      });
      _saveHistory(result, adjust, area);

    } else if (_mode == _InputMode.ne) {
      // N/E mode – area only
      final coords = <(double, double)>[];
      for (final point in _points) {
        if (point.northing != null && point.easting != null) {
          coords.add((point.northing!, point.easting!));
        }
      }

      _computeNeMode(coords);

    } else {
      // Geographic mode – convert lat/lon to target CRS, then area
      final resolvedFrom =
          _resolveCrsCode(_crsFrom, _prs92FromZone) ?? 'WGS84';
      final coords = <(double, double)>[];
      for (final point in _points) {
        final geo = _convertToDecimal(point);
        if (geo != null) {
          final (lat, lon) = geo;
          try {
            final result = CrsService.instance.transform(
              lon, lat, 'WGS84', resolvedFrom,
            );
            coords.add((result.$2, result.$1));
          } catch (_) {}
        }
      }

      _computeNeMode(coords);
    }
  }

  (double, double)? _convertToDecimal(_PointEntry p) {
    if (p.latDeg == 0 && p.lonDeg == 0) return null;
    final lat = (p.latDeg + p.latMin / 60.0 + p.latSec / 3600.0) *
        (p.latNorth ? 1.0 : -1.0);
    final lon = (p.lonDeg + p.lonMin / 60.0 + p.lonSec / 3600.0) *
        (p.lonEast ? 1.0 : -1.0);
    return (lat, lon);
  }

  String? _resolveCrsCode(String? simplified, int? zone) {
    if (simplified == null) return null;
    if (simplified == 'WGS84') return 'WGS84';

    if (_mode == _InputMode.geographic && zone == null) {
      final pt = _points.isNotEmpty ? _points[0] : null;
      if (pt != null) {
        final geo = _convertToDecimal(pt);
        if (geo != null) {
          final detected = CrsService.zoneFromLongitude(geo.$2);
          if (detected != null) return 'PRS92_PTM_$detected';
        }
      }
      return 'PRS92_GEO';
    }

    if (zone != null && zone >= 1 && zone <= 5) return 'PRS92_PTM_$zone';
    return 'PRS92_GEO';
  }

  void _computeNeMode(List<(double, double)> coords) {
    if (coords.length < 3) {
      setState(() {
        _computeResult = null;
        _adjustResult = null;
        _areaResult = null;
        _neLegs = [];
        _showResults = true;
        _processing = false;
      });
      return;
    }

    final neLegs = <_NeLeg>[];
    for (var i = 0; i < coords.length - 1; i++) {
      final (n1, e1) = coords[i];
      final (n2, e2) = coords[i + 1];
      final dN = n2 - n1;
      final dE = e2 - e1;
      final dist = math.sqrt(dN * dN + dE * dE);
      final azRad = math.atan2(dE, dN);
      final azDeg = (azRad * 180 / math.pi + 360) % 360;
      neLegs.add(_NeLeg(
        label: '${i + 1}→${i + 2}',
        bearingDeg: azDeg,
        distance: dist,
        dN: dN, dE: dE,
        northing: n2, easting: e2,
      ));
    }
    if (coords.length >= 3) {
      final (n1, e1) = coords.last;
      final (n2, e2) = coords.first;
      final dN = n2 - n1;
      final dE = e2 - e1;
      final dist = math.sqrt(dN * dN + dE * dE);
      final azRad = math.atan2(dE, dN);
      final azDeg = (azRad * 180 / math.pi + 360) % 360;
      neLegs.add(_NeLeg(
        label: '${coords.length}→1',
        bearingDeg: azDeg,
        distance: dist,
        dN: dN, dE: dE,
        northing: n2, easting: e2,
      ));
    }

    AreaResult? area;
    if (coords.length >= 3) area = AreaCalculator.compute(coords);

    setState(() {
      _computeResult = null;
      _adjustResult = null;
      _areaResult = area;
      _neLegs = neLegs;
      _showResults = true;
      _processing = false;
    });
    _saveHistory(null, null, area);
  }

  String _inputDataJson() {
    return json.encode({
      'name': _traverseNameCtrl.text,
      'mode': _mode.name,
      'hasTiePoint': _hasTiePoint,
      'tieQuadrant': _tieQuadrant?.name,
      'tieBearingDeg': _tieBearingDeg,
      'tieBearingMin': _tieBearingMin,
      'tieBearingSec': _tieBearingSec,
      'tieDistance': _tieDistance,
      'startN': _startNCtrl.text,
      'startE': _startECtrl.text,
      'points': _points.map((p) => {
        'id': p.id,
        'northing': p.northing,
        'easting': p.easting,
        'quadrant': p.quadrant?.name,
        'bearingDeg': p.bearingDeg,
        'bearingMin': p.bearingMin,
        'bearingSec': p.bearingSec,
        'distance': p.distance,
        'latDeg': p.latDeg,
        'latMin': p.latMin,
        'latSec': p.latSec,
        'latNorth': p.latNorth,
        'lonDeg': p.lonDeg,
        'lonMin': p.lonMin,
        'lonSec': p.lonSec,
        'lonEast': p.lonEast,
      }).toList(),
    });
  }

  void _saveHistory(TraverseComputeResult? result, AdjustmentResult? adjust, AreaResult? area) {
    final inputJson = _inputDataJson();
    if (_loadedDataHash != null && _loadedDataHash == inputJson) return;

    _loadedDataHash = inputJson;

    final history = StorageService().getString('gep_traverse_history');
    final list = <Map<String, dynamic>>[];
    if (history.isNotEmpty) {
      try {
        list.addAll((json.decode(history) as List).cast<Map<String, dynamic>>());
      } catch (_) {}
    }

    list.insert(0, {
      'name': _traverseNameCtrl.text.isNotEmpty ? _traverseNameCtrl.text : 'Traverse ${DateTime.now().toLocal().toString().split(' ')[0]}',
      'date': DateTime.now().toIso8601String(),
      'mode': _mode.name,
      'adjustmentMethod': _adjustmentMethod,
      'precision': result?.relativePrecision,
      'method': adjust?.method ?? 'None',
      'areaHa': area?.areaHectares,
      'areaSqm': area?.areaSqM,
      'perimeter': area?.perimeterM,
      'legs': result?.legs.length,
      'status': result?.status ?? 'N/E',
      // Input data for repopulation
      'hasTiePoint': _hasTiePoint,
      'tieQuadrant': _tieQuadrant?.name,
      'tieBearingDeg': _tieBearingDeg,
      'tieBearingMin': _tieBearingMin,
      'tieBearingSec': _tieBearingSec,
      'tieDistance': _tieDistance,
      'startN': _startNCtrl.text,
      'startE': _startECtrl.text,
      'crsFrom': _crsFrom,
      'crsTo': _crsTo,
      'prs92FromZone': _prs92FromZone,
      'prs92ToZone': _prs92ToZone,
      'points': _points.map((p) => {
        'id': p.id,
        'northing': p.northing,
        'easting': p.easting,
        'quadrant': p.quadrant?.name,
        'bearingDeg': p.bearingDeg,
        'bearingMin': p.bearingMin,
        'bearingSec': p.bearingSec,
        'distance': p.distance,
        'latDeg': p.latDeg,
        'latMin': p.latMin,
        'latSec': p.latSec,
        'latNorth': p.latNorth,
        'lonDeg': p.lonDeg,
        'lonMin': p.lonMin,
        'lonSec': p.lonSec,
        'lonEast': p.lonEast,
      }).toList(),
    });

    final trimmed = list.take(20).toList();
    StorageService().setString('gep_traverse_history', json.encode(trimmed));
  }

  void _clearAll() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear All',
      message: 'Remove all traverse data?',
      confirmLabel: 'Clear',
    );
    if (!confirmed) return;
    StorageService().setString(_storageKey, '');
    setState(() {
      _points.clear();
      _computeResult = null;
      _adjustResult = null;
      _areaResult = null;
      _showResults = false;
      _mode = _InputMode.bd;
      _crsFrom = null;
      _crsTo = null;
      _prs92FromZone = null;
      _prs92ToZone = null;
      _hasTiePoint = false;
      _tieQuadrant = null;
      _tieBearingDeg = 0;
      _tieBearingMin = 0;
      _tieBearingSec = 0.0;
      _tieDistance = null;
      _startNCtrl.clear();
      _startECtrl.clear();
      _traverseNameCtrl.clear();
      _nextId = 1;
      _neLegs = [];
      _adjustmentMethod = 'Compass Rule';
      _perimeterResult = null;
      _tieLeg = null;
      _tieCp1N = 0;
      _tieCp1E = 0;
      _loadedDataHash = null;
    });
    _addPoint();
  }

  Future<void> _saveToStorage() async {
    final data = {
      'name': _traverseNameCtrl.text,
      'mode': _mode.name,
      'adjustmentMethod': _adjustmentMethod,
      'hasTiePoint': _hasTiePoint,
      'tieQuadrant': _tieQuadrant?.name,
      'tieBearingDeg': _tieBearingDeg,
      'tieBearingMin': _tieBearingMin,
      'tieBearingSec': _tieBearingSec,
      'tieDistance': _tieDistance,
      'startN': _startNCtrl.text,
      'startE': _startECtrl.text,
      'crsFrom': _crsFrom,
      'crsTo': _crsTo,
      'prs92FromZone': _prs92FromZone,
      'prs92ToZone': _prs92ToZone,
      'points': _points.map((p) => {
        'id': p.id,
        'northing': p.northing,
        'easting': p.easting,
        'quadrant': p.quadrant?.name,
        'bearingDeg': p.bearingDeg,
        'bearingMin': p.bearingMin,
        'bearingSec': p.bearingSec,
        'distance': p.distance,
      }).toList(),
    };
    await StorageService().setString(_storageKey, json.encode(data));
    if (mounted) showToast(context, 'Traverse saved');
  }

  void _showLoadDialog() {
    final container = ProviderScope.containerOf(context, listen: false);
    final history = _loadHistory();
    final savedItem = _loadSaved();
    final theme = Theme.of(context);

    container.read(modalCountProvider.notifier).state++;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Text('Load Traverse', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  shrinkWrap: true,
                  children: [
                    if (savedItem != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('SAVED', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.muted, letterSpacing: 1)),
                      ),
                      _buildLoadCard(
                        icon: Icons.folder,
                        iconColor: AppTheme.steel,
                        title: savedItem['name'] as String? ?? 'Unnamed',
                        subtitle: () {
                          final pts = (savedItem['points'] as List?)?.length ?? 0;
                          final n = savedItem['startN'] as String? ?? '';
                          final e = savedItem['startE'] as String? ?? '';
                          return '$pts points  ·  N: $n  E: $e';
                        }(),
                        onTap: () {
                          Navigator.pop(ctx);
                          _loadFromData(savedItem);
                          WidgetsBinding.instance.addPostFrameCallback((_) => _compute());
                        },
                        onDelete: () {
                          StorageService().setString(_storageKey, '');
                          Navigator.pop(ctx);
                          _showLoadDialog();
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (history.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('HISTORY', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.muted, letterSpacing: 1)),
                      ),
                      ...history.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildLoadCard(
                            icon: Icons.route,
                            iconColor: AppTheme.brass,
                            title: item['name'] as String? ?? 'Unnamed',
                            subtitle: () {
                              final parts = <String>[];
                              final prec = item['precision'] as String? ?? '';
                              final area = item['areaSqm'] as num?;
                              final method = item['method'] as String? ?? '';
                              final date = item['date'] as String? ?? '';
                              if (method.isNotEmpty) parts.add(method);
                              if (prec.isNotEmpty) parts.add(prec);
                              if (area != null) parts.add('${area.round()} sqm');
                              if (date.isNotEmpty) parts.add(date.split('T')[0]);
                              return parts.join('  ·  ');
                            }(),
                            onTap: () {
                              Navigator.pop(ctx);
                              _loadFromData(item);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _compute());
                            },
                            onDelete: () {
                              _deleteHistoryItemAt(idx);
                              Navigator.pop(ctx);
                              _showLoadDialog();
                            },
                          ),
                        );
                      }),
                    ],
                    if (savedItem == null && history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.folder_open, size: 40, color: AppTheme.muted.withValues(alpha: 0.3)),
                              const SizedBox(height: 8),
                              Text('No saved or history traverses', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      container.read(modalCountProvider.notifier).state--;
    });
  }

  Widget _buildLoadCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
              if (onDelete != null)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: AppTheme.muted.withValues(alpha: 0.6)),
                  ),
                ),
              if (onDelete == null) const Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _loadHistory() {
    final jsonStr = StorageService().getString('gep_traverse_history');
    if (jsonStr.isEmpty) return [];
    try {
      final list = json.decode(jsonStr) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic>? _loadSaved() {
    final jsonStr = StorageService().getString(_storageKey);
    if (jsonStr.isEmpty) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _deleteHistoryItemAt(int index) {
    final jsonStr = StorageService().getString('gep_traverse_history');
    if (jsonStr.isEmpty) return;
    try {
      final list = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
      list.removeAt(index);
      StorageService().setString('gep_traverse_history', json.encode(list));
    } catch (_) {}
  }

  void _loadFromData(Map<String, dynamic> data) {
    _traverseNameCtrl.text = data['name'] as String? ?? '';
    _mode = _InputMode.values.firstWhere(
        (e) => e.name == data['mode'], orElse: () => _InputMode.bd);
    if (data['adjustmentMethod'] is String) {
      _adjustmentMethod = data['adjustmentMethod'] as String;
    }
    _hasTiePoint = data['hasTiePoint'] as bool? ?? false;
    _tieQuadrant = data['tieQuadrant'] != null
        ? Quadrant.values.byName(data['tieQuadrant'] as String)
        : null;
    _tieBearingDeg = data['tieBearingDeg'] as int? ?? 0;
    _tieBearingMin = data['tieBearingMin'] as int? ?? 0;
    _tieBearingSec = (data['tieBearingSec'] as num?)?.toDouble() ?? 0.0;
    _tieDistance = (data['tieDistance'] as num?)?.toDouble();
    _startNCtrl.text = data['startN'] as String? ?? '';
    _startECtrl.text = data['startE'] as String? ?? '';
    _crsFrom = data['crsFrom'] as String?;
    _crsTo = data['crsTo'] as String?;
    _prs92FromZone = data['prs92FromZone'] as int?;
    _prs92ToZone = data['prs92ToZone'] as int?;
    final points = data['points'] as List? ?? [];
    _points.clear();
    _nextId = 1;
    for (final p in points) {
      final pm = p as Map<String, dynamic>;
      _points.add(_PointEntry(
        id: pm['id'] as int,
        northing: (pm['northing'] as num?)?.toDouble(),
        easting: (pm['easting'] as num?)?.toDouble(),
        quadrant: pm['quadrant'] != null
            ? Quadrant.values.byName(pm['quadrant'] as String)
            : null,
        bearingDeg: pm['bearingDeg'] as int? ?? 0,
        bearingMin: pm['bearingMin'] as int? ?? 0,
        bearingSec: (pm['bearingSec'] as num?)?.toDouble() ?? 0.0,
        distance: (pm['distance'] as num?)?.toDouble(),
        latDeg: pm['latDeg'] as int? ?? 0,
        latMin: pm['latMin'] as int? ?? 0,
        latSec: (pm['latSec'] as num?)?.toDouble() ?? 0.0,
        latNorth: pm['latNorth'] as bool? ?? true,
        lonDeg: pm['lonDeg'] as int? ?? 0,
        lonMin: pm['lonMin'] as int? ?? 0,
        lonSec: (pm['lonSec'] as num?)?.toDouble() ?? 0.0,
        lonEast: pm['lonEast'] as bool? ?? true,
      ));
      if (pm['id'] as int >= _nextId) {
        _nextId = (pm['id'] as int) + 1;
      }
    }
    if (_points.isEmpty) _addPoint();
    _loadedDataHash = _inputDataJson();
  }

  Future<void> _loadFromStorage() async {
    final jsonStr = StorageService().getString(_storageKey);
    if (jsonStr.isEmpty) return;
    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      _loadFromData(data);
    } catch (_) {
      if (_points.isEmpty) _addPoint();
    }
  }

  List<(double, double)> _getGridCoords() {
    if (_mode == _InputMode.geographic) {
      final resolvedFrom =
          _resolveCrsCode(_crsFrom, _prs92FromZone) ?? 'WGS84';
      final coords = <(double, double)>[];
      for (final pt in _points) {
        final geo = _convertToDecimal(pt);
        if (geo != null) {
          final (lat, lon) = geo;
          try {
            final result = CrsService.instance.transform(
              lon, lat, 'WGS84', resolvedFrom,
            );
            coords.add((result.$2, result.$1));
          } catch (_) {}
        }
      }
      return coords;
    }
    return _points
        .where((p) => p.northing != null && p.easting != null)
        .map((p) => (p.northing!, p.easting!))
        .toList();
  }

  List<(double, double)> _getSketchCoords() {
    if (_adjustResult != null) {
      return _adjustResult!.adjustedLegs
          .map((l) => (l.adjNorthing, l.adjEasting))
          .toList();
    }
    if (_computeResult != null) {
      final stN = double.tryParse(_startNCtrl.text) ?? 0.0;
      final stE = double.tryParse(_startECtrl.text) ?? 0.0;
      final out = <(double, double)>[];
      var n = stN;
      var e = stE;
      for (final leg in _computeResult!.legs) {
        n += leg.latitude;
        e += leg.departure;
        out.add((n, e));
      }
      return out;
    }
    if (_areaResult != null && _points.isNotEmpty) {
      return _points
          .where((p) => p.northing != null && p.easting != null)
          .map((p) => (p.northing!, p.easting!))
          .toList();
    }
    return [];
  }

  List<(double, double)> _getPerimeterCoords() {
    final all = _getSketchCoords();
    // When tie point is active, the last entry is the closure back to CP1
    // (duplicating the first corner). Remove it so each corner appears once.
    if (_effectiveTiePoint && all.length > 1) {
      return all.sublist(0, all.length - 1);
    }
    return all;
  }

  List<String> _getPerimeterLabels() {
    final all = _getSketchLabels();
    if (_effectiveTiePoint && all.length > 1) {
      return all.sublist(0, all.length - 1);
    }
    return all;
  }

  List<String> _getSketchLabels() {
    if (_adjustResult != null) {
      return _adjustResult!.adjustedLegs.map((l) => l.leg.station).toList();
    }
    if (_computeResult != null) {
      return _computeResult!.legs.map((l) => l.leg.station).toList();
    }
    if (_areaResult != null) {
      return _points.asMap().entries
          .where((e) => e.value.northing != null && e.value.easting != null)
          .map((e) => '${e.key + 1}')
          .toList();
    }
    return [];
  }

  String _closureColor(String status) {
    if (status.contains('Perfect') || status.contains('Within')) {
      return 'FF2E7D32';
    }
    if (status.contains('Below')) return 'FFE8A06B';
    return 'FFC84A1E';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 8),
            _buildModeSelector(theme),
            const SizedBox(height: 8),
            _buildCrsSelector(theme),
            const SizedBox(height: 16),
            if (_mode != _InputMode.geographic) _buildStartingCoords(theme),
            const SizedBox(height: 16),
            _buildPointEntries(theme),
            const SizedBox(height: 12),
            _buildAddButton(theme),
            if (_mode == _InputMode.bd) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Adjustment:',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.65))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'Compass Rule',
                            label: Text('Compass',
                                style: TextStyle(fontSize: 12))),
                        ButtonSegment(
                            value: 'Transit Rule',
                            label: Text('Transit',
                                style: TextStyle(fontSize: 12))),
                      ],
                      selected: {_adjustmentMethod},
                      onSelectionChanged: (v) =>
                          setState(() => _adjustmentMethod = v.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _buildComputeButton(theme),
            if (widget.embedded) ...[
              const SizedBox(height: 12),
              _buildClearButton(theme),
            ],
            if (!widget.embedded) const SizedBox(height: 40),
            if (widget.embedded) const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traverse Computation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Load',
            onPressed: _showLoadDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _saveToStorage,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return TextField(
      controller: _traverseNameCtrl,
      decoration: glassInputDecoration(context,
          labelText: 'Project Name', hintText: 'e.g. Lot 234 Traverse'),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildModeSelector(ThemeData theme) {
    return Row(
      children: [
        const Spacer(),
        SegmentedButton<_InputMode>(
          segments: const [
            ButtonSegment(
                value: _InputMode.bd,
                label: Text('B&D', style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.straighten, size: 14)),
            ButtonSegment(
                value: _InputMode.ne,
                label: Text('Grid', style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.pin, size: 14)),
            ButtonSegment(
                value: _InputMode.geographic,
                label: Text('Geo', style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.public, size: 14)),
          ],
          selected: {_mode},
          onSelectionChanged: (v) =>
              setState(() => _mode = v.first),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: WidgetStatePropertyAll(
                theme.textTheme.labelSmall),
          ),
        ),
      ],
    );
  }

  Widget _buildCrsSelector(ThemeData theme) {
    final crsItems = [
      DropdownMenuItem<String?>(
        value: null,
        child: const Text('Local', style: TextStyle(fontSize: 11)),
      ),
      const DropdownMenuItem(
        value: 'WGS84',
        child: Text('WGS84', style: TextStyle(fontSize: 11)),
      ),
      const DropdownMenuItem(
        value: 'PRS92',
        child: Text('PRS92', style: TextStyle(fontSize: 11)),
      ),
    ];

    Widget zoneChips(int? selected, ValueChanged<int?> onChanged) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var z = 1; z <= 5; z++)
            Padding(
              padding: EdgeInsets.only(right: z < 5 ? 4 : 0),
              child: ChoiceChip(
                label: Text('$z', style: const TextStyle(fontSize: 10)),
                selected: selected == z,
                selectedColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                onSelected: (sel) => onChanged(sel ? z : null),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      );
    }

    final showFromZone =
        _crsFrom == 'PRS92' && _mode != _InputMode.geographic;
    final showToZone =
        _crsTo == 'PRS92' && _mode != _InputMode.geographic;
    final showAutoHint =
        _mode == _InputMode.geographic &&
        (_crsFrom == 'PRS92' || _crsTo == 'PRS92');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: glassInputDecoration(context,
                    labelText: 'CRS From', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _crsFrom,
                    isDense: true,
                    isExpanded: true,
                    items: crsItems,
                    onChanged: (v) => setState(() {
                      _crsFrom = v;
                      if (v != 'PRS92') _prs92FromZone = null;
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InputDecorator(
                decoration: glassInputDecoration(context,
                    labelText: 'CRS To', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _crsTo,
                    isDense: true,
                    isExpanded: true,
                    items: crsItems,
                    onChanged: (v) => setState(() {
                      _crsTo = v;
                      if (v != 'PRS92') _prs92ToZone = null;
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showFromZone) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text('From:',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppTheme.muted)),
              ),
              zoneChips(
                  _prs92FromZone, (v) => setState(() => _prs92FromZone = v)),
            ],
          ),
        ],
        if (showToZone) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text('To:',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppTheme.muted)),
              ),
              zoneChips(
                  _prs92ToZone, (v) => setState(() => _prs92ToZone = v)),
            ],
          ),
        ],
        if (showAutoHint)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 12, color: AppTheme.muted.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text('PTM zone auto-detected from longitude',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppTheme.muted)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStartingCoords(ThemeData theme) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  child: Checkbox(
                    value: _hasTiePoint,
                    onChanged: (v) => setState(() => _hasTiePoint = v ?? false),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text('Tie Point (BLLM / Control)',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (_hasTiePoint) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startNCtrl,
                      decoration: glassInputDecoration(context,
                          labelText: 'Northing (m)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _startECtrl,
                      decoration: glassInputDecoration(context,
                          labelText: 'Easting (m)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (_mode == _InputMode.bd) ...[
                const SizedBox(height: 8),
                Text('To Corner 1',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600, color: AppTheme.muted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<Quadrant>(
                        key: ValueKey('tieQuad_${_tieQuadrant ?? 'none'}'),
                        initialValue: _tieQuadrant,
                        isDense: true,
                        decoration: glassInputDecoration(context,
                            labelText: 'Quad', isDense: true),
                        items: Quadrant.values.map((q) => DropdownMenuItem(
                          value: q,
                          child: Text(q.name.toUpperCase(),
                              style: theme.textTheme.bodySmall),
                        )).toList(),
                        onChanged: (v) => setState(() => _tieQuadrant = v),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        decoration: glassInputDecoration(context,
                            labelText: 'Deg', isDense: true),
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodySmall,
                        controller: TextEditingController(
                            text: _tieBearingDeg > 0
                                ? _tieBearingDeg.toString()
                                : ''),
                        onChanged: (v) =>
                            _tieBearingDeg = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        decoration: glassInputDecoration(context,
                            labelText: 'Min', isDense: true),
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodySmall,
                        controller: TextEditingController(
                            text: _tieBearingMin > 0
                                ? _tieBearingMin.toString()
                                : ''),
                        onChanged: (v) =>
                            _tieBearingMin = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        decoration: glassInputDecoration(context,
                            labelText: 'Sec', isDense: true),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodySmall,
                        controller: TextEditingController(
                            text: _tieBearingSec > 0
                                ? _tieBearingSec.toString()
                                : ''),
                        onChanged: (v) =>
                            _tieBearingSec = double.tryParse(v) ?? 0.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration: glassInputDecoration(context,
                      labelText: 'Distance (m)', isDense: true),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.bodySmall,
                  controller: TextEditingController(
                      text: _tieDistance?.toStringAsFixed(3) ?? ''),
                  onChanged: (v) =>
                      _tieDistance = double.tryParse(v),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointEntries(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Text(_mode == _InputMode.bd ? 'Legs' : 'Corners',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ..._points.asMap().entries.map((entry) => _buildPointRow(
              entry.key,
              entry.value,
              theme,
            )),
      ],
    );
  }

  Widget _buildPointRow(int index, _PointEntry point, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.brass.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_badgeLabel(index),
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brass)),
                  ),
                  const Spacer(),
                  if (_points.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _removePoint(index),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _mode == _InputMode.ne
                  ? _buildCoordFields(point, theme)
                  : _mode == _InputMode.geographic
                      ? _buildGeoFields(point, theme)
                      : _buildBDFields(point, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordFields(_PointEntry point, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: glassInputDecoration(context,
                labelText: 'Northing', isDense: true),
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodySmall,
            controller: TextEditingController(
                text: point.northing?.toStringAsFixed(3) ?? ''),
            onChanged: (v) =>
                point.northing = double.tryParse(v),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: glassInputDecoration(context,
                labelText: 'Easting', isDense: true),
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodySmall,
            controller: TextEditingController(
                text: point.easting?.toStringAsFixed(3) ?? ''),
            onChanged: (v) =>
                point.easting = double.tryParse(v),
          ),
        ),
      ],
    );
  }

  Widget _buildGeoFields(_PointEntry point, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 48,
              child: InputDecorator(
                decoration: glassInputDecoration(context,
                    labelText: 'N/S', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: point.latNorth,
                    isDense: true,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('N', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: false, child: Text('S', style: TextStyle(fontSize: 11))),
                    ],
                    onChanged: (v) => setState(() => point.latNorth = v ?? true),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Lat °', isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.latDeg > 0 ? point.latDeg.toString() : ''),
                onChanged: (v) => point.latDeg = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: "'", isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.latMin > 0 ? point.latMin.toString() : ''),
                onChanged: (v) => point.latMin = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: '"', isDense: true),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.latSec > 0 ? point.latSec.toString() : ''),
                onChanged: (v) => point.latSec = double.tryParse(v) ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 48,
              child: InputDecorator(
                decoration: glassInputDecoration(context,
                    labelText: 'E/W', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: point.lonEast,
                    isDense: true,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('E', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: false, child: Text('W', style: TextStyle(fontSize: 11))),
                    ],
                    onChanged: (v) => setState(() => point.lonEast = v ?? true),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Lon °', isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.lonDeg > 0 ? point.lonDeg.toString() : ''),
                onChanged: (v) => point.lonDeg = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: "'", isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.lonMin > 0 ? point.lonMin.toString() : ''),
                onChanged: (v) => point.lonMin = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: '"', isDense: true),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.lonSec > 0 ? point.lonSec.toString() : ''),
                onChanged: (v) => point.lonSec = double.tryParse(v) ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildBDFields(_PointEntry point, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<Quadrant>(
                initialValue: point.quadrant,
                isDense: true,
                decoration: glassInputDecoration(context,
                    labelText: 'Quad', isDense: true),
                items: Quadrant.values.map((q) => DropdownMenuItem(
                  value: q,
                  child: Text(q.name.toUpperCase(),
                      style: theme.textTheme.bodySmall),
                )).toList(),
                onChanged: (v) => setState(() => point.quadrant = v),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Deg', isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.bearingDeg > 0
                        ? point.bearingDeg.toString()
                        : ''),
                onChanged: (v) =>
                    point.bearingDeg = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Min', isDense: true),
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.bearingMin > 0
                        ? point.bearingMin.toString()
                        : ''),
                onChanged: (v) =>
                    point.bearingMin = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Sec', isDense: true),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.bearingSec > 0
                        ? point.bearingSec.toString()
                        : ''),
                onChanged: (v) =>
                    point.bearingSec = double.tryParse(v) ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: glassInputDecoration(context,
                    labelText: 'Distance (m)', isDense: true),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.bodySmall,
                controller: TextEditingController(
                    text: point.distance?.toStringAsFixed(3) ?? ''),
                onChanged: (v) =>
                    point.distance = double.tryParse(v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: PressScale(
        bounce: true,
        child: OutlinedButton.icon(
          onPressed: _addPoint,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Point'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.brass.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: PressScale(
        bounce: true,
        child: OutlinedButton.icon(
          onPressed: _clearAll,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Clear'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.muted.withValues(alpha: 0.3)),
            foregroundColor: AppTheme.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildComputeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _showComputeDialog,
        icon: const Icon(Icons.calculate, size: 20),
        label: const Text('COMPUTE',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.brass,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final result = _computeResult;
    final adjust = _adjustResult;
    final area = _areaResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Results',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (_mode == _InputMode.bd && result != null) ...[
          Row(
            children: [
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(int.parse(
                          _closureColor(result.status).substring(2),
                          radix: 16) |
                      0xFF000000)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.relativePrecision,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Color(int.parse(
                            _closureColor(result.status).substring(2),
                            radix: 16) |
                        0xFF000000),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(int.parse(
                      _closureColor(result.status).substring(2),
                      radix: 16) |
                  0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          Scrollbar(
            controller: _horizontalScrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: _buildResultTable(theme, result, adjust),
            ),
          ),
          if (area != null) ...[
            const SizedBox(height: 16),
            _buildAreaCard(theme, area),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Adjustment: ',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.muted)),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _adjustmentMethod,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  style: theme.textTheme.bodySmall,
                  items: const [
                    DropdownMenuItem(
                        value: 'Compass Rule',
                        child: Text('Compass Rule (Bowditch)')),
                    DropdownMenuItem(
                        value: 'Transit Rule',
                        child: Text('Transit Rule')),
                  ],
                  onChanged: (v) {
                    if (v == null || v == _adjustmentMethod) return;
                    setState(() => _adjustmentMethod = v);
                    if (_perimeterResult != null && _tieLeg != null) {
                      // Re-adjust perimeter only, then re-merge tie leg
                      final newAdj = TraverseCalculator.adjust(
                          _perimeterResult!, method: v);
                      AreaResult? newArea;
                      if (newAdj != null) {
                        final tieRad = _tieLeg!.bearingDeg * math.pi / 180.0;
                        final tieLat = _tieLeg!.distance * math.cos(tieRad);
                        final tieDep = _tieLeg!.distance * math.sin(tieRad);
                        final tieAdjusted = AdjustedLeg(
                          leg: _tieLeg!,
                          unadjustedNorthing: _tieCp1N,
                          unadjustedEasting: _tieCp1E,
                          latitude: tieLat, departure: tieDep,
                          adjLatitude: tieLat, adjDeparture: tieDep,
                          adjNorthing: _tieCp1N, adjEasting: _tieCp1E,
                        );
                        final merged = AdjustmentResult(
                          method: newAdj.method,
                          adjustedLegs: [tieAdjusted, ...newAdj.adjustedLegs],
                          errorNorthing: newAdj.errorNorthing,
                          errorEasting: newAdj.errorEasting,
                        );
                        // Area from perimeter only
                        final cs = newAdj.adjustedLegs
                            .map((l) => (l.adjNorthing, l.adjEasting))
                            .toList();
                        if (cs.length >= 3) newArea = AreaCalculator.compute(cs);
                        setState(() {
                          _adjustResult = merged;
                          _areaResult = newArea;
                        });
                      }
                    } else if (_computeResult != null) {
                      final newAdj = TraverseCalculator.adjust(
                          _computeResult!, method: v);
                      AreaResult? newArea;
                      if (newAdj != null) {
                        final cs = newAdj.adjustedLegs
                            .map((l) => (l.adjNorthing, l.adjEasting))
                            .toList();
                        if (cs.length >= 3) newArea = AreaCalculator.compute(cs);
                      }
                      setState(() {
                        _adjustResult = newAdj;
                        _areaResult = newArea;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
        if (_mode == _InputMode.ne || _mode == _InputMode.geographic) ...[
          if (_neLegs.isNotEmpty) ...[
            Scrollbar(
              controller: _horizontalScrollCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollCtrl,
                scrollDirection: Axis.horizontal,
                child: _buildNeTable(theme),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (area != null) ...[
            _buildAreaCard(theme, area),
          ],
        ],
        if (_getSketchCoords().length >= 2) ...[
          const SizedBox(height: 20),
          Text('Boundary Sketch',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SketchPlan(
            coords: _getSketchCoords(),
            labels: _getSketchLabels(),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _showDetailedTable,
              onChanged: (v) => setState(() => _showDetailedTable = v!),
            ),
            GestureDetector(
              onTap: () => setState(() => _showDetailedTable = !_showDetailedTable),
              child: Text('Show detailed computation',
                  style: theme.textTheme.bodySmall),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportResults,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Results'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveToStorage,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultTable(
    ThemeData theme,
    TraverseComputeResult result,
    AdjustmentResult? adjust,
  ) {
    final data = adjust?.adjustedLegs ?? [];
    final useAdjust = adjust != null;

    return DataTable(
      headingRowHeight: 32,
      dataRowMinHeight: 24,
      dataRowMaxHeight: 32,
      columnSpacing: 8,
      horizontalMargin: 4,
      columns: [
        const DataColumn(label: Text('Leg', style: TextStyle(fontSize: 10))),
        const DataColumn(label: Text('Bearing', style: TextStyle(fontSize: 10))),
        const DataColumn(
            label: Text('Dist', style: TextStyle(fontSize: 10)),
            numeric: true),
        if (_showDetailedTable && useAdjust) ...[
          const DataColumn(
              label: Text('Lat', style: TextStyle(fontSize: 10)),
              numeric: true),
          const DataColumn(
              label: Text('Dep', style: TextStyle(fontSize: 10)),
              numeric: true),
          const DataColumn(
              label: Text('Cor Lat', style: TextStyle(fontSize: 10)),
              numeric: true),
          const DataColumn(
              label: Text('Cor Dep', style: TextStyle(fontSize: 10)),
              numeric: true),
        ],
        const DataColumn(
            label: Text('Northing', style: TextStyle(fontSize: 10)),
            numeric: true),
        const DataColumn(
            label: Text('Easting', style: TextStyle(fontSize: 10)),
            numeric: true),
      ],
      rows: useAdjust
          ? data.asMap().entries.map((e) {
              final i = e.key;
              final l = e.value;
              final total = data.length;
              final cells = <DataCell>[
                DataCell(Text(_legLabel(i, total),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(
                    QuadrantBearing.fromAzimuthDegrees(l.leg.bearingDeg)
                        .toFormattedString(decimals: 1),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.leg.distance.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
              ];
              if (_showDetailedTable) {
                cells.addAll([
                  DataCell(Text(l.latitude.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 10))),
                  DataCell(Text(l.departure.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 10))),
                  DataCell(Text(l.adjLatitude.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 10))),
                  DataCell(Text(l.adjDeparture.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 10))),
                ]);
              }
              cells.addAll([
                DataCell(Text(l.adjNorthing.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.adjEasting.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
              ]);
              return DataRow(cells: cells);
            }).toList()
          : result.legs.asMap().entries.map((e) {
              final i = e.key;
              final l = e.value;
              final total = result.legs.length;
              return DataRow(cells: [
                DataCell(Text(_legLabel(i, total),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(
                    QuadrantBearing.fromAzimuthDegrees(l.leg.bearingDeg)
                        .toFormattedString(decimals: 1),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.leg.distance.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.northing.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.easting.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
              ]);
            }).toList(),
    );
  }

  Widget _buildNeTable(ThemeData theme) {
    return DataTable(
      headingRowHeight: 32,
      dataRowMinHeight: 24,
      dataRowMaxHeight: 32,
      columnSpacing: 8,
      horizontalMargin: 4,
      columns: [
        const DataColumn(label: Text('Leg', style: TextStyle(fontSize: 10))),
        const DataColumn(label: Text('Bearing', style: TextStyle(fontSize: 10))),
        const DataColumn(
            label: Text('Dist', style: TextStyle(fontSize: 10)),
            numeric: true),
        if (_showDetailedTable) ...[
          const DataColumn(
              label: Text('ΔN', style: TextStyle(fontSize: 10)),
              numeric: true),
          const DataColumn(
              label: Text('ΔE', style: TextStyle(fontSize: 10)),
              numeric: true),
        ],
        const DataColumn(
            label: Text('Northing', style: TextStyle(fontSize: 10)),
            numeric: true),
        const DataColumn(
            label: Text('Easting', style: TextStyle(fontSize: 10)),
            numeric: true),
      ],
      rows: _neLegs.map((l) {
            final cells = <DataCell>[
              DataCell(Text(l.label,
                  style: const TextStyle(fontSize: 10))),
              DataCell(Text(
                  QuadrantBearing.fromAzimuthDegrees(l.bearingDeg)
                      .toFormattedString(decimals: 1),
                  style: const TextStyle(fontSize: 10))),
              DataCell(Text(l.distance.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 10))),
            ];
            if (_showDetailedTable) {
              cells.addAll([
                DataCell(Text(l.dN.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
                DataCell(Text(l.dE.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10))),
              ]);
            }
            cells.addAll([
              DataCell(Text(l.northing.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 10))),
              DataCell(Text(l.easting.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 10))),
            ]);
            return DataRow(cells: cells);
          })
          .toList(),
    );
  }




  Widget _buildAreaCard(ThemeData theme, AreaResult area) {
    final roundedSqm = area.areaSqM.round();
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: AppTheme.brass.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.square_foot, color: AppTheme.brass, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted)),
                Text(
                  '$roundedSqm sqm',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text('Calculated Area: ${area.areaSqM.toStringAsFixed(2)} sqm',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted)),
                Text('Perimeter: ${area.perimeterM.toStringAsFixed(3)} m',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportResults() {
    final result = _computeResult;
    final adjust = _adjustResult;
    final area = _areaResult;
    final buffer = StringBuffer();
    buffer.writeln('${_traverseNameCtrl.text.isNotEmpty ? _traverseNameCtrl.text : 'Traverse'} (${_mode.name.toUpperCase()})');
    buffer.writeln('');

    if (_mode == _InputMode.bd) {
      if (adjust != null) {
        buffer.writeln('Method: ${adjust.method}');
        buffer.writeln(
            'Error N: ${adjust.errorNorthing.toStringAsFixed(4)}, Error E: ${adjust.errorEasting.toStringAsFixed(4)}');
        buffer.writeln('');
        buffer.writeln(
            'Sta\tBearing\tDist\tLat\tDep\tCor Lat\tCor Dep\tNorthing\tEasting');
        final adjList = adjust.adjustedLegs;
        for (var i = 0; i < adjList.length; i++) {
          final l = adjList[i];
          final bearing =
              QuadrantBearing.fromAzimuthDegrees(l.leg.bearingDeg)
                  .toFormattedString();
          buffer.writeln(
              '${_legLabel(i, adjList.length)}\t$bearing\t${l.leg.distance.toStringAsFixed(3)}\t${l.latitude.toStringAsFixed(3)}\t${l.departure.toStringAsFixed(3)}\t${l.adjLatitude.toStringAsFixed(3)}\t${l.adjDeparture.toStringAsFixed(3)}\t${l.adjNorthing.toStringAsFixed(3)}\t${l.adjEasting.toStringAsFixed(3)}');
        }
      } else if (result != null) {
        buffer.writeln('Sta\tBearing\tDist\tNorthing\tEasting');
        for (var i = 0; i < result.legs.length; i++) {
          final l = result.legs[i];
          final bearing =
              QuadrantBearing.fromAzimuthDegrees(l.leg.bearingDeg)
                  .toFormattedString();
          buffer.writeln(
              '${_legLabel(i, result.legs.length)}\t$bearing\t${l.leg.distance.toStringAsFixed(3)}\t${l.northing.toStringAsFixed(3)}\t${l.easting.toStringAsFixed(3)}');
        }
      }

      if (result != null) {
        buffer.writeln('');
        buffer.writeln('Precision: ${result.relativePrecision}');
        buffer.writeln('Status: ${result.status}');
      }
    } else {
      buffer.writeln('Leg\tBearing\tDist\tΔN\tΔE\tNorthing\tEasting');
      for (final l in _neLegs) {
        final bearing =
            QuadrantBearing.fromAzimuthDegrees(l.bearingDeg)
                .toFormattedString();
        buffer.writeln(
            '${l.label}\t$bearing\t${l.distance.toStringAsFixed(3)}\t${l.dN.toStringAsFixed(3)}\t${l.dE.toStringAsFixed(3)}\t${l.northing.toStringAsFixed(3)}\t${l.easting.toStringAsFixed(3)}');
      }
    }

    if (area != null) {
      buffer.writeln('');
      buffer.writeln('Area: ${area.areaSqM.round()} sqm');
      buffer.writeln('Calculated Area: ${area.areaSqM.toStringAsFixed(2)} sqm');
      buffer.writeln('Perimeter: ${area.perimeterM.toStringAsFixed(3)} m');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showToast(context, 'Results copied to clipboard');
  }

  Future<bool> _computeIfNeeded() async {
    if (_computeResult != null || _areaResult != null) return true;
    await _compute();
    return _computeResult != null || _areaResult != null;
  }

  Future<void> _showComputeDialog() async {
    List<(double, double)> coords;
    List<String> labels;

    final fromGrid = _mode == _InputMode.ne || _mode == _InputMode.geographic;
    if (fromGrid) {
      coords = _getGridCoords();
      labels = [];
      for (var i = 0; i < coords.length; i++) labels.add('${i + 1}');
    } else {
      final ok = await _computeIfNeeded();
      if (!ok) {
        if (context.mounted) showToast(context, 'Add at least one valid leg');
        return;
      }
      coords = _getPerimeterCoords();
      labels = _getPerimeterLabels();
    }

    if (coords.isEmpty) {
      if (context.mounted) showToast(context, 'Enter at least one coordinate');
      return;
    }

    final points = <(double n, double e, String label)>[];
    for (var i = 0; i < coords.length; i++) {
      points.add((coords[i].$1, coords[i].$2, i < labels.length ? labels[i] : '${i + 1}'));
    }

    final title = _traverseNameCtrl.text.isNotEmpty
        ? _traverseNameCtrl.text
        : 'Traverse';

    if (!context.mounted) return;
    final resolvedFrom =
        _resolveCrsCode(_crsFrom, _prs92FromZone);
    final resolvedTo =
        _resolveCrsCode(_crsTo, _prs92ToZone);
    showComputeDialog(
      context,
      points: points,
      crsFrom: resolvedFrom,
      crsTo: resolvedTo,
      title: title,
    );
  }

  Future<void> triggerComputeDialog() => _showComputeDialog();
  void triggerLoadDialog() => _showLoadDialog();
  Future<void> triggerSave() => _saveToStorage();
  void triggerClear() => _clearAll();

  void loadFromData(Map<String, dynamic> data) {
    _loadFromData(data);
    WidgetsBinding.instance.addPostFrameCallback((_) => _compute());
  }
}
