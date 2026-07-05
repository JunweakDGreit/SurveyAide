import 'dart:async';
import 'package:flutter/material.dart';
import '../core/helpers.dart';
import '../providers/quote_provider.dart';
import '../services/export_service.dart';
import 'press_scale.dart';
import 'toast.dart';

class PostAddPanel extends StatefulWidget {
  final QuoteEntry item;
  final VoidCallback onViewPayment;
  final VoidCallback onDismiss;

  const PostAddPanel({
    super.key,
    required this.item,
    required this.onViewPayment,
    required this.onDismiss,
  });

  @override
  State<PostAddPanel> createState() => _PostAddPanelState();
}

class _PostAddPanelState extends State<PostAddPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
    _dismissTimer = Timer(const Duration(seconds: 8), widget.onDismiss);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _exportCopy() async {
    final text = formatQuoteText([widget.item]);
    await copyToClipboard(text);
    if (context.mounted) showToast(context, 'Copied to clipboard');
  }

  void _exportShare() async {
    final text = formatQuoteText([widget.item]);
    await shareText(text);
  }

  void _exportImage() async {
    final bytes = await generateQuoteImage([widget.item]);
    await shareImage(bytes);
  }

  void _exportPdf() async {
    await generatePdf([widget.item]);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.item.lines.fold<double>(0, (s, l) => s + l.amount);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: SlideTransition(
        position: _slideAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Added to Payments', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF2E7D32))),
                          const SizedBox(height: 2),
                          Text(serviceLabel(widget.item.code, widget.item.name), style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Text(peso(total), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _iconBtn(Icons.copy, 'Copy', _exportCopy),
                    _iconBtn(Icons.share, 'Share', _exportShare),
                    _iconBtn(Icons.image, 'Image', _exportImage),
                    _iconBtn(Icons.picture_as_pdf, 'PDF', _exportPdf),
                    _iconBtn(Icons.receipt_long, 'View', widget.onViewPayment),
                  ],
                ),
              ],
          ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String label, VoidCallback onTap) {
    return PressScale(
      scale: 0.90,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }
}
