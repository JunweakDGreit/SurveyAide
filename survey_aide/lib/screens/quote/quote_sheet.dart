import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/quote_provider.dart';
import '../../providers/uiprovider.dart';
import '../../services/export_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/toast.dart';

class QuoteSheet extends ConsumerWidget {
  const QuoteSheet({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(bottomSheetOpenProvider.notifier).state = true;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuoteSheet(),
    ).whenComplete(() {
      container.read(bottomSheetOpenProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quoteProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.rule, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Payments', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.rule),
                  const SizedBox(height: 12),
                  Text('No payment items yet', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                ],
              ),
            )
          else
            Flexible(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: _buildGroupedItems(context, ref, items),
                    ),
                  ),
                  _buildFooter(context, ref, items, theme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItems(BuildContext context, WidgetRef ref, List<QuoteEntry> items) {
    final grouped = <String, List<QuoteEntry>>{};
    for (final item in items) {
      final key = item.client;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      final clientItems = entry.value;
      double clientTotal = 0;

      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.ink)),
                  if (clientItems.first.location.isNotEmpty)
                    Text(clientItems.first.location, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                ],
              ),
            ),
          ],
        ),
      ));

      for (int i = 0; i < clientItems.length; i++) {
        final item = clientItems[i];
        final lineTotal = item.lines.fold<double>(0, (s, l) => s + l.amount);
        clientTotal += lineTotal;

        widgets.add(_QuoteItemCard(
          item: item,
          total: lineTotal,
          onRemove: () => ref.read(quoteProvider.notifier).removeItem(item.uid),
        ));
      }

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Spacer(),
            Text('Client Total: ', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
            Text(peso(clientTotal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink)),
          ],
        ),
      ));

      widgets.add(const Divider(height: 1));
    }

    return widgets;
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, List<QuoteEntry> items, ThemeData theme) {
    final grandTotal = items.fold<double>(0, (s, item) => s + item.lines.fold<double>(0, (ss, l) => ss + l.amount));

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Text('Grand Total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(peso(grandTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.marker)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _clearAll(context, ref),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear all'),
                ),
                const Spacer(),
                _exportBtn(Icons.copy, 'Copy', () => _copyAll(items, context)),
                const SizedBox(width: 4),
                _exportBtn(Icons.share, 'Share', () => _shareAll(items)),
                const SizedBox(width: 4),
                _exportBtn(Icons.image, 'Image', () => _imageAll(items, context)),
                const SizedBox(width: 4),
                _exportBtn(Icons.picture_as_pdf, 'PDF', () => _pdfAll(items)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.brass),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear All Payments',
      message: 'Remove all payment items?',
      confirmLabel: 'Clear',
    );
    if (confirmed) {
      ref.read(quoteProvider.notifier).clearAll();
    }
  }

  Future<void> _copyAll(List<QuoteEntry> items, BuildContext context) async {
    final text = formatQuoteText(items);
    await copyToClipboard(text);
    if (context.mounted) showToast(context, 'Copied to clipboard');
  }

  Future<void> _shareAll(List<QuoteEntry> items) async {
    final text = formatQuoteText(items);
    await shareText(text);
  }

  Future<void> _imageAll(List<QuoteEntry> items, BuildContext context) async {
    final bytes = await generateQuoteImage(items);
    await shareImage(bytes);
  }

  Future<void> _pdfAll(List<QuoteEntry> items) async {
    await generatePdf(items);
  }
}

class _QuoteItemCard extends StatefulWidget {
  final QuoteEntry item;
  final double total;
  final VoidCallback onRemove;

  const _QuoteItemCard({
    required this.item,
    required this.total,
    required this.onRemove,
  });

  @override
  State<_QuoteItemCard> createState() => _QuoteItemCardState();
}

class _QuoteItemCardState extends State<_QuoteItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.item.uid),
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
      onDismissed: (_) => widget.onRemove(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(serviceLabel(widget.item.code, widget.item.name), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.ink)),
                        ],
                      ),
                    ),
                    Text(peso(widget.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.ink)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onRemove,
                      child: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
                if (_expanded && widget.item.lines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...widget.item.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(left: 26, top: 2, bottom: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(line.label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))),
                        Text(peso(line.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
