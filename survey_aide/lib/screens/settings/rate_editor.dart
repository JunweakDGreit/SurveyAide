import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/rate_provider.dart';

final _numFmt = NumberFormat('#,##0.00', 'en_US');

double _parseVal(String text) {
  final cleaned = text.replaceAll(',', '');
  return double.tryParse(cleaned) ?? double.nan;
}

class RateEditor extends ConsumerStatefulWidget {
  final String serviceCode;
  final String serviceName;
  final Map<String, double> defaultRates;
  final Map<String, String> labels;

  const RateEditor({
    super.key,
    required this.serviceCode,
    this.serviceName = '',
    required this.defaultRates,
    required this.labels,
  });

  @override
  ConsumerState<RateEditor> createState() => _RateEditorState();
}

class _RateEditorState extends ConsumerState<RateEditor> {
  late Map<String, TextEditingController> _controllers;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(RateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultRates != widget.defaultRates) {
      for (final c in _controllers.values) {
        c.dispose();
      }
      _initControllers();
    }
  }

  void _initControllers() {
    _controllers = {};
    for (final entry in widget.defaultRates.entries) {
      final currentVal = ref.read(rateProvider.notifier).getRate(
        widget.defaultRates,
        widget.serviceCode,
        entry.key,
      );
      _controllers[entry.key] = TextEditingController(text: _numFmt.format(currentVal));
      _controllers[entry.key]!.addListener(() {
        final stored = ref.read(rateProvider.notifier).getRate(widget.defaultRates, widget.serviceCode, entry.key);
        final isDiff = _parseVal(_controllers[entry.key]!.text) != stored;
        if (isDiff != _hasChanges) {
          setState(() => _hasChanges = isDiff);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.removeListener(() {});
      c.dispose();
    }
    super.dispose();
  }

  bool get _isChanged {
    for (final entry in widget.defaultRates.entries) {
      final current = _parseVal(_controllers[entry.key]?.text ?? '');
      if (current != entry.value) return true;
    }
    return false;
  }

  void _resetService() {
    for (final entry in widget.defaultRates.entries) {
      _controllers[entry.key]?.text = _numFmt.format(entry.value);
      ref.read(rateProvider.notifier).resetRate(widget.serviceCode, entry.key);
    }
    setState(() => _hasChanges = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isChanged ? AppTheme.brass : theme.dividerColor,
          width: _isChanged ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.serviceName.isNotEmpty ? widget.serviceName : (widget.labels['base']?.split(' (')[0] ?? ''),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isChanged)
                  InkWell(
                    onTap: _resetService,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.restart_alt, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final entry in widget.defaultRates.entries) ...[
              _RateRow(
                keyName: entry.key,
                label: widget.labels[entry.key] ?? entry.key,
                controller: _controllers[entry.key]!,
                defaultValue: entry.value,
                onChanged: (val) {
                  if (val != entry.value) {
                    ref.read(rateProvider.notifier).setRate(widget.serviceCode, entry.key, val);
                  } else {
                    ref.read(rateProvider.notifier).resetRate(widget.serviceCode, entry.key);
                  }
                },
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String keyName;
  final String label;
  final TextEditingController controller;
  final double defaultValue;
  final ValueChanged<double> onChanged;

  const _RateRow({
    required this.keyName,
    required this.label,
    required this.controller,
    required this.defaultValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentVal = _parseVal(controller.text);
    final isChanged = !currentVal.isNaN && currentVal != defaultValue;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isChanged ? AppTheme.brass.withValues(alpha: 0.08) : null,
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: InputBorder.none,
                prefixText: '\u20B1 ',
                prefixStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              onSubmitted: (val) {
                final parsed = _parseVal(val);
                final finalVal = parsed.isNaN ? defaultValue : parsed;
                controller.text = _numFmt.format(finalVal);
                onChanged(finalVal);
              },
            ),
          ),
        ),
        if (isChanged) ...[
          const SizedBox(width: 4),
          Text('(${_numFmt.format(defaultValue)})', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ],
    );
  }
}
