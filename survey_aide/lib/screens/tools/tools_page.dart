import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  int _tab = 0;
  bool _gridMode = false;

  @override
  void initState() {
    super.initState();
    _tab = int.tryParse(StorageService().getString('gep_tools_tab', def: '0')) ?? 0;
    _gridMode = StorageService().getBool('gep_tools_grid_mode', def: false);
  }

  List<_ToolItem> get _tools => const [
        _ToolItem('Point Entry', Icons.edit_location_alt, 'Enter tie points via geographic, grid, or bearing-distance', AppTheme.brass),
        _ToolItem('Coordinate Transform', Icons.swap_horiz, 'WGS84 ↔ PRS92, UTM ↔ PTM, datum shift', AppTheme.steel),
        _ToolItem('Zone Detection', Icons.explore, 'Auto-detect PRS92 or UTM zone from coordinates', AppTheme.marker),
        _ToolItem('Bearing & Distance', Icons.straighten, 'Compute bearing and distance between two points', AppTheme.ink),
        _ToolItem('Traverse Closure', Icons.route, 'Compass Rule / Transit Rule closure with precision check', AppTheme.brass),
        _ToolItem('Area Computation', Icons.square_foot, 'Shoelace, DMD, and cross-multiplication methods', AppTheme.steel),
        _ToolItem('Lot Data (LDC)', Icons.table_chart, 'LMB Form GSD-B-11 lot data computation sheet', AppTheme.marker),
        _ToolItem('Technical Description', Icons.description, 'DENR metes-and-bounds narrative generator', AppTheme.ink),
        _ToolItem('Export Documents', Icons.file_download, 'TRAVERSE, LDC, DLSD, TechDesc, TRD/TRX', AppTheme.brass),
        _ToolItem('Monument Data', Icons.location_city, 'BLLM, PSM, and monument recovery sheets', AppTheme.steel),
        _ToolItem('Field Notes', Icons.note_alt, 'DENR field notes template generator', AppTheme.marker),
        _ToolItem('GPS / Map Tools', Icons.map, 'Live GPS location, map click point placement', AppTheme.ink),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: _tab == 0 ? _buildToolsGrid() : _buildComingSoon(),
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
            BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build), label: 'Tools'),
            BottomNavigationBarItem(icon: Icon(Icons.construction_outlined), activeIcon: Icon(Icons.construction), label: 'More'),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Select a tool to get started', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          const SizedBox(height: 12),
          Expanded(
            child: _gridMode ? _buildToolsList() : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _tools.length,
              itemBuilder: (_, i) => _ToolCard(tool: _tools[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _tools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ToolListTile(tool: _tools[i]),
    );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 64, color: AppTheme.muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('More tools coming soon', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.muted)),
        ],
      ),
    );
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tool.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(tool.icon, color: tool.color, size: 22),
        ),
        title: Text(tool.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(tool.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
        onTap: () {},
      ),
    );
  }
}

class _ToolItem {
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  const _ToolItem(this.name, this.icon, this.description, this.color);
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
        onTap: () {},
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
