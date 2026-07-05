import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../providers/layout_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme_presets.dart';
import 'traverse_screen.dart';

class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});

  @override
  ConsumerState<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends ConsumerState<ToolsPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tab = int.tryParse(StorageService().getString('gep_tools_tab', def: '0')) ?? 0;
  }

  List<_ToolItem> get _tools => const [
        _ToolItem('Traverse', Icons.route, 'Traverse computation with Compass/Transit Rule adjustment and area', AppTheme.brass, false),
        _ToolItem('Coordinate Transform', Icons.swap_horiz, 'WGS84 \u2194 PRS92, UTM \u2194 PTM, datum shift', AppTheme.steel, true),
      ];

  @override
  Widget build(BuildContext context) {
    final preset = ref.watch(themeProvider).preset;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presetColors = isDark ? preset.dark() : preset.light();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Tools'),
      ),
      body: Stack(
        children: [
          PageTransitionSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: switch (_tab) {
              1 => _buildHistory(),
              _ => _buildToolsGrid(),
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: glassBackdrop(
                context,
                radius: 24,
                background: presetColors.cardColor,
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: _tab,
                  onTap: (i) => setState(() {
                    _tab = i;
                    StorageService().setString('gep_tools_tab', i.toString());
                  }),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid() {
    final tools = _tools;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Select a tool', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          const SizedBox(height: 12),
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
                key: ValueKey('tools_${ref.watch(gridModeProvider)}'),
                child: ref.watch(gridModeProvider)
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: tools.length,
                        itemBuilder: (_, i) => _ToolCard(tool: tools[i]),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: tools.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _ToolListTile(tool: tools[i]),
                      ),
              ),
            ),
            ),
        ],
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
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

    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedBuilder: (_, action) => Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
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
      openBuilder: (_, action) => TraverseScreen(initialData: item),
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

class _ToolListTile extends StatelessWidget {
  final _ToolItem tool;
  const _ToolListTile({required this.tool});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tool.icon, color: tool.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(tool.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      if (tool.comingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.ink.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Coming Soon', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted.withValues(alpha: 0.7))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tool.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 12)),
                ],
              ),
            ),
            Icon(tool.comingSoon ? Icons.lock_outline : Icons.chevron_right, color: AppTheme.muted),
          ],
        ),
      ),
    );

    if (tool.comingSoon) return card;

    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedBuilder: (_, action) => card,
      openBuilder: (_, action) => const TraverseScreen(),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tool.icon, color: tool.color, size: 22),
            ),
            const Spacer(),
            Text(tool.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(tool.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (tool.comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Coming Soon', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted.withValues(alpha: 0.7))),
              ),
          ],
        ),
      ),
    );

    if (tool.comingSoon) return card;

    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      openShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      closedBuilder: (_, action) => card,
      openBuilder: (_, action) => const TraverseScreen(),
    );
  }
}

class _ToolItem {
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  final bool comingSoon;

  const _ToolItem(this.name, this.icon, this.description, this.color, this.comingSoon);
}
