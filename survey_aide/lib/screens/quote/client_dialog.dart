import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';

class ClientDialog extends StatefulWidget {
  final String? initialName;
  final String? initialLocation;

  const ClientDialog({
    super.key,
    this.initialName,
    this.initialLocation,
  });

  @override
  State<ClientDialog> createState() => _ClientDialogState();
}

class _ClientDialogState extends State<ClientDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final lastName = widget.initialName ?? StorageService().getString('gep_last_client_name');
    final lastLoc = widget.initialLocation ?? StorageService().getString('gep_last_client_location');
    _nameCtrl = TextEditingController(text: lastName);
    _locCtrl = TextEditingController(text: lastLoc);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameCtrl.text.trim();
    final location = _locCtrl.text.trim();
    if (name.isEmpty) return;
    StorageService().setString('gep_last_client_name', name);
    StorageService().setString('gep_last_client_location', location);
    Navigator.of(context).pop((name: name, location: location));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Text('Client Information', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Enter payment details for this service', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: glassInputDecoration(context, labelText: 'Client Name *', hintText: 'e.g. Juan Dela Cruz'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Client name is required' : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locCtrl,
                decoration: glassInputDecoration(context, labelText: 'Location (optional)', hintText: 'e.g. Brgy. 1, City'),
                textCapitalization: TextCapitalization.words,
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
                    child: const Text('Add to Payment'),
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
