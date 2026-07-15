import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../providers/quote_provider.dart';
import '../../services/export_service.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final QuoteEntry item;
  const InvoicePreviewScreen({super.key, required this.item});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await generateQuoteImage([widget.item]);
    if (mounted) setState(() { _bytes = bytes; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          PopupMenuButton<_ShareAction>(
            onSelected: (action) => _onShare(context, action),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _ShareAction.pdf,
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Share as PDF'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: _ShareAction.image,
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Share as Image'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: _ShareAction.text,
                child: ListTile(
                  leading: Icon(Icons.text_snippet),
                  title: Text('Share as Text'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _bytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _onShare(BuildContext context, _ShareAction action) async {
    switch (action) {
      case _ShareAction.pdf:
        await sharePdf([widget.item], fileName: 'invoice_${widget.item.uid}.pdf');
      case _ShareAction.image:
        if (_bytes != null) await shareImage(_bytes!);
      case _ShareAction.text:
        final text = formatQuoteText([widget.item]);
        await shareText(text);
    }
  }
}

enum _ShareAction { pdf, image, text }
