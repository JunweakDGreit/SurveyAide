import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/services_provider.dart';
import '../../providers/region_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/service_sheet.dart';
import '../../widgets/toast.dart';
import '../settings/settings_sheet.dart';

final pinnedProvider = StateNotifierProvider<PinnedNotifier, Set<String>>((ref) {
  return PinnedNotifier();
});

class PinnedNotifier extends StateNotifier<Set<String>> {
  PinnedNotifier() : super({}) {
    _load();
  }

  void _load() {
    final val = StorageService().getString('gep_pinned');
    if (val.isNotEmpty) {
      state = val.split(',').toSet();
    }
  }

  void toggle(String code) {
    final updated = Set<String>.from(state);
    if (updated.contains(code)) {
      updated.remove(code);
    } else {
      updated.add(code);
    }
    state = updated;
    StorageService().setString('gep_pinned', updated.join(','));
  }
}

class CalculatorView extends ConsumerStatefulWidget {
  const CalculatorView({super.key});

  @override
  ConsumerState<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends ConsumerState<CalculatorView> {
  int _activeTab = 0;
  bool _gridMode = false;

  @override
  void initState() {
    super.initState();
    _gridMode = StorageService().getBool('gep_calc_grid_mode', def: false);
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);
    final region = ref.watch(regionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('GE Tariff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                region.displayName,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_gridMode ? Icons.view_list_outlined : Icons.grid_view_outlined),
            tooltip: _gridMode ? 'List view' : 'Grid view',
            onPressed: () => setState(() {
              _gridMode = !_gridMode;
              StorageService().setBool('gep_calc_grid_mode', _gridMode);
            }),
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => SettingsSheet.show(context),
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (regionData) => _buildBody(context, regionData),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.brass)),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Failed to load services: $err', style: const TextStyle(color: AppTheme.marker)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RegionData regionData) {
    final theme = Theme.of(context);
    final showFav = StorageService().getBool('gep_show_fav_tab', def: true);
    final pinned = ref.watch(pinnedProvider);
    final categories = regionData.categories;
    final allServices = regionData.services;

    final filteredCats = <String>[];
    if (showFav && pinned.isNotEmpty) {
      filteredCats.add('Favorites');
    }
    for (final cat in categories) {
      filteredCats.add(cat.key);
    }

    if (_activeTab >= filteredCats.length) {
      _activeTab = 0;
    }

    return Column(
      children: [
        // Flat category row
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            child: Row(
              children: List.generate(filteredCats.length, (i) {
                final catKey = filteredCats[i];
                final isActive = i == _activeTab;
                final cat = categories.where((c) => c.key == catKey).firstOrNull;

                return GestureDetector(
                  onTap: () => setState(() => _activeTab = i),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          catKey == 'Favorites' ? '⭐ Favorites' : cat?.label ?? catKey,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? (cat?.color ?? AppTheme.brass) : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: 24,
                          decoration: BoxDecoration(
                            color: isActive ? (cat?.color ?? AppTheme.brass) : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Service list
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey('${filteredCats[_activeTab]}_$_gridMode'),
              child: _gridMode
                  ? _buildServiceGrid(filteredCats, allServices, pinned, showFav)
                  : _buildServiceList(filteredCats, allServices, pinned, showFav),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceList(
    List<String> filteredCats,
    List<Service> allServices,
    Set<String> pinned,
    bool showFav,
  ) {
    if (filteredCats.isEmpty) return const SizedBox.shrink();

    final activeCat = filteredCats[_activeTab];
    List<Service> services;

    if (activeCat == 'Favorites') {
      services = allServices.where((s) => pinned.contains(s.code)).toList();
    } else {
      services = allServices.where((s) => s.cat == activeCat).toList();
    }

    services.sort((a, b) {
      final aPinned = pinned.contains(a.code) ? 0 : 1;
      final bPinned = pinned.contains(b.code) ? 0 : 1;
      if (aPinned != bPinned) return aPinned.compareTo(bPinned);
      return a.code.compareTo(b.code);
    });

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activeCat == 'Favorites' ? Icons.star_outline : Icons.search_off,
              size: 48, color: AppTheme.rule,
            ),
            const SizedBox(height: 12),
            Text(
              activeCat == 'Favorites'
                  ? 'No pinned services yet.\nLong-press a service to pin it.'
                  : 'No services in this category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final service = services[i];
        final isPinned = pinned.contains(service.code);

        // Grouped items (Category B)
        if (activeCat == 'B' && service.group.isNotEmpty) {
          final prev = i > 0 ? services[i - 1] : null;
          final showHeader = prev == null || prev.group != service.group;
          if (showHeader) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4, left: 4),
                  child: Text(service.group, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent,
                  )),
                ),
                _ServiceCard(
                  service: service,
                  isPinned: isPinned,
                  onTap: () {
                    ServiceSheet.show(context, service).then((added) {
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
                  onLongPress: () => ref.read(pinnedProvider.notifier).toggle(service.code),
                ),
              ],
            );
          }
        }

        return _ServiceCard(
          service: service,
          isPinned: isPinned,
          onTap: () {
            ServiceSheet.show(context, service).then((added) {
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
          onLongPress: () => ref.read(pinnedProvider.notifier).toggle(service.code),
        );
      },
    );
  }

  Widget _buildServiceGrid(
    List<String> filteredCats,
    List<Service> allServices,
    Set<String> pinned,
    bool showFav,
  ) {
    if (filteredCats.isEmpty) return const SizedBox.shrink();

    final activeCat = filteredCats[_activeTab];
    List<Service> services;

    if (activeCat == 'Favorites') {
      services = allServices.where((s) => pinned.contains(s.code)).toList();
    } else {
      services = allServices.where((s) => s.cat == activeCat).toList();
    }

    services.sort((a, b) {
      final aPinned = pinned.contains(a.code) ? 0 : 1;
      final bPinned = pinned.contains(b.code) ? 0 : 1;
      if (aPinned != bPinned) return aPinned.compareTo(bPinned);
      return a.code.compareTo(b.code);
    });

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activeCat == 'Favorites' ? Icons.star_outline : Icons.search_off,
              size: 48, color: AppTheme.rule,
            ),
            const SizedBox(height: 12),
            Text(
              activeCat == 'Favorites'
                  ? 'No pinned services yet.\nLong-press a service to pin it.'
                  : 'No services in this category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final service = services[i];
        final isPinned = pinned.contains(service.code);
        return _ServiceCard(
          service: service,
          isPinned: isPinned,
          onTap: () {
            ServiceSheet.show(context, service).then((added) {
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
          onLongPress: () => ref.read(pinnedProvider.notifier).toggle(service.code),
        );
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Service service;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ServiceCard({
    required this.service,
    required this.isPinned,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() => _scale = 0.96);
            Future.delayed(const Duration(milliseconds: 80), () {
              if (mounted) setState(() => _scale = 1.0);
            });
            widget.onTap();
          },
          onLongPress: () {
            setState(() => _scale = 0.96);
            Future.delayed(const Duration(milliseconds: 80), () {
              if (mounted) setState(() => _scale = 1.0);
            });
            widget.onLongPress();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(serviceDisplayName(widget.service.name, widget.service.group), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (widget.isPinned)
                      const Icon(Icons.star, size: 18, color: AppTheme.brass),
                  ],
                ),
                if (widget.service.shortDescription != null && widget.service.shortDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Tooltip(
                      message: widget.service.shortDescription!,
                      child: Text(
                        widget.service.shortDescription!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

