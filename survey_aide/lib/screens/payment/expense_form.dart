import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../providers/expense_provider.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseEntry? expense;

  const ExpenseForm({super.key, this.expense});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _valueCtrl;
  late bool _isPercent;
  late String _base;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _labelCtrl = TextEditingController(text: exp?.label ?? '');
    _isPercent = exp?.isPercent ?? false;
    _valueCtrl = TextEditingController(text: exp?.value.toString() ?? '');
    _base = exp?.base ?? 'net';
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = double.tryParse(_valueCtrl.text) ?? 0;
    if (value <= 0) return;

    final result = ExpenseEntry(
      label: _labelCtrl.text.trim(),
      isPercent: _isPercent,
      value: value,
      base: _base,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.expense != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? 'Edit Expense' : 'Add Expense', style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _labelCtrl,
                decoration: glassInputDecoration(context, labelText: 'Label', hintText: 'e.g. Survey Instrument, Finder\'s Fee'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Value'), icon: Icon(Icons.attach_money, size: 16)),
                  ButtonSegment(value: true, label: Text('Percentage'), icon: Icon(Icons.percent, size: 16)),
                ],
                selected: {_isPercent},
                onSelectionChanged: (v) => setState(() => _isPercent = v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueCtrl,
                decoration: glassInputDecoration(
                  context,
                  labelText: _isPercent ? 'Percentage' : 'Amount',
                  hintText: _isPercent ? 'e.g. 5' : 'e.g. 5000',
                  prefixText: _isPercent ? null : '₱',
                  suffixText: _isPercent ? '%' : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Value is required';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Enter a positive value';
                  if (_isPercent && val > 100) return 'Enter a value between 1 and 100';
                  return null;
                },
              ),
              if (_isPercent) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _base,
                  decoration: glassInputDecoration(context, labelText: 'Base'),
                  items: const [
                    DropdownMenuItem(value: 'net', child: Text('of Net (after prior expenses)')),
                    DropdownMenuItem(value: 'total', child: Text('of Total Income')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _base = v);
                  },
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(isEdit ? 'Save' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
