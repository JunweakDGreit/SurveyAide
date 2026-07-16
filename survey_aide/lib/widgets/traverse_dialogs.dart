import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../services/traverse_service.dart';
import '../services/crs_service.dart';

// ═══════════════════════════════════════════
// UNIFIED COMPUTE DIALOG
// ═══════════════════════════════════════════

enum _GeoFormat { dms, decimal }

class _ComputePoint {
  final String label;
  final double northing, easting;
  const _ComputePoint(this.label, this.northing, this.easting);
}

void showComputeDialog(
  BuildContext context, {
  required List<(double n, double e, String label)> points,
  String? crsFrom,
  String? crsTo,
  String title = '',
}) {
  Navigator.of(context).push(_DialogRoute(
    builder: (_) => _ComputeDialogContent(
      points: points.map((p) => _ComputePoint(p.$3, p.$1, p.$2)).toList(),
      crsFrom: crsFrom,
      crsTo: crsTo,
      dialogTitle: title,
    ),
  ));
}

class _ComputeRow {
  final String label;
  final double northing, easting;
  final String? sourceGeo;
  final String? targetGeo;
  const _ComputeRow(
      this.label, this.northing, this.easting, this.sourceGeo, this.targetGeo);
}

class _ComputeDialogContent extends StatefulWidget {
  final List<_ComputePoint> points;
  final String? crsFrom;
  final String? crsTo;
  final String dialogTitle;
  const _ComputeDialogContent({
    required this.points,
    required this.crsFrom,
    required this.crsTo,
    required this.dialogTitle,
  });

  @override
  State<_ComputeDialogContent> createState() => _ComputeDialogContentState();
}

class _ComputeDialogContentState extends State<_ComputeDialogContent> {
  _GeoFormat _geoFormat = _GeoFormat.dms;
  bool _loading = true;
  String? _error;
  List<_ComputeRow> _rows = [];
  LotDataResult? _areaResult;
  final _horizontalCtrl = ScrollController();

  bool get _showSourceGeo => widget.crsFrom != null;
  bool get _showTargetGeo => widget.crsTo != null;

  @override
  void initState() {
    super.initState();
    _computeAll();
  }

  @override
  void dispose() {
    _horizontalCtrl.dispose();
    super.dispose();
  }

  void _computeAll() {
    try {
      setState(() => _loading = true);
      final rows = <_ComputeRow>[];
      final fmt = _geoFormat;

      for (final pt in widget.points) {
        String? sourceStr;
        String? targetStr;

        if (_showSourceGeo) {
          final geo = CrsService.instance.transform(
              pt.easting, pt.northing, widget.crsFrom!,
              CrsService.geographicFor(widget.crsFrom!));
          sourceStr = _formatGeo(geo.$2, geo.$1, fmt);
        }

        if (_showTargetGeo) {
          final from = widget.crsFrom ?? 'WGS84';
          final proj = CrsService.instance.transform(
              pt.easting, pt.northing, from, widget.crsTo!);
          final geo = CrsService.instance.transform(
              proj.$1, proj.$2, widget.crsTo!,
              CrsService.geographicFor(widget.crsTo!));
          targetStr = _formatGeo(geo.$2, geo.$1, fmt);
        }

        rows.add(_ComputeRow(
            pt.label, pt.northing, pt.easting, sourceStr, targetStr));
      }

      LotDataResult? area;
      if (widget.points.length >= 3) {
        final coords = <(double, double)>[];
        for (final pt in widget.points) {
          coords.add((pt.northing, pt.easting));
        }
        if (coords.first.$1 != coords.last.$1 ||
            coords.first.$2 != coords.last.$2) {
          coords.add(coords.first);
        }
        area = LotDataComputer.compute(coords);
      }

      setState(() {
        _rows = rows;
        _areaResult = area;
        _error = null;
        _loading = false;
      });
    } catch (ex) {
      setState(() {
        _error = ex.toString();
        _loading = false;
      });
    }
  }

