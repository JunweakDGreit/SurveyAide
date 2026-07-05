import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/quote_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/expense_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/calculator_dialog.dart';
import 'installment_form.dart';
import 'expense_form.dart';

class PaymentView extends ConsumerWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quoteProvider);
    final payments = ref.watch(paymentProvider);
    final allAppointments = ref.watch(appointmentProvider);
    final expenses = ref.watch(expenseProvider);
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return SafeArea(child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.credit_card_outlined, size: 64, color: AppTheme.rule),
            const SizedBox(height: 16),
            Text('No payment items', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Add services from the Calculator tab', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
      );
    }

    final grouped = <String, List<QuoteEntry>>{};
    for (final item in items) {
      final key = item.client;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return SafeArea(child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (entry.value.first.location.isNotEmpty)
                        Text(entry.value.first.location, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final item in entry.value) ...[
            _PaymentItemCard(
              item: item,
              installments: payments[item.uid] ?? [],
              expenses: expenses[item.uid] ?? [],
              itemAppointments: allAppointments.where((a) => a.itemUid == item.uid).toList(),
              onAddInstallment: () => _addInstallment(context, ref, item.uid),
              onAddSchedule: () => _addSchedule(context, ref, item),
              onEditInstallment: (index, inst) => _editInstallment(context, ref, item.uid, index, inst),
              onDeleteInstallment: (index) => ref.read(paymentProvider.notifier).removeInstallment(item.uid, index),
              onAddExpense: () => _addExpense(context, ref, item.uid),
              onEditExpense: (index, entry) => _editExpense(context, ref, item.uid, index, entry),
              onDeleteExpense: (index) => ref.read(expenseProvider.notifier).removeExpense(item.uid, index),
              onCalculator: () => _showCalculator(context),
              onEdit: () => _editItem(context, ref, item),
              onDelete: () => _deleteItem(context, ref, item),
              onShare: () => _showInvoiceShare(context, item),
              onEditBasis: () => _editBasis(context, ref, item),
            ),
            const SizedBox(height: 8),
          ],
          const Divider(height: 24),
        ],
      ],
    ));
  }

  void _addInstallment(BuildContext context, WidgetRef ref, String itemUid) async {
    final result = await showDialog<Installment>(
      context: context,
      builder: (_) => const InstallmentForm(),
    );
    if (result != null) {
      ref.read(paymentProvider.notifier).addInstallment(itemUid, result);
    }
  }

  void _addSchedule(BuildContext context, WidgetRef ref, QuoteEntry item) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !context.mounted) return;
    final label = serviceLabel(item.code, item.name);
    ref.read(appointmentProvider.notifier).add(Appointment(
      title: label,
      date: picked,
      serviceLabel: label,
      itemUid: item.uid,
    ));
  }

  void _editInstallment(BuildContext context, WidgetRef ref, String itemUid, int index, Installment inst) async {
    final result = await showDialog<Installment>(
      context: context,
      builder: (_) => InstallmentForm(installment: inst),
    );
    if (result != null) {
      ref.read(paymentProvider.notifier).updateInstallment(itemUid, index, result);
    }
  }

  void _addExpense(BuildContext context, WidgetRef ref, String itemUid) async {
    final result = await showDialog<ExpenseEntry>(
      context: context,
      builder: (_) => const ExpenseForm(),
    );
    if (result != null) {
      ref.read(expenseProvider.notifier).addExpense(itemUid, result);
    }
  }

  void _editExpense(BuildContext context, WidgetRef ref, String itemUid, int index, ExpenseEntry entry) async {
    final result = await showDialog<ExpenseEntry>(
      context: context,
      builder: (_) => ExpenseForm(expense: entry),
    );
    if (result != null) {
      ref.read(expenseProvider.notifier).updateExpense(itemUid, index, result);
    }
  }

  Future<void> _showCalculator(BuildContext context) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => const CalculatorDialog(),
    );
    if (result != null) {
      await Clipboard.setData(ClipboardData(text: result.toStringAsFixed(2)));
    }
  }

  Future<void> _editItem(BuildContext context, WidgetRef ref, QuoteEntry item) async {
    final nameCtrl = TextEditingController(text: item.client);
    final locCtrl = TextEditingController(text: item.location);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Service Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: glassInputDecoration(context, labelText: 'Client Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locCtrl,
              decoration: glassInputDecoration(context, labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true && context.mounted) {
      final updated = item.copyWith(client: nameCtrl.text.trim(), location: locCtrl.text.trim());
      ref.read(quoteProvider.notifier).updateItem(item.uid, updated);
    }
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref, QuoteEntry item) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Service',
      message: 'Remove "${serviceLabel(item.code, item.name)}" from payment items?',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      ref.read(quoteProvider.notifier).removeItem(item.uid);
    }
  }

  Future<void> _editBasis(BuildContext context, WidgetRef ref, QuoteEntry item) async {
    final linesTotal = item.lines.fold<double>(0, (s, l) => s + l.amount);
    final current = item.overriddenTotal ?? linesTotal;
    final ctrl = TextEditingController(text: current.toStringAsFixed(2));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Basis Value'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Computed total: ${peso(linesTotal)}',
              style: TextStyle(fontSize: 13, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ctrl,
              decoration: glassInputDecoration(context, labelText: 'Basis Value', prefixText: '₱'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(-1.0),
            child: const Text('Reset'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              Navigator.of(ctx).pop(val ?? 0.0);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == -1.0) {
      final updated = item.copyWith(overriddenTotal: null);
      ref.read(quoteProvider.notifier).updateItem(item.uid, updated);
    } else if (result != null && result > 0) {
      final updated = item.copyWith(overriddenTotal: result);
      ref.read(quoteProvider.notifier).updateItem(item.uid, updated);
    }
  }

  Future<void> _showInvoiceShare(BuildContext context, QuoteEntry item) async {
    final total = item.lines.fold<double>(0, (sum, line) => sum + line.amount);
    final bytes = await generateQuoteImage([item]);

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Invoice Preview', style: theme.textTheme.titleLarge)),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(serviceLabel(item.code, item.name), style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text('Total: ${peso(total)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(ctx).size.width * 0.82,
                          maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                        ),
                        child: Image.memory(bytes, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await sharePdf([item], fileName: 'invoice_${item.uid}.pdf');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Invoice'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await shareImage(bytes);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Share as Image'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final text = formatQuoteText([item]);
                      await shareText(text);
                    },
                    icon: const Icon(Icons.text_snippet),
                    label: const Text('Share as Text'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentItemCard extends StatefulWidget {
  final QuoteEntry item;
  final List<Installment> installments;
  final List<ExpenseEntry> expenses;
  final List<Appointment> itemAppointments;
  final VoidCallback onAddInstallment;
  final VoidCallback onAddSchedule;
  final void Function(int, Installment) onEditInstallment;
  final void Function(int) onDeleteInstallment;
  final VoidCallback onAddExpense;
  final void Function(int, ExpenseEntry) onEditExpense;
  final void Function(int) onDeleteExpense;
  final VoidCallback onCalculator;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onEditBasis;

  const _PaymentItemCard({
    required this.item,
    required this.installments,
    required this.expenses,
    required this.itemAppointments,
    required this.onAddInstallment,
    required this.onAddSchedule,
    required this.onEditInstallment,
    required this.onDeleteInstallment,
    required this.onAddExpense,
    required this.onEditExpense,
    required this.onDeleteExpense,
    required this.onCalculator,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onEditBasis,
  });

  @override
  State<_PaymentItemCard> createState() => _PaymentItemCardState();
}

class _PaymentItemCardState extends State<_PaymentItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final linesTotal = widget.item.lines.fold<double>(0, (s, l) => s + l.amount);
    final basis = widget.item.overriddenTotal ?? linesTotal;
    final totalPaid = widget.installments.where((i) => i.paid).fold<double>(0, (s, i) => s + i.amount(basis));
    final totalExpenses = widget.expenses.fold<double>(0, (s, e) => s + e.computeAmount(basis, 0));
    final net = basis - totalExpenses;

    final scheduledAppts = widget.itemAppointments..toList()..sort((a, b) => a.date.compareTo(b.date));
    final hasSchedule = scheduledAppts.isNotEmpty;
    final scheduleText = hasSchedule
        ? 'Schedule: ${scheduledAppts.first.date.toLocal().toString().split(' ')[0]}'
        : 'No schedule';

    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onShare,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(serviceLabel(widget.item.code, widget.item.name), style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Total: ${peso(basis)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 24, height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                onPressed: widget.onEditBasis,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Net: ${peso(net)}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        hasSchedule
                            ? Text(scheduleText, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.75)))
                            : InkWell(
                                onTap: widget.onAddSchedule,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brass.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 13, color: AppTheme.brass),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add Schedule',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.brass,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.item.overriddenTotal != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'Tariff: ${peso(linesTotal)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: widget.onCalculator,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.calculate_outlined, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: widget.onEdit,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: widget.onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.delete_outline, size: 18, color: AppTheme.marker),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => setState(() => _isExpanded = !_isExpanded),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: basis > 0 ? (totalPaid / basis).clamp(0, 1) : 0,
                        minHeight: 8,
                        backgroundColor: AppTheme.rule,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brass),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${basis > 0 ? (totalPaid / basis * 100).toStringAsFixed(0) : 0}% paid · ${peso(totalPaid)} of ${peso(basis)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (basis - totalPaid > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Receivable: ${peso(basis - totalPaid)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.marker, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ...widget.installments.asMap().entries.map((entry) => _InstallmentRow(
                      index: entry.key,
                      installment: entry.value,
                      total: basis,
                      onEdit: () => widget.onEditInstallment(entry.key, entry.value),
                      onDelete: () => widget.onDeleteInstallment(entry.key),
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: widget.onAddInstallment,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Payment'),
                      ),
                    ),
                    const Divider(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        children: [
                          Text('Expenses', style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600, color: AppTheme.muted,
                          )),
                          const Spacer(),
                          Text(
                            'Total: ${peso(widget.expenses.fold<double>(0, (s, e) => s + e.computeAmount(basis, 0)))}',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                    ...widget.expenses.asMap().entries.map((entry) => _ExpenseRow(
                      index: entry.key,
                      expense: entry.value,
                      total: basis,
                      onEdit: () => widget.onEditExpense(entry.key, entry.value),
                      onDelete: () => widget.onDeleteExpense(entry.key),
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: widget.onAddExpense,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Expense'),
                      ),
                    ),
                  ],
            ],
          ),
        ),
      ),
    ));
  }
}

class _InstallmentRow extends StatelessWidget {
  final int index;
  final Installment installment;
  final double total;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InstallmentRow({
    required this.index,
    required this.installment,
    required this.total,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = installment.amount(total);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: installment.paid ? AppTheme.brass.withValues(alpha: 0.08) : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.rule),
          ),
          child: Row(
            children: [
              Icon(
                installment.paid ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: installment.paid ? AppTheme.brass : theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(installment.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      installment.isFixed
                          ? '${peso(amount)}${installment.dueDate != null ? ' — due ${installment.dueDate!.toLocal().toString().split(' ')[0]}' : ''}'
                          : '${installment.pct.toStringAsFixed(0)}% — ${peso(amount)}${installment.dueDate != null ? ' — due ${installment.dueDate!.toLocal().toString().split(' ')[0]}' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final int index;
  final ExpenseEntry expense;
  final double total;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseRow({
    required this.index,
    required this.expense,
    required this.total,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = expense.computeAmount(total, 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.rule),
          ),
          child: Row(
            children: [
              const Icon(Icons.money_off, size: 18, color: AppTheme.marker),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      expense.isPercent
                          ? '${expense.value.toStringAsFixed(0)}% — ${peso(amount)}'
                          : '${peso(expense.value)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
