import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/uiprovider.dart';

class CalculatorSheet extends StatefulWidget {
  final String initialValue;

  const CalculatorSheet({super.key, this.initialValue = '0'});

  static Future<double?> show(BuildContext context, {String initialValue = '0'}) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(modalCountProvider.notifier).state++;
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalculatorSheet(initialValue: initialValue),
    ).whenComplete(() {
      container.read(modalCountProvider.notifier).state--;
    });
  }

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _display = '0';
  double? _operand;
  String? _operator;
  bool _fresh = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != '0') {
      _display = widget.initialValue;
    }
  }

  void _tap(String c) {
    setState(() {
      if (c == 'C') {
        _display = '0';
        _operand = null;
        _operator = null;
        _fresh = true;
      } else if (c == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (c == '.') {
        if (!_display.contains('.')) _display += '.';
      } else if (c == '+' || c == '-' || c == '×' || c == '÷') {
        _operand = double.tryParse(_display);
        _operator = c;
        _fresh = true;
      } else if (c == '=') {
        final right = double.tryParse(_display);
        if (_operand != null && right != null && _operator != null) {
          final result = _compute(_operand!, right, _operator!);
          _display = _format(result);
        }
        _operand = null;
        _operator = null;
        _fresh = true;
      } else {
        if (_fresh || _display == '0') {
          _display = c;
          _fresh = false;
        } else {
          _display += c;
        }
      }
    });
  }

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b != 0 ? a / b : 0;
      default: return b;
    }
  }

  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toStringAsFixed(0);
    }
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final displayBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final opColor = theme.colorScheme.primary;
    final numColor = isDark ? Colors.white : Colors.black87;
    final funcColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: displayBg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.centerRight,
            child: Text(_display, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: numColor)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                _buildRow(['C', '⌫', '÷'], [funcColor, funcColor, opColor]),
                const SizedBox(height: 8),
                _buildRow(['7', '8', '9', '×'], [numColor, numColor, numColor, opColor]),
                const SizedBox(height: 8),
                _buildRow(['4', '5', '6', '-'], [numColor, numColor, numColor, opColor]),
                const SizedBox(height: 8),
                _buildRow(['1', '2', '3', '+'], [numColor, numColor, numColor, opColor]),
                const SizedBox(height: 8),
                _buildRow(['0', '.', '='], [numColor, numColor, opColor], wide0: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final result = double.tryParse(_display) ?? 0;
                  Navigator.of(context).pop(result);
                },
                child: const Text('Use'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> labels, List<Color> colors, {bool wide0 = false}) {
    return Row(
      children: labels.asMap().entries.map((entry) {
        final i = entry.key;
        final label = entry.value;
        final isWide = wide0 && label == '0';
        return Expanded(
          flex: isWide ? 2 : 1,
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
            child: _CalcButton(label: label, color: i < colors.length ? colors[i] : colors.last, onTap: () => _tap(label)),
          ),
        );
      }).toList(),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);

    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: color),
        ),
        child: Text(label),
      ),
    );
  }
}
