import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants.dart';

class SketchPlan extends StatelessWidget {
  final List<(double northing, double easting)> coords;
  final List<String> labels;
  final double height;

  const SketchPlan({
    super.key,
    required this.coords,
    required this.labels,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SketchPlanPainter(coords: coords, labels: labels),
      ),
    );
  }
}

class _SketchPlanPainter extends CustomPainter {
  final List<(double northing, double easting)> coords;
  final List<String> labels;
  static const double _pad = 28;
  static const double _ptRadius = 3.5;

  _SketchPlanPainter({required this.coords, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (coords.length < 2) return;

    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    var minN = double.infinity, maxN = double.negativeInfinity;
    var minE = double.infinity, maxE = double.negativeInfinity;
    for (final (n, e) in coords) {
      if (n < minN) minN = n;
      if (n > maxN) maxN = n;
      if (e < minE) minE = e;
      if (e > maxE) maxE = e;
    }

    final rn = maxN - minN;
    final re = maxE - minE;
    if (rn < 1e-10 && re < 1e-10) return;

    final sx = (w - 2 * _pad) / (re > 0 ? re : 1);
    final sy = (h - 2 * _pad) / (rn > 0 ? rn : 1);
    final scale = sx < sy ? sx : sy;
    final cN = (maxN + minN) / 2;
    final cE = (maxE + minE) / 2;
    final cx = w / 2;
    final cy = h / 2;

    Offset toScr(double n, double e) => Offset(cx + (e - cE) * scale, cy - (n - cN) * scale);

    final pts = coords.map((c) => toScr(c.$1, c.$2)).toList();

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) { path.lineTo(p.dx, p.dy); }
    path.close();

    canvas.drawPath(path, Paint()
      ..color = AppTheme.brass.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, Paint()
      ..color = AppTheme.brass
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    final dot = Paint()..color = AppTheme.steel;
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], _ptRadius, dot);
      final lbl = labels.length > i ? labels[i] : '${i + 1}';
      final tp = TextPainter(
        text: TextSpan(
          text: lbl,
          style: const TextStyle(color: AppTheme.steel, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pts[i].dx + 6, pts[i].dy - tp.height - 4));
    }

    _drawNorthArrow(canvas, w, h);
    _drawScaleBar(canvas, w, h, scale);
  }

  void _drawNorthArrow(Canvas canvas, double w, double h) {
    final x = w - _pad - 16;
    const y = _pad + 24;
    final paint = Paint()
      ..color = AppTheme.steel
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(x, y + 16), Offset(x, y - 10), paint);

    canvas.drawPath(
      Path()
        ..moveTo(x, y - 18)
        ..lineTo(x - 6, y - 6)
        ..lineTo(x + 6, y - 6)
        ..close(),
      Paint()..color = AppTheme.steel..style = PaintingStyle.fill,
    );

    final nTp = TextPainter(
      text: const TextSpan(text: 'N', style: TextStyle(color: AppTheme.steel, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    nTp.paint(canvas, Offset(x - nTp.width / 2, y - nTp.height - 22));
  }

  void _drawScaleBar(Canvas canvas, double w, double h, double scale) {
    const barX = _pad + 8;
    final barY = h - _pad - 12;
    final groundDist = (w - 3 * _pad) / scale;
    final niceDist = _niceScale(groundDist);
    final barPx = niceDist * scale;

    final paint = Paint()
      ..color = AppTheme.steel
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(barX, barY), Offset(barX + barPx, barY), paint);
    canvas.drawLine(Offset(barX, barY - 4), Offset(barX, barY + 4), paint);
    canvas.drawLine(Offset(barX + barPx, barY - 4), Offset(barX + barPx, barY + 4), paint);

    final scaleTp = TextPainter(
      text: TextSpan(text: _fmtDist(niceDist), style: const TextStyle(color: AppTheme.steel, fontSize: 9)),
      textDirection: TextDirection.ltr,
    )..layout();
    scaleTp.paint(canvas, Offset(barX + barPx / 2 - scaleTp.width / 2, barY + 6));
  }

  double _niceScale(double meters) {
    if (meters <= 0) return 10;
    final exp = math.pow(10, (math.log(meters) / math.ln10).floor()).toDouble();
    final fraction = meters / exp;
    if (fraction < 2) return exp;
    if (fraction < 5) return 2 * exp;
    return 5 * exp;
  }

  String _fmtDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    final rounded = (meters / 10).round() * 10;
    return '${rounded.toInt()} m';
  }

  @override
  bool shouldRepaint(covariant _SketchPlanPainter oldDelegate) => true;
}
