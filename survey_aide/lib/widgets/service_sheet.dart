import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/helpers.dart';
import '../providers/rate_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/uiprovider.dart';
import '../services/computation_service.dart';
import '../services/storage_service.dart';
import '../screens/quote/client_dialog.dart';
import 'press_scale.dart';

class ServiceSheet extends ConsumerStatefulWidget {
  final Service service;

  const ServiceSheet({super.key, required this.service});

  static Future<bool> show(BuildContext context, Service service) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(bottomSheetOpenProvider.notifier).state = true;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceSheet(service: service),
    ).whenComplete(() {
      container.read(bottomSheetOpenProvider.notifier).state = false;
    }).then((result) => result ?? false);
  }

  @override
  ConsumerState<ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends ConsumerState<ServiceSheet> {
  final _fieldControllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};
  final _selectValues = <String, String>{};
  bool _interp = false;

  @override
  void initState() {
    super.initState();
    _interp = StorageService().getBool('gep_interpolate', def: false);
    for (final f in widget.service.fields) {
      if (f.type == 'select') {
        _selectValues[f.key] = f.options.isNotEmpty ? f.options.first.value : '';
      } else {
        final ctrl = TextEditingController(text: f.def > 0 ? f.def.toString() : '0');
        _fieldControllers[f.key] = ctrl;
        _focusNodes[f.key] = FocusNode()
          ..addListener(() {
            if (_focusNodes[f.key]!.hasFocus && ctrl.text == '0') {
              ctrl.text = '';
            }
          });
        ctrl.addListener(_onFieldChanged);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _fieldControllers.values) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  Map<String, double> get _fieldValues {
    return _fieldControllers.map((k, v) => MapEntry(k, double.tryParse(v.text) ?? 0));
  }

  Map<String, dynamic> get _allValues => {..._fieldValues, ..._selectValues};

  void _onFieldChanged() {
    setState(() {});
  }

  List<TallyLine> get _computedLines {
    final values = _allValues;
    final rates = widget.service.rates.map((k, v) {
      final custom = ref.read(rateProvider.notifier).getRate(widget.service.rates, widget.service.code, k);
      return MapEntry(k, custom);
    });
    return ComputationService.compute(widget.service.code, values, rates, interp: _interp);
  }

  double get _total {
    return _computedLines.fold<double>(0, (s, l) => s + l.amount);
  }

  void _resetFields() {
    setState(() {
      for (final f in widget.service.fields) {
        _fieldControllers[f.key]?.text = f.def.toString();
      }
    });
  }

  Future<void> _addToPayment() async {
    final result = await showDialog<({String name, String location})>(
      context: context,
      builder: (_) => const ClientDialog(),
    );
    if (result == null || !context.mounted) return;

    final uid = QuoteNotifier.generateUid();
    final entry = QuoteEntry(
      uid: uid,
      code: widget.service.code,
      name: widget.service.name,
      total: _total,
      lines: List.from(_computedLines),
      client: result.name,
      location: result.location,
    );

    ref.read(quoteProvider.notifier).addItem(entry);
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;
    final lines = _computedLines;
    final total = _total;

    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: glassDecoration(
            opacity: isDark ? 0.30 : 0.40,
            blur: 12,
            radius: 20,
            dark: isDark,
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.rule, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 2),
                      Text(serviceDisplayName(service.name, service.group), style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ],
            ),
          ),
          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fields
                  ...service.fields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: field.type == 'select'
                        ? _SelectInput(
                            field: field,
                            value: _selectValues[field.key] ?? field.def.toStringAsFixed(0),
                            onChanged: (v) {
                              setState(() => _selectValues[field.key] = v);
                            },
                          )
                        : _FieldInput(
                            field: field,
                            controller: _fieldControllers[field.key]!,
                            focusNode: _focusNodes[field.key]!,
                          ),
                  )),
                  // Note
                  if (service.note != null && service.note!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.brass.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.brass, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(service.note!, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Reset
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetFields,
                      child: const Text('Reset fields'),
                    ),
                  ),
                  // Tally
                  if (lines.isNotEmpty) ...[
                    const Divider(),
                    ...lines.map((line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(line.label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))),
                          Text(peso(line.amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    )),
                    const Divider(thickness: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const Spacer(),
                          Text(peso(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.marker)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Footer button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _addToPayment,
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: Text('Add to Payment — ${peso(total)}'),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }
}

class _SelectInput extends StatelessWidget {
  final ServiceField field;
  final String value;
  final ValueChanged<String> onChanged;

  const _SelectInput({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: field.options.any((o) => o.value == value) ? value : field.options.firstOrNull?.value,
          items: field.options.map((o) => DropdownMenuItem(value: o.value, child: Text(o.label, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
          decoration: glassInputDecoration(context),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _FieldInput extends StatelessWidget {
  final ServiceField field;
  final TextEditingController controller;
  final FocusNode focusNode;

  const _FieldInput({
    required this.field,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            _stepperBtn(context, Icons.remove, () {
              final val = (double.tryParse(controller.text) ?? 0) - field.step;
              controller.text = val < field.min ? field.min.toString() : val.toStringAsFixed(4);
            }),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: glassInputDecoration(context, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                onSubmitted: (_) {
                  final val = double.tryParse(controller.text);
                  if (val == null || val < field.min) {
                    controller.text = field.min.toString();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            _stepperBtn(context, Icons.add, () {
              final val = (double.tryParse(controller.text) ?? 0) + field.step;
              controller.text = val.toStringAsFixed(4);
            }),
          ],
        ),
      ],
    );
  }

  Widget _stepperBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return PressScale(
      onTap: onTap,
      child: Material(
        color: AppTheme.rule.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
        ),
      ),
    );
  }
}
