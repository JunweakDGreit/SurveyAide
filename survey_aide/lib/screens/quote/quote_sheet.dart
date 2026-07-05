import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    container.read(modalCountProvider.notifier).state++;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (_, __, ___) => const QuoteSheet(),
    ).whenComplete(() {
      container.read(bottomSheetOpenProvider.notifier).state = false;
      container.read(modalCountProvider.notifier).state--;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quoteProvider);
    const bwTheme = Color(0xFF1A1A1A);
    const bwMuted = Color(0xFF888888);

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE0E0E0),
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          onSurface: bwTheme,
          primary: bwTheme,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bwTheme),
          bodyLarge: TextStyle(fontSize: 14, color: bwMuted),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          title: const Text('Payments', style: TextStyle(fontWeight: FontWeight.bold, color: bwTheme)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: bwTheme),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: items.isNotEmpty
              ? [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: bwTheme),
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      switch (value) {
                        case 'copy': _copyAll(items, context);
                        case 'share': _shareAll(items);
                        case 'image': _imageAll(items, context);
                        case 'pdf': _pdfAll(items);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'copy', child: _MenuRow(Icons.copy, 'Copy text')),
                      PopupMenuItem(value: 'share', child: _MenuRow(Icons.share, 'Share')),
                      PopupMenuItem(value: 'image', child: _MenuRow(Icons.image, 'Save as image')),
                      PopupMenuItem(value: 'pdf', child: _MenuRow(Icons.picture_as_pdf, 'Save as PDF')),
                    ],
                  ),
                ]
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE0E0E0), height: 1),
          ),
        ),
        body: items.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: bwMuted),
                    SizedBox(height: 12),
                    Text('No payment items yet', style: TextStyle(color: bwMuted)),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: _buildGroupedItems(context, ref, items),
                    ),
                  ),
                  _buildFooter(context, ref, items),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildGroupedItems(BuildContext context, WidgetRef ref, List<QuoteEntry> items) {
    const bwTheme = Color(0xFF1A1A1A);
    const bwMuted = Color(0xFF888888);
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
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: bwTheme)),
                  if (clientItems.first.location.isNotEmpty)
                    Text(clientItems.first.location, style: const TextStyle(fontSize: 12, color: bwMuted)),
                  if (clientItems.first.billingAddress.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(clientItems.first.billingAddress, style: const TextStyle(fontSize: 12, color: bwMuted)),
                    ),
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
            const Text('Client Total: ', style: TextStyle(fontSize: 14, color: bwMuted)),
            Text(peso(clientTotal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: bwTheme)),
          ],
        ),
      ));

      widgets.add(const Divider(height: 1));
    }

    return widgets;
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, List<QuoteEntry> items) {
    final grandTotal = items.fold<double>(0, (s, item) => s + item.lines.fold<double>(0, (ss, l) => ss + l.amount));
    const bwTheme = Color(0xFF1A1A1A);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            TextButton.icon(
              onPressed: () => _clearAll(context, ref),
              icon: const Icon(Icons.delete_outline, size: 18, color: bwTheme),
              label: const Text('Clear all', style: TextStyle(color: bwTheme)),
            ),
            const Spacer(),
            const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, color: bwTheme)),
            const SizedBox(width: 8),
            Text(peso(grandTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bwTheme)),
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
    const bwTheme = Color(0xFF1A1A1A);
    const bwMuted = Color(0xFF888888);
    return Dismissible(
      key: ValueKey(widget.item.uid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => widget.onRemove(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
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
                      size: 18, color: bwMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(serviceLabel(widget.item.code, widget.item.name), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: bwTheme)),
                        ],
                      ),
                    ),
                    Text(peso(widget.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: bwTheme)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onRemove,
                      child: const Icon(Icons.close, size: 18, color: bwMuted),
                    ),
                  ],
                ),
                if (_expanded && widget.item.lines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...widget.item.lines.map((line) => Padding(
                    padding: const EdgeInsets.only(left: 26, top: 2, bottom: 2),
                    child: _DotBridgeRow(
                      label: line.label,
                      value: peso(line.amount),
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

class _DotBridgeRow extends StatelessWidget {
  final String label;
  final String value;
  const _DotBridgeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A))),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dotWidth = 5.0;
              final count = (constraints.maxWidth / dotWidth).floor();
              return Text(
                '.' * (count > 1 ? count : 1),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              );
            },
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
      ],
    );
  }
}
