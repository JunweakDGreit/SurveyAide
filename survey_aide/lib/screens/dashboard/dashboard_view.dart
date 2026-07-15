import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/uiprovider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider);
    final pageIndex = ref.watch(pageViewIndexProvider);
    final isActive = pageIndex == 0;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
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
          child: isActive ? _buildContent(stats, theme) : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardStats stats, ThemeData theme) {
    return Column(
      key: const ValueKey('dashboard_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Overview of your surveying services',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ServicesCard(
                stats: stats,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_outlined,
                label: 'Total Income',
                value: peso(stats.totalIncome),
                color: AppTheme.brass,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_down_outlined,
                label: 'Total Expense',
                value: peso(stats.totalExpense),
                color: AppTheme.marker,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Net Income',
                value: peso(stats.netIncome),
                color: AppTheme.accent,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.calendar_month_outlined,
          label: 'Upcoming Schedules',
          value: '${stats.upcomingSchedules}',
          color: Colors.indigo,
          theme: theme,
          fullWidth: true,
        ),
        const SizedBox(height: 24),
        Text('Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._buildInsights(stats, theme),
      ],
    );
  }

  List<Widget> _buildInsights(DashboardStats stats, ThemeData theme) {
    final insights = <Widget>[];

    if (stats.unpaidReceivables > 0) {
      insights.add(_InsightCard(
        icon: Icons.warning_amber_rounded,
        text: 'You have ${peso(stats.unpaidReceivables)} in unpaid receivables',
        color: AppTheme.marker,
        theme: theme,
      ));
    }

    if (stats.mostUsedService != '—') {
      insights.add(_InsightCard(
        icon: Icons.star_outline,
        text: 'Most-used service: ${stats.mostUsedService}',
        color: AppTheme.brass,
        theme: theme,
      ));
    }

    if (stats.appointmentsThisWeek > 0) {
      insights.add(_InsightCard(
        icon: Icons.event,
        text: '${stats.appointmentsThisWeek} appointment${stats.appointmentsThisWeek == 1 ? '' : 's'} this week',
        color: Colors.indigo,
        theme: theme,
      ));
    }

    if (stats.topClient != '—') {
      insights.add(_InsightCard(
        icon: Icons.person_outline,
        text: 'Top client by revenue: ${stats.topClient}',
        color: AppTheme.accent,
        theme: theme,
      ));
    }

    if (insights.isEmpty) {
      insights.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Start adding services from the Calculator tab to see insights.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
        ),
      ));
    }

    return insights;
  }
}

class _ServicesCard extends StatelessWidget {
  final DashboardStats stats;
  final Color color;
  final ThemeData theme;

  const _ServicesCard({
    required this.stats,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats.totalServices;
    final hasAny = total > 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.design_services_outlined, size: 22, color: color),
            ),
            const SizedBox(height: 12),
            Text('Services', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
            const SizedBox(height: 2),
            Text('$total', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    if (stats.servicesPast > 0)
                      Flexible(
                        flex: stats.servicesPast,
                        child: Container(color: const Color(0xFF4CAF50)),
                      ),
                    if (stats.servicesToday > 0)
                      Flexible(
                        flex: stats.servicesToday,
                        child: Container(color: Colors.indigo),
                      ),
                    if (stats.servicesUnscheduled > 0)
                      Flexible(
                        flex: stats.servicesUnscheduled,
                        child: Container(color: AppTheme.muted),
                      ),
                    if (!hasAny) Expanded(child: Container(color: theme.dividerColor.withValues(alpha: 0.3))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (stats.servicesPast > 0 || stats.servicesToday > 0 || stats.servicesUnscheduled > 0) ...[
              if (stats.servicesPast > 0) _BreakdownRow(label: 'Done', count: stats.servicesPast, color: const Color(0xFF4CAF50), theme: theme),
              if (stats.servicesToday > 0) _BreakdownRow(label: 'Ongoing', count: stats.servicesToday, color: Colors.indigo, theme: theme),
              if (stats.servicesUnscheduled > 0) _BreakdownRow(label: 'Unscheduled', count: stats.servicesUnscheduled, color: AppTheme.muted, theme: theme),
            ] else
              Text('No services yet', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final ThemeData theme;

  const _BreakdownRow({
    required this.label,
    required this.count,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$count $label', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
                        const SizedBox(height: 2),
                        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final ThemeData theme;

  const _InsightCard({
    required this.icon,
    required this.text,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ),
      ),
    );
  }
}
