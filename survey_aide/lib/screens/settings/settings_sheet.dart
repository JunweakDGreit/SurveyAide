import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants.dart';
import '../../core/theme_presets.dart';
import '../../providers/services_provider.dart';
import '../../providers/setup_provider.dart';
import '../../providers/region_provider.dart';
import '../../providers/rate_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/invoice_settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/press_scale.dart';
import '../../providers/uiprovider.dart';
import '../../providers/reference_provider.dart';
import 'rate_editor.dart';

final settingsSheetOpenProvider = StateProvider<bool>((ref) => false);

final showFavTabProvider = StateProvider<bool>((ref) {
  return StorageService().getBool('gep_show_fav_tab', def: true);
});

final interpolateProvider = StateProvider<bool>((ref) {
  return StorageService().getBool('gep_interpolate', def: true);
});

enum _SettingsPage { menu, profile, invoice, theme, services, advanced, about }

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    container.read(settingsSheetOpenProvider.notifier).state = true;
    container.read(bottomSheetOpenProvider.notifier).state = true;
    container.read(modalCountProvider.notifier).state++;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    ).whenComplete(() {
      container.read(settingsSheetOpenProvider.notifier).state = false;
      container.read(bottomSheetOpenProvider.notifier).state = false;
      container.read(modalCountProvider.notifier).state--;
    });
  }

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  _SettingsPage _currentPage = _SettingsPage.menu;
  late TextEditingController _nameCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _companyAddressCtrl;
  late TextEditingController _companyPhoneCtrl;
  late TextEditingController _companyEmailCtrl;
  late TextEditingController _companyTinCtrl;
  late TextEditingController _prcLicenseCtrl;
  late TextEditingController _prcDateCtrl;
  late TextEditingController _ptrCtrl;
  late TextEditingController _ptrDateCtrl;
  bool _settingsDirty = false;
  String _rateSearch = '';
  String _selectedRegionName = '';
  int _aboutCardTapCount = 0;
  Timer? _aboutCardTapTimer;
  DateTime? _lastEasterEggToggle;
  int _confettiKey = 0;
  bool _confettiActive = false;

  @override
  void initState() {
    super.initState();
    final setup = ref.read(setupProvider);
    final biz = ref.read(businessInfoProvider);
    _nameCtrl = TextEditingController(text: setup.name);
    _companyCtrl = TextEditingController(text: biz.company);
    _companyAddressCtrl = TextEditingController(text: biz.address);
    _companyPhoneCtrl = TextEditingController(text: biz.phone);
    _companyEmailCtrl = TextEditingController(text: biz.email);
    _companyTinCtrl = TextEditingController(text: biz.tin);
    _prcLicenseCtrl = TextEditingController(text: biz.prcLicense);
    _prcDateCtrl = TextEditingController(text: biz.prcDate);
    _ptrCtrl = TextEditingController(text: biz.ptr);
    _ptrDateCtrl = TextEditingController(text: biz.ptrDate);
    _selectedRegionName = setup.region;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _companyAddressCtrl.dispose();
    _companyPhoneCtrl.dispose();
    _companyEmailCtrl.dispose();
    _companyTinCtrl.dispose();
    _prcLicenseCtrl.dispose();
    _prcDateCtrl.dispose();
    _ptrCtrl.dispose();
    _ptrDateCtrl.dispose();
    _aboutCardTapTimer?.cancel();
    super.dispose();
  }

  void _goToPage(_SettingsPage page) {
    setState(() => _currentPage = page);
  }

  void _goBack() {
    if (_settingsDirty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Save changes before leaving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _saveSettings();
                if (mounted) setState(() {
                  _currentPage = _SettingsPage.menu;
                  _settingsDirty = false;
                });
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (mounted) setState(() {
                  _currentPage = _SettingsPage.menu;
                  _settingsDirty = false;
                });
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _currentPage = _SettingsPage.menu);
    }
  }

  void _markDirty() {
    if (!_settingsDirty) setState(() => _settingsDirty = true);
  }

  void _saveSettings() {
    final name = _nameCtrl.text.trim();
    final company = _companyCtrl.text.trim();
    final address = _companyAddressCtrl.text.trim();
    final phone = _companyPhoneCtrl.text.trim();
    final email = _companyEmailCtrl.text.trim();
    final tin = _companyTinCtrl.text.trim();
    final prcLicense = _prcLicenseCtrl.text.trim();
    final prcDate = _prcDateCtrl.text.trim();
    final ptr = _ptrCtrl.text.trim();
    final ptrDate = _ptrDateCtrl.text.trim();

    final profileRegion = _selectedRegionName.isNotEmpty
        ? _selectedRegionName
        : ref.read(setupProvider).region;
    ref.read(selectedRegionCodeProvider.notifier).state = profileRegion;
    unawaited(StorageService().setString('gep_name', name));
    unawaited(StorageService().setString('gep_admin_region', profileRegion));

    final showFav = ref.read(showFavTabProvider);
    unawaited(StorageService().setBool('gep_show_fav_tab', showFav));

    final interp = ref.read(interpolateProvider);
    unawaited(StorageService().setBool('gep_interpolate', interp));

    ref.read(businessInfoProvider.notifier).save(BusinessInfo(
      company: company, address: address, phone: phone, email: email, tin: tin,
      prcLicense: prcLicense, prcDate: prcDate, ptr: ptr, ptrDate: ptrDate,
    ));

    ref.read(invoiceSettingsProvider.notifier).save(ref.read(invoiceSettingsProvider));
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
    final themeState = ref.watch(themeProvider);
    final themePreset = ref.watch(themeProvider.select((s) => s.preset));
    final inv = ref.watch(invoiceSettingsProvider);

    return PopScope(
      canPop: !_settingsDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text('You have unsaved settings changes.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Discard')),
              FilledButton(onPressed: () {
                _saveSettings();
                Navigator.of(ctx).pop(true);
              }, child: const Text('Save & Close')),
            ],
          ),
        );
        if (confirmed == true && context.mounted) Navigator.of(context).pop();
      },
      child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildHeader(),
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentPage),
                  child: _buildPage(inv, themeState.mode, themePreset),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    final isMenu = _currentPage == _SettingsPage.menu;
    return Row(
      children: [
        if (isMenu)
          PressScale(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          )
        else
          PressScale(
            child: TextButton(
              onPressed: _goBack,
              child: const Text('Back'),
            ),
          ),
        Expanded(
          child: Center(
            child: Text(
              _pageTitle(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        if (isMenu)
          const SizedBox(width: 64)
        else
          PressScale(
            child: TextButton(
              onPressed: () {
                _saveSettings();
                if (mounted) setState(() {
                  _settingsDirty = false;
                  _currentPage = _SettingsPage.menu;
                });
              },
              child: const Text('Save'),
            ),
          ),
      ],
    );
  }

  String _pageTitle() {
    switch (_currentPage) {
      case _SettingsPage.menu: return 'Settings';
      case _SettingsPage.profile: return 'Profile';
      case _SettingsPage.invoice: return 'Invoice Display';
      case _SettingsPage.theme: return 'Theme';
      case _SettingsPage.services: return 'Services';
      case _SettingsPage.advanced: return 'Advanced';
      case _SettingsPage.about: return 'About';
    }
  }

  Widget _buildPage(InvoiceSettings inv, ThemeMode themeMode, ThemePreset themePreset) {
    switch (_currentPage) {
      case _SettingsPage.menu:
        return _buildMenuPage();
      case _SettingsPage.profile:
        return _buildProfilePage();
      case _SettingsPage.invoice:
        return _buildInvoicePage(inv);
      case _SettingsPage.theme:
        return _buildThemePage(themeMode, themePreset);
      case _SettingsPage.services:
        return _buildServicesPage();
      case _SettingsPage.advanced:
        return _buildAdvancedPage();
      case _SettingsPage.about:
        return _buildAboutPage();
    }
  }

  Widget _buildMenuPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _menuCard(Icons.person_outline, 'Profile', 'Personal info, company, PRC, PTR', _SettingsPage.profile),
        const SizedBox(height: 8),
        _menuCard(Icons.receipt_long_outlined, 'Invoice Display', 'Invoice visibility toggles', _SettingsPage.invoice),
        const SizedBox(height: 8),
        _menuCard(Icons.palette_outlined, 'Theme', 'Light/Dark/System, color presets', _SettingsPage.theme),
        const SizedBox(height: 8),
        _menuCard(Icons.construction_outlined, 'Services', 'Rate configuration editors', _SettingsPage.services),
        const SizedBox(height: 8),
        _menuCard(Icons.tune_outlined, 'Advanced', 'Reset / Export / Import rates', _SettingsPage.advanced),
        const SizedBox(height: 8),
        _menuCard(Icons.info_outline, 'About', 'Survey Aide v2.0.0', _SettingsPage.about),
      ],
    );
  }

  Widget _menuCard(IconData icon, String title, String subtitle, _SettingsPage page) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _goToPage(page),
      ),
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _settingsCard(
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
          ],
        ),
        const SizedBox(height: 12),
        _settingsCard(
          children: [
            _sectionHeader('Company'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyCtrl,
              decoration: glassInputDecoration(context, labelText: 'Company Name', hintText: 'e.g. SURVEY AIDE'),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyAddressCtrl,
              decoration: glassInputDecoration(context, labelText: 'Company Address', hintText: 'e.g. 123 Rizal St., Manila'),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _companyPhoneCtrl,
                  decoration: glassInputDecoration(context, labelText: 'Phone', hintText: 'e.g. 09171234567'),
                  onChanged: (_) => _markDirty(),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  controller: _companyEmailCtrl,
                  decoration: glassInputDecoration(context, labelText: 'Email', hintText: 'e.g. hello@survey.com'),
                  onChanged: (_) => _markDirty(),
                )),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyTinCtrl,
              decoration: glassInputDecoration(context, labelText: 'TIN', hintText: 'e.g. 123-456-789-000'),
              onChanged: (_) => _markDirty(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _settingsCard(
          children: [
            _sectionHeader('Professional Licenses'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _prcLicenseCtrl,
              decoration: glassInputDecoration(context, labelText: 'PRC License No.', hintText: 'e.g. 0123456'),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 8),
            _buildDateField(
              controller: _prcDateCtrl,
              label: 'PRC License Date',
              hint: 'e.g. 2024-01-15',
              onChanged: () => (),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ptrCtrl,
              decoration: glassInputDecoration(context, labelText: 'PTR No.', hintText: 'e.g. 1234567'),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 8),
            _buildDateField(
              controller: _ptrDateCtrl,
              label: 'PTR Date',
              hint: 'e.g. 2024-01-15',
              onChanged: () => (),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: glassInputDecoration(
        context,
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, size: 18),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              onChanged();
            }
          },
        ),
      ),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildInvoicePage(InvoiceSettings inv) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _settingsCard(
          children: [
            _sectionHeader('Invoice Elements'),
            const SizedBox(height: 4),
            _invToggle('Company Info', 'Business name, address, contact, TIN', inv.showCompanyInfo, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showCompanyInfo: v));
              _markDirty();
            }),
            _invToggle('Invoice # & Date', 'Invoice number and issue date', inv.showInvoiceNumber, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showInvoiceNumber: v));
              _markDirty();
            }),
            _invToggle('Due Date', 'Payment due date indicator', inv.showDueDate, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showDueDate: v));
              _markDirty();
            }),
            _invToggle('Billing Address', 'Client billing address field', inv.showBillingAddress, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showBillingAddress: v));
              _markDirty();
            }),
            _invToggle('VAT Breakdown', 'Subtotal / VAT 12% / Grand Total', inv.showVatBreakdown, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showVatBreakdown: v));
              _markDirty();
            }),
            _invToggle('Payment Terms', '"Due by [date]" notice', inv.showPaymentTerms, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showPaymentTerms: v));
              _markDirty();
            }),
            _invToggle('Thank You Note', 'Custom message at the bottom', inv.showThankYouNote, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showThankYouNote: v));
              _markDirty();
            }),
            if (inv.showThankYouNote)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  initialValue: inv.thankYouNote,
                  decoration: glassInputDecoration(context, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) {
                    ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(thankYouNote: v));
                    _markDirty();
                  },
                ),
              ),
            _invToggle('Footer', 'Custom footer bar text', inv.showFooter, (v) {
              ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(showFooter: v));
              _markDirty();
            }),
            if (inv.showFooter)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  initialValue: inv.footerText,
                  decoration: glassInputDecoration(context, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) {
                    ref.read(invoiceSettingsProvider.notifier).save(inv.copyWith(footerText: v));
                    _markDirty();
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemePage(ThemeMode themeMode, ThemePreset themePreset) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _settingsCard(
          children: [
            _sectionHeader('Mode'),
            const SizedBox(height: 8),
            Center(child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.light_mode, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.dark_mode, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.settings_brightness, size: 16),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selected) {
                ref.read(themeProvider.notifier).setThemeMode(selected.first);
                _markDirty();
              },
              style: SegmentedButton.styleFrom(
                side: BorderSide.none,
                selectedBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                selectedForegroundColor: Theme.of(context).colorScheme.primary,
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 12),
        _settingsCard(
          children: [
            _sectionHeader('Color Preset'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ThemePreset.values.map((preset) {
                final pdark = Theme.of(context).brightness == Brightness.dark;
                final selected = preset == themePreset;
                final chipColor = preset.chipColor(pdark);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: chipColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(preset.label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) {
                    ref.read(themeProvider.notifier).setPreset(preset);
                    _markDirty();
                  },
                  selectedColor: chipColor.withValues(alpha: 0.2),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: selected ? chipColor : chipColor.withValues(alpha: 0.3),
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? chipColor : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _settingsCard(
          children: [
            _sectionHeader('Services'),
            const SizedBox(height: 8),
            TextField(
              decoration: glassInputDecoration(context, hintText: 'Search services...', prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              onChanged: (v) => setState(() => _rateSearch = v),
            ),
            const SizedBox(height: 8),
            _buildRateEditors(),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedPage() {
    final showFav = ref.watch(showFavTabProvider);
    final interp = ref.watch(interpolateProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _settingsCard(
          children: [
            _sectionHeader('General'),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Show Favorites tab'),
              subtitle: const Text('Display pinned services in a separate tab'),
              value: showFav,
              onChanged: (v) {
                ref.read(showFavTabProvider.notifier).state = v ?? false;
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 1),
            CheckboxListTile(
              title: const Text('Enable interpolation mode'),
              subtitle: const Text('Use proportional billing for partial quantities'),
              value: interp,
              onChanged: (v) {
                ref.read(interpolateProvider.notifier).state = v ?? false;
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _settingsCard(
          children: [
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildRegionRatesSummary(),
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
      ],
    );
  }

  Widget _buildAboutPage() {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Stack(
          children: [
            Card(
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _aboutCardTapTimer?.cancel();
                  _aboutCardTapCount++;
                  if (_aboutCardTapCount >= 10) {
                    _aboutCardTapCount = 0;
                    final now = DateTime.now();
                    final canToggle = _lastEasterEggToggle == null || now.difference(_lastEasterEggToggle!) >= const Duration(minutes: 1);
                    if (canToggle) {
                      _lastEasterEggToggle = now;
                      ref.read(surveyReturnsVisibleProvider.notifier).update((state) => !state);
                      final visible = ref.read(surveyReturnsVisibleProvider);
                      setState(() {
                        _confettiKey++;
                        _confettiActive = true;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) setState(() => _confettiActive = false);
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(visible ? 'Survey Returns unlocked!' : 'Survey Returns hidden!'),
                          backgroundColor: AppTheme.marker,
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    }
                    return;
                  }
                  _aboutCardTapTimer = Timer(const Duration(seconds: 30), () {
                    _aboutCardTapCount = 0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: theme.colorScheme.primary, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Survey Aide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Version 2.0.0', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All-in-one survey computation tool for Philippine geodetic engineers.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Developed by JG',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_confettiActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: _ConfettiBurstWidget(key: ValueKey(_confettiKey)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionDropdown() {
    final regionsAsync = ref.watch(regionListProvider);
    final setup = ref.watch(setupProvider);
    final currentRegion = _selectedRegionName.isNotEmpty ? _selectedRegionName : setup.region;

    return regionsAsync.when(
      data: (regions) {
        final selectedValue = regions.any((r) => r.code == currentRegion) ? currentRegion : regions.first.code;
        return DropdownButtonFormField<String>(
          initialValue: selectedValue,
          decoration: glassInputDecoration(context, labelText: 'Region'),
          isExpanded: true,
          items: regions.map((r) => DropdownMenuItem(
            value: r.code,
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

  Widget _settingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(label, style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
    ));
  }

  Widget _invToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildRegionRatesSummary() {
    final regionRatesAsync = ref.watch(regionRatesProvider);
    final regionsAsync = ref.watch(regionListProvider);
    final currentCode = ref.watch(selectedRegionCodeProvider);

    return regionRatesAsync.when(
      data: (regionRates) {
        if (regionRates.isEmpty) {
          return const Text('No region rates available',
              style: TextStyle(fontSize: 13, color: AppTheme.muted));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Regions with base rates',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...regionRates.entries.map((e) {
              final code = e.key;
              final count = e.value;
              final isCurrent = code == currentCode;
              final name = regionsAsync.valueOrNull
                      ?.where((r) => r.code == code || r.name == code)
                      .firstOrNull
                      ?.name ??
                  code;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      isCurrent ? Icons.check_circle : Icons.circle_outlined,
                      size: 14,
                      color: isCurrent ? AppTheme.brass : AppTheme.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$name  ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '($count services)',
                      style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Text('Loading regions...',
          style: TextStyle(fontSize: 13, color: AppTheme.muted)),
      error: (e, _) => Text('Error: $e',
          style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
    );
  }

  Widget _buildRateEditors() {
    final categoryOrder = ['A', 'B', 'C', 'D'];
    final servicesAsync = ref.watch(servicesProvider);
    final allServices = servicesAsync.valueOrNull ?? [];

    final serviceCodesByCat = <String, List<String>>{};
    final serviceNameMap = <String, String>{};
    final serviceRatesMap = <String, Map<String, double>>{};
    final serviceLabelsMap = <String, Map<String, String>>{};
    for (final s in allServices) {
      serviceCodesByCat.putIfAbsent(s.cat, () => []).add(s.code);
      serviceNameMap[s.code] = s.name;
      serviceRatesMap[s.code] = s.rates;
      serviceLabelsMap[s.code] = s.labels;
    }

    final allCodes = allServices.map((s) => s.code).toSet();
    final filteredCodes = allCodes.where((code) {
      if (_rateSearch.isEmpty) return true;
      final q = _rateSearch.toLowerCase();
      return code.toLowerCase().contains(q) ||
          (serviceNameMap[code] ?? '').toLowerCase().contains(q) ||
          (serviceLabelsMap[code]?['base'] ?? '').toLowerCase().contains(q);
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
          serviceRatesMap: serviceRatesMap,
          serviceLabelsMap: serviceLabelsMap,
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
  final Map<String, Map<String, double>> serviceRatesMap;
  final Map<String, Map<String, String>> serviceLabelsMap;
  final String rateSearch;
  final VoidCallback onChanged;

  const _CategoryRatesSection({
    required this.category,
    required this.codes,
    required this.serviceNameMap,
    required this.serviceRatesMap,
    required this.serviceLabelsMap,
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
                    defaultRates: widget.serviceRatesMap[code] ?? {},
                    labels: widget.serviceLabelsMap[code] ?? {},
                  )).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ConfettiBurstWidget extends StatefulWidget {
  const _ConfettiBurstWidget({super.key});

  @override
  State<_ConfettiBurstWidget> createState() => _ConfettiBurstWidgetState();
}

class _ConfettiBurstWidgetState extends State<_ConfettiBurstWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final List<_ConfettiParticle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    const colors = [
      Color(0xFFFFD700),
      Color(0xFFFFA500),
      Color(0xFFFF8C00),
      Color(0xFFFFF8DC),
      Color(0xFFFFE4B5),
      Color(0xFFFFDAB9),
    ];

    for (int i = 0; i < 45; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 150 + _rng.nextDouble() * 350;
      _particles.add(_ConfettiParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 150,
        color: colors[_rng.nextInt(colors.length)],
        size: 4 + _rng.nextDouble() * 7,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 10,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final gravity = 400;
    final opacity = (1.0 - progress * 0.6).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = cx + p.vx * progress;
      final y = cy + p.vy * progress + 0.5 * gravity * progress * progress;
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * progress);

      final half = p.size / 2;
      final rrect = RRect.fromLTRBR(-half, -half, half, half,
          Radius.circular(p.size * 0.3));
      canvas.drawRRect(rrect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
