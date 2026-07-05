import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../providers/appointment_provider.dart';
import 'appointment_form.dart';

class ScheduleView extends ConsumerStatefulWidget {
  const ScheduleView({super.key});

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showUpcoming = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointments = ref.watch(appointmentProvider);

    final eventsForSelected = appointments.where((a) =>
      a.date.year == _selectedDay.year &&
      a.date.month == _selectedDay.month &&
      a.date.day == _selectedDay.day
    ).toList();

    final now = DateTime.now();
    final upcomingAppts = appointments.where((a) =>
      !a.date.isBefore(DateTime(now.year, now.month, now.day))
    ).toList()..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            locale: 'en_US',
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              titleTextStyle: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.brass),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.brass),
              formatButtonDecoration: BoxDecoration(
                color: AppTheme.brass.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              formatButtonTextStyle: const TextStyle(color: AppTheme.brass, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppTheme.brass,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.brass.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.marker,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
            eventLoader: (day) {
              return appointments.where((a) =>
                a.date.year == day.year &&
                a.date.month == day.month &&
                a.date.day == day.day
              ).toList();
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Selected Day'), icon: Icon(Icons.calendar_view_day, size: 16)),
                ButtonSegment(value: true, label: Text('Upcoming'), icon: Icon(Icons.upcoming, size: 16)),
              ],
              selected: {_showUpcoming},
              onSelectionChanged: (v) => setState(() => _showUpcoming = v.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
              ),
            ),
          ),
          Expanded(
            child: _showUpcoming
                ? _buildUpcomingList(upcomingAppts, appointments, theme)
                : _buildSelectedDayList(eventsForSelected, appointments, theme),
          ),
        ],
      ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _addAppointment(context),
          backgroundColor: AppTheme.brass,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _addAppointment(BuildContext context) async {
    final result = await showDialog<Appointment>(
      context: context,
      builder: (_) => AppointmentForm(selectedDate: _selectedDay),
    );
    if (result != null && context.mounted) {
      ref.read(appointmentProvider.notifier).add(result);
    }
  }

  Future<void> _editAppointment(BuildContext context, int index, Appointment appt) async {
    final result = await showDialog<Appointment>(
      context: context,
      builder: (_) => AppointmentForm(appointment: appt),
    );
    if (result != null && context.mounted) {
      ref.read(appointmentProvider.notifier).update(index, result);
    }
  }

  Widget? _buildSubtitle(Appointment appt, ThemeData theme) {
    final parts = <String>[];
    if (appt.serviceLabel != null) parts.add(appt.serviceLabel!);
    if (appt.note.isNotEmpty) parts.add(appt.note);
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: theme.textTheme.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAppointmentCard(Appointment appt, int apptIndex, List<Appointment> allAppts, ThemeData theme, {String? dateSubtitle}) {
    return Dismissible(
      key: ValueKey('${apptIndex}_${appt.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.marker,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(appointmentProvider.notifier).remove(apptIndex);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.brass.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event, color: AppTheme.brass, size: 22),
          ),
          title: Text(appt.title, style: theme.textTheme.titleSmall),
          subtitle: dateSubtitle != null
              ? Text(dateSubtitle, style: theme.textTheme.bodySmall)
              : _buildSubtitle(appt, theme),
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
          onTap: () => _editAppointment(context, apptIndex, appt),
        ),
      ),
    );
  }

  Widget _buildSelectedDayList(List<Appointment> events, List<Appointment> allAppts, ThemeData theme) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 40, color: AppTheme.rule),
            const SizedBox(height: 8),
            Text(
              'No appointments on this day',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _addAppointment(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Appointment'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (_, i) {
        final apptIndex = allAppts.indexOf(events[i]);
        return _buildAppointmentCard(events[i], apptIndex, allAppts, theme);
      },
    );
  }

  Widget _buildUpcomingList(List<Appointment> upcoming, List<Appointment> allAppts, ThemeData theme) {
    if (upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note, size: 40, color: AppTheme.rule),
            const SizedBox(height: 8),
            Text(
              'No upcoming appointments',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _addAppointment(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Appointment'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcoming.length,
      itemBuilder: (_, i) {
        final apptIndex = allAppts.indexOf(upcoming[i]);
        final dateStr = upcoming[i].date.toLocal().toString().split(' ')[0];
        return _buildAppointmentCard(
          upcoming[i], apptIndex, allAppts, theme,
          dateSubtitle: '$dateStr · ${_buildSubtitleText(upcoming[i])}',
        );
      },
    );
  }

  String _buildSubtitleText(Appointment appt) {
    final parts = <String>[];
    if (appt.serviceLabel != null) parts.add(appt.serviceLabel!);
    if (appt.note.isNotEmpty) parts.add(appt.note);
    return parts.isNotEmpty ? parts.join(' · ') : '';
  }
}
