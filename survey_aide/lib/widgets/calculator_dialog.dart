import 'package:flutter/material.dart';
import '../core/constants.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _currentNumber = '0';
  String? _pendingOp;
  double? _operand;
  double? _result;

  void _onDigit(String d) {
    setState(() {
      if (_currentNumber == '0' && d != '.') {
        _currentNumber = d;
      } else {
        _currentNumber += d;
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      final num = double.tryParse(_currentNumber) ?? 0;
      if (_pendingOp != null && _operand != null) {
        _computeWith(num);
      } else {
        _operand = num;
      }
      _pendingOp = op;
      _currentNumber = '0';
    });
  }

  void _computeWith(double num) {
    switch (_pendingOp) {
      case '+': _operand = (_operand ?? 0) + num; break;
      case '-': _operand = (_operand ?? 0) - num; break;
      case '×': _operand = (_operand ?? 0) * num; break;
      case '÷': _operand = num != 0 ? (_operand ?? 0) / num : 0; break;
    }
    _currentNumber = _operand.toString();
    _result = _operand;
  }

  void _onEquals() {
    setState(() {
      final num = double.tryParse(_currentNumber) ?? 0;
      if (_pendingOp != null) _computeWith(num);
      _pendingOp = null;
    });
  }

  void _onClear() {
    setState(() {
      _currentNumber = '0';
      _pendingOp = null;
      _operand = null;
      _result = null;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_currentNumber.length > 1) {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
      } else {
        _currentNumber = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = _result != null
        ? _result!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')
        : _currentNumber;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_pendingOp != null)
                    Text(
                      '${_operand?.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') ?? ''} $_pendingOp $_currentNumber',
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.muted, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    display,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildButtonGrid(theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onClear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      final num = double.tryParse(_currentNumber) ?? 0;
                      if (_pendingOp != null) _computeWith(num);
                      final value = double.tryParse(_currentNumber) ?? 0;
                      Navigator.of(context).pop(value);
                    },
                    child: const Text('Use'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid(ThemeData theme) {
    final buttons = [
      ['C', '⌫', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Column(
      children: buttons.map((row) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: row.map((label) {
            final isOp = ['+', '-', '×', '÷'].contains(label);
            final isEq = label == '=';
            final isClear = label == 'C' || label == '⌫';
            final flex = (label == '0') ? 2 : 1;
            return Expanded(
              flex: flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 48,
                  child: isOp
                    ? FilledButton.tonal(
                        onPressed: () => _onOperator(label),
                        child: Text(label, style: const TextStyle(fontSize: 18)),
                      )
                    : isEq
                      ? FilledButton(
                          onPressed: _onEquals,
                          child: Text(label, style: const TextStyle(fontSize: 18)),
                        )
                      : isClear
                        ? OutlinedButton(
                            onPressed: label == 'C' ? _onClear : _onBackspace,
                            child: Text(label, style: const TextStyle(fontSize: 16)),
                          )
                        : OutlinedButton(
                            onPressed: () => _onDigit(label),
                            child: Text(label, style: const TextStyle(fontSize: 18)),
                          ),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }
}
