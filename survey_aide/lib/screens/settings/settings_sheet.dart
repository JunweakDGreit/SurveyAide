import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants.dart';
import '../../providers/services_provider.dart';
import '../../providers/setup_provider.dart';
import '../../providers/region_provider.dart';
import '../../providers/rate_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../providers/uiprovider.dart';
import '../../providers/reference_provider.dart';
import 'rate_editor.dart';

final settingsSheetOpenProvider = StateProvider<bool>((ref) => false);

final showFavTabProvider = StateProvider<bool>((ref) {
  return StorageService().getBool('gep_show_fav_tab', def: true);
});

final interpolateProvider = StateProvider<bool>((ref) {
  return StorageService().getBool('gep_interpolate', def: false);
});

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    container.read(settingsSheetOpenProvider.notifier).state = true;
    container.read(bottomSheetOpenProvider.notifier).state = true;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    ).whenComplete(() {
      container.read(settingsSheetOpenProvider.notifier).state = false;
      container.read(bottomSheetOpenProvider.notifier).state = false;
    });
  }

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late TextEditingController _nameCtrl;
  bool _settingsDirty = false;
  String _rateSearch = '';
  String _selectedRegionName = '';

  @override
  void initState() {
    super.initState();
    final setup = ref.read(setupProvider);
    _nameCtrl = TextEditingController(text: setup.name);
    _selectedRegionName = setup.region;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_settingsDirty) setState(() => _settingsDirty = true);
  }

  Future<bool> _onWillPop() async {
    if (!_settingsDirty) return true;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('You have unsaved settings changes.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop('cancel'), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop('discard'), child: const Text('Discard')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop('save'), child: const Text('Save')),
        ],
      ),
    );
    if (result == 'save') {
      _saveSettings();
      return true;
    }
    return result == 'discard';
  }

  void _saveSettings() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      StorageService().setString('gep_name', name);
    }
    final profileRegion = _selectedRegionName.isNotEmpty
        ? _selectedRegionName
        : ref.read(setupProvider).region;
    ref.read(setupProvider.notifier).complete(
      name.isNotEmpty ? name : ref.read(setupProvider).name,
      profileRegion,
    );
    ref.read(regionProvider.notifier).setRegion(Region.fromString(profileRegion));

    final showFav = ref.read(showFavTabProvider);
    StorageService().setBool('gep_show_fav_tab', showFav);

    final interp = ref.read(interpolateProvider);
    StorageService().setBool('gep_interpolate', interp);

    _settingsDirty = false;
  }

  Future<void> _exportRates() async {
    final overrides = await StorageService().getRateOverrides();
    final map = <String, Map<String, double>>{};
    for (final o in overrides) {
      map.putIfAbsent(o.code, () => {})[o.key] = o.value;
    }
    final jsonStr = const JsonEncoder.withIndent('  ').convert(map);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/gep_rates_export.json');
    await file.writeAsString(jsonStr);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Rates exported to ${file.path}'),
        backgroundColor: AppTheme.marker,
      ));
    }
  }

  Future<void> _importRates() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.first.path!);
    final jsonStr = await file.readAsString();
    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      for (final codeEntry in data.entries) {
        final code = codeEntry.key;
        final rates = codeEntry.value as Map<String, dynamic>;
        for (final rateEntry in rates.entries) {
          await ref.read(rateProvider.notifier).setRate(
            code,
            rateEntry.key,
            (rateEntry.value as num).toDouble(),
          );
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Rates imported successfully'),
          backgroundColor: AppTheme.marker,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: AppTheme.marker,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final showFav = ref.watch(showFavTabProvider);
    final interp = ref.watch(interpolateProvider);

    return PopScope(
      canPop: !_settingsDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) Navigator.of(context).pop();
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
        decoration: glassDecoration(
          opacity: Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.40,
          blur: 12,
          radius: 20,
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.rule,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Settings', style: theme.textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () {
                      _saveSettings();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _sectionHeader('Profile'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: glassInputDecoration(context, labelText: 'Name', hintText: 'Enter your name'),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _markDirty(),
                  ),
                  const SizedBox(height: 8),
                  _buildRegionDropdown(),
                  const SizedBox(height: 20),
                  _sectionHeader('Favorites'),
                  CheckboxListTile(
                    title: const Text('Show Favorites tab'),
                    subtitle: const Text('Display pinned services in a separate tab'),
                    value: showFav,
                    onChanged: (v) {
                      ref.read(showFavTabProvider.notifier).state = v ?? false;
                      _markDirty();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppTheme.brass,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _sectionHeader('Calculation'),
                  CheckboxListTile(
                    title: const Text('Enable interpolation mode'),
                    subtitle: const Text('Use proportional billing for partial quantities'),
                    value: interp,
                    onChanged: (v) {
                      ref.read(interpolateProvider.notifier).state = v ?? false;
                      _markDirty();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppTheme.brass,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _sectionHeader('Theme'),
                  CheckboxListTile(
                    title: const Text('Dark mode'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: themeMode == ThemeMode.system
                        ? null
                        : (v) {
                            ref.read(themeProvider.notifier).setDark(v ?? false);
                            _markDirty();
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppTheme.brass,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Follow system'),
                    value: themeMode == ThemeMode.system,
                    onChanged: (v) {
                      ref.read(themeProvider.notifier).setFollowSystem(v ?? false);
                      _markDirty();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppTheme.brass,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _sectionHeader('Services'),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: glassInputDecoration(context, hintText: 'Search services...', prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    onChanged: (v) => setState(() => _rateSearch = v),
                  ),
                  const SizedBox(height: 8),
                  _buildRateEditors(),
                  const SizedBox(height: 12),
                  _sectionHeader('Advanced'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context, title: 'Reset All Rates',
                          message: 'Reset all rate overrides to default values?',
                          confirmLabel: 'Reset All',
                        );
                        if (confirmed && context.mounted) {
                          await ref.read(rateProvider.notifier).resetAll();
                          _markDirty();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('All rates reset to defaults'),
                              backgroundColor: AppTheme.marker,
                            ));
                          }
                        }
                      },
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reset all rates to defaults'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.marker,
                        side: const BorderSide(color: AppTheme.marker),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exportRates,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export rates'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importRates,
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Import rates'),
                        ),
                      ),
                    ],
                  ),
                ],
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

  Widget _buildRegionDropdown() {
    final regionsAsync = ref.watch(regionListProvider);
    final setup = ref.watch(setupProvider);
    final currentRegion = _selectedRegionName.isNotEmpty ? _selectedRegionName : setup.region;

    return regionsAsync.when(
      data: (regions) {
        final selectedValue = regions.any((r) => r.name == currentRegion) ? currentRegion : regions.first.name;
        return DropdownButtonFormField<String>(
          initialValue: selectedValue,
          decoration: glassInputDecoration(context, labelText: 'Region'),
          isExpanded: true,
          items: regions.map((r) => DropdownMenuItem(
            value: r.name,
            child: Text(r.description),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRegionName = value);
              _markDirty();
            }
          },
        );
      },
      loading: () => DropdownButtonFormField<String>(
        decoration: glassInputDecoration(context, labelText: 'Region'),
        items: const [DropdownMenuItem(value: '', child: Text('Loading...'))],
        onChanged: null,
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(label, style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
    ));
  }

  Widget _buildRateEditors() {
    final categoryOrder = ['A', 'B', 'C', 'D'];
    final serviceCodesByCat = <String, List<String>>{};
    for (final code in defaultRates.keys) {
      final cat = code.split('.')[0];
      serviceCodesByCat.putIfAbsent(cat, () => []).add(code);
    }

    final servicesAsync = ref.watch(servicesProvider);
    final serviceNameMap = <String, String>{};
    servicesAsync.whenData((regionData) {
      for (final s in regionData.services) {
        serviceNameMap[s.code] = s.name;
      }
    });

    final filteredCodes = defaultRates.keys.where((code) {
      if (_rateSearch.isEmpty) return true;
      final q = _rateSearch.toLowerCase();
      return code.toLowerCase().contains(q) ||
          (serviceNameMap[code] ?? '').toLowerCase().contains(q) ||
          (rateLabels[code]?['base'] ?? '').toLowerCase().contains(q);
    }).toList();

    return Column(
      children: categoryOrder.map((cat) {
        final catCodes = (serviceCodesByCat[cat] ?? [])
            .where((c) => filteredCodes.contains(c))
            .toList();
        if (catCodes.isEmpty) return const SizedBox.shrink();
        return _CategoryRatesSection(
          category: cat,
          codes: catCodes,
          serviceNameMap: serviceNameMap,
          rateSearch: _rateSearch,
          onChanged: _markDirty,
        );
      }).toList(),
    );
  }
}

const _catNames = {'A': 'Property', 'B': 'Engineering', 'C': 'Mapping', 'D': 'Other'};

String _catLabel(String key) => _catNames[key] ?? 'Category $key';

class _CategoryRatesSection extends StatefulWidget {
  final String category;
  final List<String> codes;
  final Map<String, String> serviceNameMap;
  final String rateSearch;
  final VoidCallback onChanged;

  const _CategoryRatesSection({
    required this.category,
    required this.codes,
    required this.serviceNameMap,
    required this.rateSearch,
    required this.onChanged,
  });

  @override
  State<_CategoryRatesSection> createState() => _CategoryRatesSectionState();
}

class _CategoryRatesSectionState extends State<_CategoryRatesSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.rateSearch.isNotEmpty) _expanded = true;
  }

  @override
  void didUpdateWidget(_CategoryRatesSection old) {
    super.didUpdateWidget(old);
    if (widget.rateSearch != old.rateSearch && widget.rateSearch.isNotEmpty) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text(_catLabel(widget.category), style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface,
                )),
                const Spacer(),
                Text('${widget.codes.length} services', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  children: widget.codes.map((code) => RateEditor(
                    serviceCode: code,
                    serviceName: widget.serviceNameMap[code] ?? '',
                    defaultRates: defaultRates[code] ?? {},
                    labels: rateLabels[code] ?? {},
                  )).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
