import 'package:flutter/material.dart';

class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool bounce;
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.92,
    this.bounce = false,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = widget.scale),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: widget.bounce ? 400 : 100),
        curve: widget.bounce ? Curves.elasticOut : Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