  String _formatGeo(double lat, double lon, _GeoFormat fmt) {
    if (fmt == _GeoFormat.dms) {
      final latDir = lat >= 0 ? 'N' : 'S';
      final lonDir = lon >= 0 ? 'E' : 'W';
      final latAbs = lat.abs();
      final lonAbs = lon.abs();
      final latD = latAbs.floor();
      final latM = ((latAbs - latD) * 60).floor();
      final latS = (latAbs - latD - latM / 60.0) * 3600;
      final lonD = lonAbs.floor();
      final lonM = ((lonAbs - lonD) * 60).floor();
      final lonS = (lonAbs - lonD - lonM / 60.0) * 3600;
      return '${latD}°${latM.toString().padLeft(2, '0')}\'${latS.toStringAsFixed(1).padLeft(4, '0')}"$latDir  '
          '${lonD}°${lonM.toString().padLeft(2, '0')}\'${lonS.toStringAsFixed(1).padLeft(4, '0')}"$lonDir';
    }
    return '${lat.toStringAsFixed(7)}°  ${lon.toStringAsFixed(7)}°';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final columns = <DataColumn>[
      const DataColumn(
          label: Text('Corner', style: TextStyle(fontSize: 10))),
      const DataColumn(
          label: Text('Northing', style: TextStyle(fontSize: 10)),
          numeric: true),
      const DataColumn(
          label: Text('Easting', style: TextStyle(fontSize: 10)),
          numeric: true),
    ];
    if (_showSourceGeo) {
      columns.add(DataColumn(
        label: Text(CrsService.labelFor(CrsService.geographicFor(widget.crsFrom!)),
            style: const TextStyle(fontSize: 9)),
      ));
    }
    if (_showTargetGeo) {
      columns.add(DataColumn(
        label: Text(CrsService.labelFor(CrsService.geographicFor(widget.crsTo!)),
            style: const TextStyle(fontSize: 9)),
      ));
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compute',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (widget.dialogTitle.isNotEmpty)
                        Text(widget.dialogTitle,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppTheme.muted)),
                      Text(_crsLabel(),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.muted, fontSize: 10)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Controls
          if (_showSourceGeo || _showTargetGeo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<_GeoFormat>(
                segments: const [
                  ButtonSegment(
                    value: _GeoFormat.dms,
                    label: Text('DMS', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: _GeoFormat.decimal,
                    label: Text('DD', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_geoFormat},
                onSelectionChanged: (v) => setState(() {
                  _geoFormat = v.first;
                  _computeAll();
                }),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          const SizedBox(height: 12),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child:
                  CircularProgressIndicator(strokeWidth: 3),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $_error',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.marker)),
            )
          else
            Flexible(
              child: Scrollbar(
                controller: _horizontalCtrl,
                child: SingleChildScrollView(
                  controller: _horizontalCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      DataTable(
                        headingRowHeight: 30,
                        dataRowMinHeight: 20,
                        dataRowMaxHeight: 26,
                        columnSpacing: 8,
                        horizontalMargin: 4,
                        columns: columns,
                        rows: _rows
                            .map((r) => DataRow(cells: [
                                  DataCell(Text(r.label,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.w600))),
                                  DataCell(Text(
                                      r.northing
                                          .toStringAsFixed(3),
                                      style: const TextStyle(
                                          fontSize: 10))),
                                  DataCell(Text(
                                      r.easting
                                          .toStringAsFixed(3),
                                      style: const TextStyle(
                                          fontSize: 10))),
                                  if (_showSourceGeo)
                                    DataCell(Text(
                                        r.sourceGeo ?? '',
                                        style: const TextStyle(
                                            fontSize: 9))),
                                  if (_showTargetGeo)
                                    DataCell(Text(
                                        r.targetGeo ?? '',
                                        style: const TextStyle(
                                            fontSize: 9))),
                                ]))
                            .toList(),
                      ),
                      if (_areaResult != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 4),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'DMD Area Computation',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          fontWeight:
                                              FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  'Area: ${_areaResult!.areaSqMRounded} sqm  (${_areaResult!.areaHaRounded} ha)',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          fontWeight:
                                              FontWeight.w600)),
                              Text(
                                  'Perimeter: ${_areaResult!.perimeter.toStringAsFixed(3)} m',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppTheme.muted)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _rows.isNotEmpty
                    ? () => _copyResult(context)
                    : null,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy All'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _crsLabel() {
    final from = widget.crsFrom;
    final to = widget.crsTo;
    if (from == null && to == null) return 'Local CRS';
    if (to == null) return 'CRS: ${CrsService.labelFor(from!)}';
    if (from == null) return 'CRS: Local → ${CrsService.labelFor(to)}';
    return 'CRS: ${CrsService.labelFor(from)} → ${CrsService.labelFor(to)}';
  }

  void _copyResult(BuildContext context) {
    final buf = StringBuffer();
    buf.writeln(
        'Compute — ${widget.dialogTitle.isNotEmpty ? widget.dialogTitle : 'Traverse'}');
    buf.writeln(_crsLabel());
    buf.writeln('');

    buf.write('Corner\tNorthing\tEasting');
    if (_showSourceGeo) {
      buf.write('\t${CrsService.labelFor(widget.crsFrom!)}');
    }
    if (_showTargetGeo) {
      buf.write('\t${CrsService.labelFor(widget.crsTo!)}');
    }
    buf.writeln('');

    for (final r in _rows) {
      buf.write(
          '${r.label}\t${r.northing.toStringAsFixed(3)}\t${r.easting.toStringAsFixed(3)}');
      if (_showSourceGeo) buf.write('\t${r.sourceGeo}');
      if (_showTargetGeo) buf.write('\t${r.targetGeo}');
      buf.writeln('');
    }

    if (_areaResult != null) {
      buf.writeln('');
      buf.writeln(
          'Area: ${_areaResult!.areaSqMRounded} sqm  (${_areaResult!.areaHaRounded} ha)');
      buf.writeln(
          'Perimeter: ${_areaResult!.perimeter.toStringAsFixed(3)} m');
    }

    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('All data copied'),
          duration: Duration(seconds: 2)),
    );
  }
}

// ═══════════════════════════════════════════
// LOT DATA SHEET (GSD-B-11) DIALOG
// ═══════════════════════════════════════════

void showLotDataSheet(
  BuildContext context, {
  required List<(double n, double e)> coords,
  required String title,
  required String method,
  String? date,
  List<String>? stations,
  List<String>? bearings,
  List<double>? distances,
}) {
  final points = List<(double, double)>.from(coords);
  if (points.length < 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Need at least 3 points')),
    );
    return;
  }

  if (points.first.$1 != points.last.$1 ||
      points.first.$2 != points.last.$2) {
    points.add(points.first);
  }

  final result = LotDataComputer.compute(points,
      stations: stations, bearings: bearings, distances: distances);
  final dateStr =
      date ?? DateTime.now().toLocal().toString().split(' ')[0];

  Navigator.of(context).push(_DialogRoute(
    builder: (_) => _LotDataSheetContent(
      title: title,
      result: result,
      method: method,
      date: dateStr,
    ),
  ));
}

class _LotDataSheetContent extends StatelessWidget {
  final String title;
  final LotDataResult result;
  final String method;
  final String date;

