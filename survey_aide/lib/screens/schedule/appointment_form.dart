import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../providers/appointment_provider.dart';

class AppointmentForm extends StatefulWidget {
  final DateTime? selectedDate;
  final Appointment? appointment;

  const AppointmentForm({
    super.key,
    this.selectedDate,
    this.appointment,
  });

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _date;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final appt = widget.appointment;
    _titleCtrl = TextEditingController(text: appt?.title ?? '');
    _noteCtrl = TextEditingController(text: appt?.note ?? '');
    _date = appt?.date ?? widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = Appointment(
      title: _titleCtrl.text.trim(),
      date: _date,
      note: _noteCtrl.text.trim(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.appointment != null;

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
              Text(isEdit ? 'Edit Appointment' : 'New Appointment', style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                decoration: glassInputDecoration(context, labelText: 'Title *', hintText: 'e.g. Site visit, Meeting'),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: glassInputDecoration(context, labelText: 'Date', suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.brass)),
                  child: Text(
                    _date.toLocal().toString().split(' ')[0],
                    style: const TextStyle(color: AppTheme.ink),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: glassInputDecoration(context, labelText: 'Note (optional)', hintText: 'Add details...'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
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
