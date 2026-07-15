import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/helpers.dart';
import 'quote_provider.dart';
import 'payment_provider.dart';
import 'expense_provider.dart';
import 'appointment_provider.dart';

class DashboardStats {
  final int servicesPast;
  final int servicesToday;
  final int servicesFuture;
  final int servicesUnscheduled;
  final int totalServices;
  final double totalIncome;
  final double totalExpense;
  final double netIncome;
  final int upcomingSchedules;
  final double unpaidReceivables;
  final String mostUsedService;
  final int appointmentsThisWeek;
  final String topClient;

  const DashboardStats({
    required this.servicesPast,
    required this.servicesToday,
    required this.servicesFuture,
    required this.servicesUnscheduled,
    required this.totalServices,
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
    required this.upcomingSchedules,
    required this.unpaidReceivables,
    required this.mostUsedService,
    required this.appointmentsThisWeek,
    required this.topClient,
  });
}

final dashboardProvider = Provider<DashboardStats>((ref) {
  final items = ref.watch(quoteProvider);
  final payments = ref.watch(paymentProvider);
  final expenses = ref.watch(expenseProvider);
  final appointments = ref.watch(appointmentProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekEnd = today.add(const Duration(days: 7));

  int servicesPast = 0;
  int servicesToday = 0;
  int servicesFuture = 0;
  int servicesUnscheduled = 0;

  for (final item in items) {
    final itemAppts = appointments.where((a) => a.itemUid == item.uid).toList();
    if (itemAppts.isEmpty) {
      servicesUnscheduled++;
      continue;
    }
    itemAppts.sort((a, b) => a.date.compareTo(b.date));
    final apptDay = DateTime(
      itemAppts.first.date.year,
      itemAppts.first.date.month,
      itemAppts.first.date.day,
    );
    if (apptDay.isBefore(today)) {
      servicesPast++;
    } else if (apptDay == today) {
      servicesToday++;
    } else {
      servicesFuture++;
    }
  }

  double totalIncome = 0;
  for (final item in items) {
    final basis = item.overriddenTotal ?? item.lines.fold<double>(0, (s, l) => s + l.amount);
    final itemPayments = payments[item.uid] ?? [];
    totalIncome += itemPayments.where((i) => i.paid).fold<double>(0, (s, i) => s + i.amount(basis));
  }

  double totalExpense = 0;
  for (final item in items) {
    final basis = item.overriddenTotal ?? item.lines.fold<double>(0, (s, l) => s + l.amount);
    final itemExpenses = expenses[item.uid] ?? [];
    totalExpense += itemExpenses.fold<double>(0, (s, e) => s + e.computeAmount(basis, 0));
  }

  final netIncome = totalIncome - totalExpense;

  final upcomingSchedules = appointments.where((a) => !a.date.isBefore(today)).length;

  double unpaidReceivables = 0;
  for (final item in items) {
    final basis = item.overriddenTotal ?? item.lines.fold<double>(0, (s, l) => s + l.amount);
    final itemPayments = payments[item.uid] ?? [];
    unpaidReceivables += itemPayments.where((i) => !i.paid).fold<double>(0, (s, i) => s + i.amount(basis));
  }

  final codeCount = <String, int>{};
  for (final item in items) {
    final label = serviceLabel(item.code, item.name);
    codeCount[label] = (codeCount[label] ?? 0) + 1;
  }
  String mostUsedService = '—';
  if (codeCount.isNotEmpty) {
    final sorted = codeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    mostUsedService = sorted.first.key;
  }

  final appointmentsThisWeek = appointments.where((a) {
    return !a.date.isBefore(today) && a.date.isBefore(weekEnd);
  }).length;

  final clientRevenue = <String, double>{};
  for (final item in items) {
    final basis = item.overriddenTotal ?? item.lines.fold<double>(0, (s, l) => s + l.amount);
    final itemPayments = payments[item.uid] ?? [];
    final paid = itemPayments.where((i) => i.paid).fold<double>(0, (s, i) => s + i.amount(basis));
    clientRevenue[item.client] = (clientRevenue[item.client] ?? 0) + paid;
  }
  String topClient = '—';
  if (clientRevenue.isNotEmpty) {
    final sorted = clientRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topClient = sorted.first.key;
  }

  final totalServices = servicesPast + servicesToday + servicesFuture + servicesUnscheduled;

  return DashboardStats(
    servicesPast: servicesPast,
    servicesToday: servicesToday,
    servicesFuture: servicesFuture,
    servicesUnscheduled: servicesUnscheduled,
    totalServices: totalServices,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netIncome: netIncome,
    upcomingSchedules: upcomingSchedules,
    unpaidReceivables: unpaidReceivables,
    mostUsedService: mostUsedService,
    appointmentsThisWeek: appointmentsThisWeek,
    topClient: topClient,
  );
});