  const _LotDataSheetContent({
    required this.title,
    required this.result,
    required this.method,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = result.rows;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Lot Data Computation (GSD-B-11)',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$title  ·  $method  ·  $date',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 30,
                  dataRowMinHeight: 20,
                  dataRowMaxHeight: 26,
                  columnSpacing: 6,
                  horizontalMargin: 2,
                  columns: const [
                    DataColumn(
                        label: Text('Sta', style: TextStyle(fontSize: 9))),
                    DataColumn(
                        label: Text('Bearing', style: TextStyle(fontSize: 9))),
                    DataColumn(
                        label: Text('Dist', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('Lat', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('Dep', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('DMD', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('2×Area', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('Northing', style: TextStyle(fontSize: 9)),
                        numeric: true),
                    DataColumn(
                        label: Text('Easting', style: TextStyle(fontSize: 9)),
                        numeric: true),
                  ],
                  rows: [
                    ...rows.asMap().entries.map((e) {
                      final r = e.value;
                      return DataRow(cells: [
                        DataCell(Text(r.station,
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.bearingDms,
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.distance.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.latitude.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.departure.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.dmd.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.doubleArea.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.northing.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                        DataCell(Text(r.easting.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 9))),
                      ]);
                    }),
                    DataRow(cells: [
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                      DataCell(Text(result.sumLatitude.toStringAsFixed(3),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brass))),
                      DataCell(Text(result.sumDeparture.toStringAsFixed(3),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brass))),
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                      DataCell(Text(result.doubleAreaTotal.toStringAsFixed(3),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brass))),
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                      const DataCell(Text('', style: TextStyle(fontSize: 9))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Area: ${result.areaSqMRounded} sqm',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                        '${result.areaHaRounded} ha  ·  Perimeter: ${result.perimeter.toStringAsFixed(3)} m',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyLdc(context),
                    icon: const Icon(Icons.copy, size: 14),
                    label:
                        const Text('Copy', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyGsd11(context),
                    icon: const Icon(Icons.description_outlined, size: 14),
                    label:
                        const Text('GSD-B-11', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyLdc(BuildContext context) {
    final buf = StringBuffer();
    buf.writeln('LOT DATA COMPUTATION');
    buf.writeln('Title: $title');
    buf.writeln('Method: $method');
    buf.writeln('Date: $date');
    buf.writeln('');
    buf.writeln(
        'Sta\tBearing\tDist\tLat\tDep\tDMD\t2×Area\tNorthing\tEasting');
    for (final r in result.rows) {
      buf.writeln(
          '${r.station}\t${r.bearingDms}\t${r.distance.toStringAsFixed(3)}\t${r.latitude.toStringAsFixed(3)}\t${r.departure.toStringAsFixed(3)}\t${r.dmd.toStringAsFixed(3)}\t${r.doubleArea.toStringAsFixed(3)}\t${r.northing.toStringAsFixed(3)}\t${r.easting.toStringAsFixed(3)}');
    }
    buf.writeln('');
    buf.writeln(
        'ΣLat: ${result.sumLatitude.toStringAsFixed(3)}  ΣDep: ${result.sumDeparture.toStringAsFixed(3)}');
    buf.writeln('2×Area: ${result.doubleAreaTotal.toStringAsFixed(3)}');
    buf.writeln('Area: ${result.areaSqMRounded} sqm');
    buf.writeln('Area: ${result.areaHaRounded} ha');
    buf.writeln('Perimeter: ${result.perimeter.toStringAsFixed(3)} m');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Lot data copied'), duration: Duration(seconds: 2)),
    );
  }

  void _copyGsd11(BuildContext context) {
    final buf = StringBuffer();
    buf.writeln('══════════════════════════════════════════════════');
    buf.writeln('       LOT DATA COMPUTATION SHEET');
    buf.writeln('            (GSD-B-11)');
    buf.writeln('══════════════════════════════════════════════════');
    buf.writeln('Title: $title');
    buf.writeln('Method: $method  |  Date: $date');
    buf.writeln('──────────────────────────────────────────────────');
    buf.writeln(
        '│ Sta │ Bearing        │ Dist (m) │ Lat      │ Dep      │ DMD      │ 2×Area   │ Northing  │ Easting   │');
    buf.writeln(
        '├─────┼────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┼───────────┼───────────┤');
    for (final r in result.rows) {
      final line =
          '│ ${r.station.padRight(3)} │ ${r.bearingDms.padRight(14)} │ ${r.distance.toStringAsFixed(3).padLeft(8)} │ ${r.latitude.toStringAsFixed(3).padLeft(8)} │ ${r.departure.toStringAsFixed(3).padLeft(8)} │ ${r.dmd.toStringAsFixed(3).padLeft(8)} │ ${r.doubleArea.toStringAsFixed(3).padLeft(8)} │ ${r.northing.toStringAsFixed(3).padLeft(9)} │ ${r.easting.toStringAsFixed(3).padLeft(9)} │';
      buf.writeln(line);
    }
    buf.writeln(
        '├─────┼────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┼───────────┼───────────┤');
    buf.writeln(
        '│     │                │          │ ${result.sumLatitude.toStringAsFixed(3).padLeft(8)} │ ${result.sumDeparture.toStringAsFixed(3).padLeft(8)} │          │ ${result.doubleAreaTotal.toStringAsFixed(3).padLeft(8)} │           │           │');
    buf.writeln('──────────────────────────────────────────────────');
    buf.writeln(
        'Area: ${result.areaSqMRounded} sqm  (${result.areaHaRounded} ha)');
    buf.writeln('Perimeter: ${result.perimeter.toStringAsFixed(3)} m');
    buf.writeln('══════════════════════════════════════════════════');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('GSD-B-11 format copied'),
          duration: Duration(seconds: 2)),
    );
  }
}

// ═══════════════════════════════════════════
// CUSTOM DIALOG ROUTE (transparent barrier)
// ═══════════════════════════════════════════

class _DialogRoute extends PopupRoute {
  final WidgetBuilder builder;
  _DialogRoute({required this.builder});

  @override
  Color? get barrierColor => Colors.black54;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dismiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: builder(context),
    );
  }
}
