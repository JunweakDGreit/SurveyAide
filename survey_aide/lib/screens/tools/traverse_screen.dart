import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../services/traverse_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/sketch_plan_painter.dart';
import '../../widgets/toast.dart';


enum _InputMode { bd, ne }

class _PointEntry {
  int id;
  double? northing;
  double? easting;
  Quadrant? quadrant;
  int bearingDeg;
  int bearingMin;
  double bearingSec;
  double? distance;

  _PointEntry({
    required this.id,
    this.northing,
    this.easting,
    this.quadrant,
    this.bearingDeg = 0,
    this.bearingMin = 0,
    this.bearingSec = 0.0,
    this.distance,
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

  const TraverseScreen({super.key, this.initialData});

  @override
  State<TraverseScreen> createState() => _TraverseScreenState();
}

class _TraverseScreenState extends State<TraverseScreen> {
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
    if (_mode == _InputMode.ne) return '${index + 1}';
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

    } else {
      // N/E mode – area only
      final coords = <(double, double)>[];
      for (final point in _points) {
        if (point.northing != null && point.easting != null) {
          coords.add((point.northing!, point.easting!));
        }
      }

      // Compute inverse legs (consecutive pairs)
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
      // Closing leg back to station 1
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
  }

  void _saveHistory(TraverseComputeResult? result, AdjustmentResult? adjust, AreaResult? area) {
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
    setState(() {
      _points.clear();
      _computeResult = null;
      _adjustResult = null;
      _areaResult = null;
      _showResults = false;
      _mode = _InputMode.bd;
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
    });
    _addPoint();
  }

  Future<void> _saveToStorage() async {
    final data = {
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
      }).toList(),
    };
    await StorageService().setString(_storageKey, json.encode(data));
    if (mounted) showToast(context, 'Traverse saved');
  }

  void _loadFromData(Map<String, dynamic> data) {
    _traverseNameCtrl.text = data['name'] as String? ?? '';
    _mode = _InputMode.values.firstWhere(
        (e) => e.name == data['mode'], orElse: () => _InputMode.bd);
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
      ));
      if (pm['id'] as int >= _nextId) {
        _nextId = (pm['id'] as int) + 1;
      }
    }
    if (_points.isEmpty) _addPoint();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traverse Computation'),
        actions: [
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 8),
              _buildModeSelector(theme),
              const SizedBox(height: 16),
              _buildStartingCoords(theme),
              const SizedBox(height: 16),
              _buildPointEntries(theme),
              const SizedBox(height: 12),
              _buildAddButton(theme),
              const SizedBox(height: 20),
              _buildComputeButton(theme),
              if (_showResults && (_computeResult != null || _areaResult != null)) ...[
                const SizedBox(height: 20),
                _buildResults(theme),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return TextField(
      controller: _traverseNameCtrl,
      decoration: glassInputDecoration(context,
          labelText: 'Traverse Name', hintText: 'e.g. Lot 234 Traverse'),
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
                label: Text('N/E', style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.pin, size: 14)),
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

  Widget _buildStartingCoords(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
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
                      width: 70,
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.5)),
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

  Widget _buildBDFields(_PointEntry point, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 70,
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
      child: OutlinedButton.icon(
        onPressed: _addPoint,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Point'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.brass.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildComputeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _processing ? null : _compute,
        icon: _processing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate),
        label: Text(_processing ? 'Computing...' : 'Compute'),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.brass,
          foregroundColor: Colors.white,
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
            thumbVisibility: true,
            child: SingleChildScrollView(
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
        if (_mode == _InputMode.ne) ...[
          if (_neLegs.isNotEmpty) ...[
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
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
    return Card(
      elevation: 0,
      color: AppTheme.brass.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppTheme.brass.withValues(alpha: 0.3)),
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
                Text('Computed Area',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted)),
                Text(
                  '${area.areaSqM.toStringAsFixed(2)} sqm  (${area.areaHectares.toStringAsFixed(4)} ha)',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
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
      buffer.writeln('Area: ${area.areaSqM.toStringAsFixed(2)} sqm');
      buffer.writeln('Area: ${area.areaHectares.toStringAsFixed(4)} ha');
      buffer.writeln('Perimeter: ${area.perimeterM.toStringAsFixed(3)} m');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showToast(context, 'Results copied to clipboard');
  }
}
