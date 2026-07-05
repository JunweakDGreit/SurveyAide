import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../providers/payment_provider.dart';

class InstallmentForm extends StatefulWidget {
  final Installment? installment;

  const InstallmentForm({super.key, this.installment});

  @override
  State<InstallmentForm> createState() => _InstallmentFormState();
}

class _InstallmentFormState extends State<InstallmentForm> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _pctCtrl;
  late DateTime? _dueDate;
  late bool _paid;
  late bool _isFixed;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final inst = widget.installment;
    _labelCtrl = TextEditingController(text: inst?.label ?? '');
    _isFixed = inst?.isFixed ?? false;
    _pctCtrl = TextEditingController(text: inst?.pct.toString() ?? '');
    _dueDate = inst?.dueDate;
    _paid = inst?.paid ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _pctCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = double.tryParse(_pctCtrl.text) ?? 0;
    if (value <= 0) return;
    if (!_isFixed && value > 100) return;

    final result = Installment(
      label: _labelCtrl.text.trim(),
      pct: value,
      isFixed: _isFixed,
      dueDate: _dueDate,
      paid: _paid,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.installment != null;

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
              Text(isEdit ? 'Edit Payment' : 'Add Payment', style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _labelCtrl,
                decoration: glassInputDecoration(context, labelText: 'Label', hintText: 'e.g. Downpayment, 1st Payment'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Percentage'), icon: Icon(Icons.percent, size: 16)),
                  ButtonSegment(value: true, label: Text('Amount'), icon: Icon(Icons.attach_money, size: 16)),
                ],
                selected: {_isFixed},
                onSelectionChanged: (v) => setState(() => _isFixed = v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pctCtrl,
                decoration: glassInputDecoration(
                  context,
                  labelText: _isFixed ? 'Amount' : 'Percentage',
                  hintText: _isFixed ? 'e.g. 5000' : 'e.g. 50',
                  prefixText: _isFixed ? '₱' : null,
                  suffixText: _isFixed ? null : '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return _isFixed ? 'Amount is required' : 'Percentage is required';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Enter a positive value';
                  if (!_isFixed && val > 100) return 'Enter a value between 1 and 100';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: glassInputDecoration(context, labelText: 'Due Date (optional)', suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.brass)),
                  child: Text(
                    _dueDate != null
                        ? _dueDate!.toLocal().toString().split(' ')[0]
                        : 'Select date',
                    style: TextStyle(
                      color: _dueDate != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Paid'),
                value: _paid,
                onChanged: (v) => setState(() => _paid = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.brass,
              ),
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
