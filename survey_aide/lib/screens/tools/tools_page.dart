import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme_presets.dart';
import '../settings/settings_sheet.dart';
import 'traverse_screen.dart';

class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});

  @override
  ConsumerState<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends ConsumerState<ToolsPage> {
  int _tab = 0;
  final _traverseKey = GlobalKey<TraverseScreenState>();

  @override
  void initState() {
    super.initState();
    _tab = (int.tryParse(StorageService().getString('gep_tools_tab', def: '0')) ?? 0).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final preset = ref.watch(themeProvider).preset;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presetColors = isDark ? preset.dark() : preset.light();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Tools'),
        actions: [
          if (_tab == 0) ...[
            IconButton(
              icon: const Icon(Icons.folder_open_outlined),
              tooltip: 'Load',
              onPressed: () => _traverseKey.currentState?.triggerLoadDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save',
              onPressed: () => _traverseKey.currentState?.triggerSave(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => SettingsSheet.show(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          TraverseScreen(key: _traverseKey, embedded: true),
          _buildHistory(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: glassBackdrop(
          context,
          radius: 24,
          opacity: 0.92,
          background: presetColors.cardColor,
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _tab,
            onTap: _onNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavTap(int i) {
    setState(() {
      _tab = i;
      StorageService().setString('gep_tools_tab', '$i');
    });
  }

  Widget _buildHistory() {
    final history = _loadHistory();
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: AppTheme.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No computation history', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted)),
            const SizedBox(height: 4),
            Text('Compute a traverse to see results here', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildHistoryCard(history[i], i),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final name = item['name'] as String? ?? 'Unnamed Traverse';
    final date = item['date'] as String? ?? '';
    final precision = item['precision'] as String? ?? '';
    final areaSqm = item['areaSqm'] as num?;
    final method = item['method'] as String? ?? '';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _traverseKey.currentState?.loadFromData(item);
          setState(() => _tab = 0);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.brass.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route, color: AppTheme.brass, size: 22),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (method.isNotEmpty)
                    Text(method, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
                  if (precision.isNotEmpty || date.isNotEmpty)
                    Text(
                      [if (precision.isNotEmpty) precision, if (date.isNotEmpty) date].join(' \u00B7 '),
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (areaSqm != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${areaSqm.round()} sqm', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _deleteHistoryItem(index),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: AppTheme.muted.withValues(alpha: 0.6)),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _deleteHistoryItem(int index) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete',
      message: 'Remove this traverse from history?',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    final jsonStr = StorageService().getString('gep_traverse_history');
    if (jsonStr.isEmpty) return;
    try {
      final list = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
      list.removeAt(index);
      StorageService().setString('gep_traverse_history', json.encode(list));
      setState(() {});
    } catch (_) {}
  }

  List<Map<String, dynamic>> _loadHistory() {
    final jsonStr = StorageService().getString('gep_traverse_history');
    if (jsonStr.isEmpty) return [];
    try {
      final list = json.decode(jsonStr) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
