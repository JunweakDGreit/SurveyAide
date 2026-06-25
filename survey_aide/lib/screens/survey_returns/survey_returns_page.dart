import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';

class SurveyReturnsPage extends StatefulWidget {
  const SurveyReturnsPage({super.key});

  @override
  State<SurveyReturnsPage> createState() => _SurveyReturnsPageState();
}

class _SurveyReturnsPageState extends State<SurveyReturnsPage> {
  int _tab = 0;
  bool _gridMode = false;

  @override
  void initState() {
    super.initState();
    _tab = StorageService().getString('gep_survey_returns_tab', def: '0') == '1'
        ? 1
        : StorageService().getString('gep_survey_returns_tab', def: '0') == '2'
            ? 2
            : 0;
    _gridMode = StorageService().getBool('gep_survey_returns_grid_mode', def: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
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
              StorageService().setString('gep_survey_returns_tab', i.toString());
            }),
            items: const [
            BottomNavigationBarItem(icon: Icon(Icons.checklist_outlined), activeIcon: Icon(Icons.checklist), label: 'Checklist'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_tab == 1) return _buildReportsPlaceholder();
    if (_tab == 2) return _buildHistoryPlaceholder();
    return _buildChecklist();
  }

  Widget _buildChecklist() {
    final items = [
      const _ReturnItem('Traverse Computation', 'DENR traverse computation worksheet', Icons.route, _Status.notStarted),
      const _ReturnItem('Setting Computation', 'Survey instrument setting computation', Icons.settings, _Status.notStarted),
      const _ReturnItem('Lot Data Computation', 'LMB Form GSD-B-11 lot data worksheet', Icons.table_chart, _Status.notStarted),
      const _ReturnItem('Technical Description', 'DENR metes-and-bounds narrative', Icons.description, _Status.notStarted),
      const _ReturnItem('DLSD XML Export', 'DENR DLSD XML export', Icons.code, _Status.notStarted),
      const _ReturnItem('Field Notes', 'DENR field notes template', Icons.note_alt, _Status.notStarted),
      const _ReturnItem('Monument Recovery', 'Monument recovery sheet', Icons.location_city, _Status.notStarted),
      const _ReturnItem('Survey Returns Checklist', 'DENR documentary requirements checklist', Icons.fact_check, _Status.notStarted),
      const _ReturnItem('Point Data Export', 'CSV / TRD / TRX export', Icons.file_present, _Status.notStarted),
      const _ReturnItem('Lot Index & Boundary', 'LDX / PBF boundary index', Icons.border_style, _Status.notStarted),
    ];

    final completed = items.where((i) => i.status == _Status.complete).length;
    final progress = items.isEmpty ? 0.0 : completed / items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('DENR Survey Returns', style: Theme.of(context).textTheme.headlineSmall)),
            IconButton(
              icon: Icon(_gridMode ? Icons.view_list_outlined : Icons.grid_view_outlined),
              tooltip: _gridMode ? 'List view' : 'Grid view',
              onPressed: () => setState(() {
                _gridMode = !_gridMode;
                StorageService().setBool('gep_survey_returns_grid_mode', _gridMode);
              }),
            ),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, backgroundColor: AppTheme.rule, minHeight: 6, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brass)),
          ),
          const SizedBox(height: 4),
          Text('$completed / ${items.length} requirements completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
          const SizedBox(height: 12),
          Expanded(
            child: _gridMode ? _buildGrid(items) : _buildList(items),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_ReturnItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = items[i];
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _statusColor(item.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: _statusColor(item.status), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                  _StatusBadge(status: item.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<_ReturnItem> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
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
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(item.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: _statusColor(item.status), size: 18),
                    ),
                    const Spacer(),
                    _StatusBadge(status: item.status, compact: true),
                  ]),
                  const Spacer(),
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(_Status s) => switch (s) {
    _Status.complete => const Color(0xFF2E7D32),
    _Status.inProgress => AppTheme.brass,
    _Status.notStarted => AppTheme.muted,
  };

  Widget _buildReportsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _gridMode ? _buildReportsGrid() : _buildReportsList(),
    );
  }

  Widget _buildReportsList() {
    final reports = [
      const _ReturnItem('Traverse Report', 'TRAVERSE.pdf', Icons.assessment, _Status.notStarted),
      const _ReturnItem('Setting Report', 'SETTING.pdf', Icons.settings, _Status.notStarted),
      const _ReturnItem('Field Notes', 'FIELD_NOTES.pdf', Icons.note_alt, _Status.notStarted),
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: reports.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.rule.withValues(alpha: 0.5)),
      itemBuilder: (_, index) {
        final item = reports[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Icon(item.icon, color: _statusColor(item.status)),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          trailing: _StatusBadge(status: item.status),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildReportsGrid() {
    final reports = [
      const _ReturnItem('Traverse Report', 'TRAVERSE.pdf', Icons.assessment, _Status.notStarted),
      const _ReturnItem('Setting Report', 'SETTING.pdf', Icons.settings, _Status.notStarted),
      const _ReturnItem('Field Notes', 'FIELD_NOTES.pdf', Icons.note_alt, _Status.notStarted),
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: reports.length,
      itemBuilder: (_, index) {
        final item = reports[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6))),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(item.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: _statusColor(item.status), size: 18),
                    ),
                    const Spacer(),
                    _StatusBadge(status: item.status, compact: true),
                  ]),
                  const Spacer(),
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryPlaceholder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _gridMode ? _buildHistoryGrid() : _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    final history = [
      const _ReturnItem('March Return', '03/2026', Icons.event, _Status.complete),
      const _ReturnItem('February Return', '02/2026', Icons.event, _Status.complete),
      const _ReturnItem('January Return', '01/2026', Icons.event, _Status.inProgress),
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: history.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.rule.withValues(alpha: 0.5)),
      itemBuilder: (_, index) {
        final item = history[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Icon(item.icon, color: _statusColor(item.status)),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          trailing: _StatusBadge(status: item.status),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildHistoryGrid() {
    final history = [
      const _ReturnItem('March Return', '03/2026', Icons.event, _Status.complete),
      const _ReturnItem('February Return', '02/2026', Icons.event, _Status.complete),
      const _ReturnItem('January Return', '01/2026', Icons.event, _Status.inProgress),
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: history.length,
      itemBuilder: (_, index) {
        final item = history[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.rule.withValues(alpha: 0.6))),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(item.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: _statusColor(item.status), size: 18),
                    ),
                    const Spacer(),
                    _StatusBadge(status: item.status, compact: true),
                  ]),
                  const Spacer(),
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _Status { notStarted, inProgress, complete }

class _ReturnItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final _Status status;
  const _ReturnItem(this.name, this.subtitle, this.icon, this.status);
}

class _StatusBadge extends StatelessWidget {
  final _Status status;
  final bool compact;
  const _StatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _Status.complete => ('Done', const Color(0xFF2E7D32)),
      _Status.inProgress => ('Progress', AppTheme.brass),
      _Status.notStarted => ('Pending', AppTheme.muted),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: compact ? 9 : 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
