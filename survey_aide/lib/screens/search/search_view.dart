import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/region_provider.dart';
import '../../widgets/service_sheet.dart';
import '../../widgets/toast.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _filteredServicesProvider = FutureProvider.autoDispose<List<Service>>((ref) async {
  final query = ref.watch(_searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return [];

  final region = ref.watch(regionProvider);
  final regionData = await loadServices(region.displayName);

  return regionData.services.where((s) {
    return s.code.toLowerCase().contains(query) ||
        s.name.toLowerCase().contains(query);
  }).toList();
});

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchCtrl.addListener(() {
      ref.read(_searchQueryProvider.notifier).state = _searchCtrl.text;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(_searchQueryProvider);
    final servicesAsync = ref.watch(_filteredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search services by code or name...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          ).applyDefaults(Theme.of(context).inputDecorationTheme),

          style: theme.textTheme.bodyLarge,
          textCapitalization: TextCapitalization.none,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: servicesAsync.when(
        data: (services) {
          if (query.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 48, color: AppTheme.rule),
                  const SizedBox(height: 12),
                  Text('Type to search services', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                ],
              ),
            );
          }
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48, color: AppTheme.rule),
                  const SizedBox(height: 12),
                  Text('No services found for "$query"', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (_, i) => _SearchResultCard(
              service: services[i],
              onTap: () {
                ServiceSheet.show(context, services[i]).then((added) {
                  if (added && context.mounted) {
                    showToast(
                      context,
                      'Service added to Payments',
                      actionLabel: 'View',
                      onAction: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        context.go('/payment');
                      },
                    );
                  }
                });
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.brass)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.marker))),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _SearchResultCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceDisplayName(service.name, service.group), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    if (service.note != null && service.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(service.note!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
            ],
          ),
        ),
      ),
    );
  }
}
