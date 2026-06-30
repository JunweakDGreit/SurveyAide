import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import 'traverse_screen.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  int _tab = 0;
  bool _gridMode = true;

  @override
  void initState() {
    super.initState();
    _tab = int.tryParse(StorageService().getString('gep_tools_tab', def: '0')) ?? 0;
    _gridMode = StorageService().getBool('gep_tools_grid_mode', def: true);
  }

  List<_ToolItem> get _tools => const [
        _ToolItem('Traverse', Icons.route, 'Traverse computation with Compass/Transit Rule adjustment and area', AppTheme.brass, false),
        _ToolItem('Coordinate Transform', Icons.swap_horiz, 'WGS84 \u2194 PRS92, UTM \u2194 PTM, datum shift', AppTheme.steel, true),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Go to Calculator',
          onPressed: () => context.go('/'),
        ),
        title: const Text('Survey Tools'),
        actions: _tab == 0
            ? [
                IconButton(
                  icon: Icon(_gridMode ? Icons.view_list_outlined : Icons.grid_view_outlined),
                  tooltip: _gridMode ? 'List view' : 'Grid view',
                  onPressed: () => setState(() {
                    _gridMode = !_gridMode;
                    StorageService().setBool('gep_tools_grid_mode', _gridMode);
                  }),
                ),
              ]
            : [],
      ),
      body: switch (_tab) {
        1 => _buildHistory(),
        2 => _buildSaved(),
        _ => _buildToolsGrid(),
      },
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: glassBackdrop(
          context,
          radius: 24,
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
              BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Saved'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    final tools = _tools;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Select a tool', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          const SizedBox(height: 12),
          Expanded(
            child: _gridMode
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
      padding: const EdgeInsets.all(16),
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
    final area = item['areaHa'] as num?;
    final method = item['method'] as String? ?? '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
      ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraverseScreen(initialData: item))),
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
              if (area != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${area.toStringAsFixed(4)} ha', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaved() {
    final savedItem = _loadSaved();
    final saved = savedItem != null ? [savedItem] : <Map<String, dynamic>>[];
    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: AppTheme.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No saved traverses', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted)),
            const SizedBox(height: 4),
            Text('Save a traverse using the Save button', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: saved.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildSavedCard(saved[i], i),
    );
  }

  Widget _buildSavedCard(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final name = item['name'] as String? ?? 'Unnamed Traverse';
    final points = (item['points'] as List?)?.length ?? 0;
    final startN = item['startN'] as String? ?? '';
    final startE = item['startE'] as String? ?? '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
      ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TraverseScreen(initialData: item))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.steel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder, color: AppTheme.steel, size: 22),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('$points points', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
                    if (startN.isNotEmpty && startE.isNotEmpty)
                      Text('N: $startN  E: $startE', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
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

  Map<String, dynamic>? _loadSaved() {
    final jsonStr = StorageService().getString('gep_traverse_data');
    if (jsonStr.isEmpty) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class _ToolListTile extends StatelessWidget {
  final _ToolItem tool;
  const _ToolListTile({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: tool.comingSoon
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraverseScreen())),
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
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: tool.comingSoon
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraverseScreen())),
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
      ),
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
