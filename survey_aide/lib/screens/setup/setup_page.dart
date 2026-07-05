import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/setup_provider.dart';
import '../../providers/reference_provider.dart';
import '../../db/reference_database.dart';
import '../../core/constants.dart';

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AdminRegion? _region;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regionsAsync = ref.watch(regionListProvider);

    return Scaffold(
      body: SafeArea(child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome', style: theme.textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Tell us about yourself',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: glassInputDecoration(context, labelText: 'Name', hintText: 'Enter your name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                regionsAsync.when(
                  data: (regions) => DropdownButtonFormField<AdminRegion>(
                    initialValue: _region,
                    decoration: glassInputDecoration(context, labelText: 'Region'),
                    isExpanded: true,
                    items: regions.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.description),
                    )).toList(),
                    onChanged: (v) => setState(() => _region = v),
                  ),
                  loading: () => DropdownButtonFormField<String>(
                    decoration: glassInputDecoration(context, labelText: 'Region'),
                    items: const [DropdownMenuItem(value: '', child: Text('Loading...'))],
                    onChanged: null,
                  ),
                  error: (e, _) => Text('Error loading regions: $e'),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onSubmit,
                    child: const Text('Get Started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_region == null) return;
    await ref.read(setupProvider.notifier).complete(
          _nameController.text.trim(),
          _region!.code,
        );
    if (context.mounted) context.go('/');
  }
}
