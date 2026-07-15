import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../core/helpers.dart';
import '../providers/quote_provider.dart';
import '../providers/business_provider.dart';
import '../providers/invoice_settings_provider.dart';

String _invNum() {
  final now = DateTime.now();
  return 'INV-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(6)}';
}

String _invDate() {
  final now = DateTime.now();
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}

String _dueDate() {
  final due = DateTime.now().add(const Duration(days: 30));
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[due.month - 1]} ${due.day}, ${due.year}';
}

String formatQuoteText(List<QuoteEntry> items, {InvoiceSettings? settings}) {
  if (items.isEmpty) return 'No items.';
  final s = settings ?? InvoiceSettings.fromStorage();

  final grouped = <String, List<QuoteEntry>>{};
  for (final item in items) {
    final key = item.client;
    grouped.putIfAbsent(key, () => []).add(item);
  }

  final buf = StringBuffer();
  buf.writeln('INVOICE');
  if (s.showInvoiceNumber) buf.writeln('Invoice #: ${_invNum()}');
  buf.writeln('Date: ${_invDate()}');
  if (s.showDueDate) buf.writeln('Due: $_dueDate');
  buf.writeln();

  final biz = BusinessInfo.fromStorage();
  if (s.showCompanyInfo && biz.company.isNotEmpty) {
    buf.writeln(biz.company);
    if (biz.address.isNotEmpty) buf.writeln(biz.address);
    if (biz.phone.isNotEmpty) buf.writeln('Phone: ${biz.phone}');
    if (biz.email.isNotEmpty) buf.writeln('Email: ${biz.email}');
    if (biz.tin.isNotEmpty) buf.writeln('TIN: ${biz.tin}');
    buf.writeln();
  }

  for (final entry in grouped.entries) {
    buf.writeln('Bill To:');
    buf.writeln(entry.key);
    if (entry.value.first.location.isNotEmpty) {
      buf.writeln(entry.value.first.location);
    }
    if (s.showBillingAddress && entry.value.first.billingAddress.isNotEmpty) {
      buf.writeln(entry.value.first.billingAddress);
    }
    buf.writeln();
    double clientTotal = 0;
    for (final item in entry.value) {
      buf.writeln(serviceLabel(item.code, item.name));
      for (final line in item.lines) {
        buf.writeln('  ${line.label}: ${peso(line.amount)}');
      }
      final lineTotals = item.lines.fold<double>(0, (s, l) => s + l.amount);
      buf.writeln('  ${'=' * 20}');
      buf.writeln('  Subtotal: ${peso(lineTotals)}');
      buf.writeln();
      clientTotal += lineTotals;
    }
    buf.writeln('Client Total: ${peso(clientTotal)}');
    buf.writeln();
  }

  final grandTotal = items.fold<double>(0, (s, item) => s + item.lines.fold<double>(0, (ss, l) => ss + l.amount));

  if (s.showVatBreakdown) {
    final vat = grandTotal * 0.12 / 1.12;
    final sub = grandTotal - vat;
    buf.writeln('=' * 40);
    buf.writeln('Subtotal: ${peso(sub)}');
    buf.writeln('VAT (12%): ${peso(vat)}');
    buf.writeln('GRAND TOTAL: ${peso(grandTotal)}');
  } else {
    buf.writeln('=' * 40);
    buf.writeln('GRAND TOTAL: ${peso(grandTotal)}');
  }
  buf.writeln();

  if (s.showPaymentTerms) buf.writeln('Payment Terms: Due by $_dueDate');
  if (s.showThankYouNote && s.thankYouNote.isNotEmpty) buf.writeln(s.thankYouNote);
  if (s.showFooter && s.footerText.isNotEmpty) buf.writeln(s.footerText);

  return buf.toString();
}

Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}

Future<void> shareText(String text) async {
  await SharePlus.instance.share(ShareParams(text: text));
}

const _invoiceW = 600.0;
const _invoiceMargin = 24.0;
const _invoiceLineH = 22.0;

Future<Uint8List> generateQuoteImage(List<QuoteEntry> items, {BusinessInfo? businessInfo, InvoiceSettings? settings}) async {
  final s = settings ?? InvoiceSettings.fromStorage();
  final biz = businessInfo ?? BusinessInfo.fromStorage();
  final grouped = <String, List<QuoteEntry>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.client, () => []).add(item);
  }

  final rows = <String, String>{};
  double grandTotal = 0;

  final invNum = _invNum();
  final invDate = _invDate();
  final dueDate = _dueDate();

  for (final entry in grouped.entries) {
    rows['bill_title_${entry.key}'] = 'BILL TO';
    rows['bill_name_${entry.key}'] = entry.key;
    if (entry.value.first.location.isNotEmpty) {
      rows['bill_loc_${entry.key}'] = entry.value.first.location;
    }
    if (s.showBillingAddress && entry.value.first.billingAddress.isNotEmpty) {
      rows['bill_addr_${entry.key}'] = entry.value.first.billingAddress;
    }
    rows['sp_${entry.key}_1'] = '';

    double clientTotal = 0;
    for (final item in entry.value) {
      rows['svc_${item.uid}'] = serviceLabel(item.code, item.name);
      for (final l in item.lines) {
        rows['line_${item.uid}_${l.label}'] = l.label;
      }
      final st = item.lines.fold<double>(0, (s, l) => s + l.amount);
      rows['amt_${item.uid}'] = peso(st);
      rows['sp_${item.uid}_2'] = '';
      clientTotal += st;
    }
    rows['client_tot_${entry.key}'] = peso(clientTotal);
    rows['sp_${entry.key}_3'] = '';
    grandTotal += clientTotal;
  }

  if (s.showVatBreakdown) {
    final vat = grandTotal * 0.12 / 1.12;
    final sub = grandTotal - vat;
    rows['subtotal'] = 'Subtotal';
    rows['subtot_amt'] = peso(sub);
    rows['vat'] = 'VAT (12%)';
    rows['vat_amt'] = peso(vat);
  }
  rows['grand'] = 'TOTAL';
  rows['grand_amt'] = peso(grandTotal);

  // Calculate height
  const headerH = 80.0;
  const footerH = 36.0;

  // Company info lines
  int bizLines = 0;
  if (s.showCompanyInfo) {
    if (biz.company.isNotEmpty) bizLines++;
    if (biz.address.isNotEmpty) bizLines++;
    if (biz.phone.isNotEmpty || biz.email.isNotEmpty) bizLines++;
    if (biz.tin.isNotEmpty) bizLines++;
  }
  final bizSectionH = 12.0 + bizLines * 16.0;

  // Inv info lines
  final invInfoH = 20.0
    + (s.showInvoiceNumber ? 16.0 : 0)
    + 16.0 // date always shown
    + (s.showDueDate ? 16.0 : 0);

  int totalBodyLines = 0;
  for (final key in rows.keys) {
    if (key.startsWith('sp')) continue;
    if (key == 'subtotal' || key == 'subtot_amt' || key == 'vat' || key == 'vat_amt') {
      totalBodyLines++;
      continue;
    }
    if (key == 'grand' || key == 'grand_amt') {
      totalBodyLines++;
      continue;
    }
    if (key.startsWith('client_tot_')) {
      totalBodyLines++;
      continue;
    }
    if (key.startsWith('svc_') || key.startsWith('line_') || key.startsWith('amt_')) {
      totalBodyLines++;
      continue;
    }
    if (key.startsWith('bill_')) {
      totalBodyLines++;
      continue;
    }
    totalBodyLines++;
  }

  final bodyH = totalBodyLines * _invoiceLineH;
  final notesH = (s.showPaymentTerms ? 16.0 : 0) + (s.showThankYouNote ? 16.0 : 0) + 8;
  final totalHeight = headerH + bizSectionH + invInfoH + _invoiceMargin + bodyH + notesH + (s.showFooter ? footerH : 0) + _invoiceMargin * 2 + 24;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _invoiceW, totalHeight));

  const bg = Color(0xFFFFFFFF);
  const darkGray = Color(0xFF333333);
  const muted = Color(0xFF888888);
  const rule = Color(0xFFE0E0E0);
  const lightBg = Color(0xFFF5F5F5);
  const accentColor = Color(0xFFE8A06B);

  canvas.drawRect(Rect.fromLTWH(0, 0, _invoiceW, totalHeight), Paint()..color = bg);

  // Header
  drawText(canvas, 'INVOICE', _invoiceMargin, 22, size: 26, color: darkGray, weight: FontWeight.bold);
  drawText(canvas, 'SURVEY AIDE', _invoiceMargin, 50, size: 10, color: muted);
  // Accent divider
  canvas.drawRect(Rect.fromLTWH(_invoiceMargin, headerH - 2, _invoiceW - 2 * _invoiceMargin, 2), Paint()..color = accentColor);

  double y = headerH + 12;

  // Company info
  if (s.showCompanyInfo) {
    if (biz.company.isNotEmpty) {
      drawText(canvas, biz.company.toUpperCase(), _invoiceMargin, y, size: 12, color: darkGray, weight: FontWeight.bold);
      y += 16;
    }
    if (biz.address.isNotEmpty) {
      drawText(canvas, biz.address, _invoiceMargin, y, size: 11, color: muted);
      y += 16;
    }
    if (biz.phone.isNotEmpty || biz.email.isNotEmpty) {
      drawText(canvas, [biz.phone, biz.email].where((e) => e.isNotEmpty).join('  |  '), _invoiceMargin, y, size: 11, color: muted);
      y += 16;
    }
    if (biz.tin.isNotEmpty) {
      drawText(canvas, 'TIN: ${biz.tin}', _invoiceMargin, y, size: 11, color: muted);
      y += 16;
    }
    if (biz.company.isNotEmpty) y += 4;
  }

  // Invoice info
  const infoX = _invoiceW - _invoiceMargin;
  if (s.showInvoiceNumber) {
    drawTextRight(canvas, '#$invNum', infoX, y, size: 13, color: darkGray, weight: FontWeight.bold);
    y += 16;
  }
  drawTextRight(canvas, 'Date: $invDate', infoX, y, size: 11, color: muted);
  y += 16;
  if (s.showDueDate) {
    drawTextRight(canvas, 'Due: $dueDate', infoX, y, size: 11, color: muted);
    y += 16;
  }
  y += 8;

  // Divider
  canvas.drawLine(Offset(_invoiceMargin, y), Offset(_invoiceW - _invoiceMargin, y), Paint()..color = rule..strokeWidth = 1);
  y += 12;

  double bodyY = y;
  for (final key in rows.keys) {
    if (key.startsWith('sp')) continue;

    final val = rows[key]!;

    if (key.startsWith('bill_title_')) {
      drawText(canvas, val, _invoiceMargin, bodyY, size: 10, color: muted, weight: FontWeight.bold);
      bodyY += _invoiceLineH;
      continue;
    }
    if (key.startsWith('bill_name_')) {
      drawText(canvas, val, _invoiceMargin, bodyY, size: 14, color: darkGray, weight: FontWeight.bold);
      bodyY += _invoiceLineH;
      continue;
    }
    if (key.startsWith('bill_loc_') || key.startsWith('bill_addr_')) {
      if (key.startsWith('bill_addr_') && !s.showBillingAddress) { continue; }
      drawText(canvas, val, _invoiceMargin, bodyY, size: 11, color: darkGray);
      bodyY += _invoiceLineH;
      continue;
    }

    if (key.startsWith('svc_')) {
      drawText(canvas, val, _invoiceMargin, bodyY, size: 12, color: darkGray, weight: FontWeight.bold);
      bodyY += _invoiceLineH;
      continue;
    }
    if (key.startsWith('line_')) {
      drawText(canvas, val, _invoiceMargin + 16, bodyY, size: 11, color: darkGray);
      bodyY += _invoiceLineH;
      continue;
    }
    if (key.startsWith('amt_')) {
      drawTextRight(canvas, val, infoX, bodyY - _invoiceLineH, size: 11, color: darkGray, weight: FontWeight.w600);
      continue;
    }

    if (key.startsWith('client_tot_')) {
      canvas.drawRect(Rect.fromLTWH(_invoiceMargin, bodyY - 2, _invoiceW - 2 * _invoiceMargin, _invoiceLineH + 4), Paint()..color = lightBg);
      drawText(canvas, 'Subtotal', _invoiceMargin, bodyY, size: 11, color: darkGray, weight: FontWeight.bold);
      drawTextRight(canvas, val, infoX, bodyY, size: 11, color: darkGray, weight: FontWeight.bold);
      bodyY += _invoiceLineH + 4;
      canvas.drawLine(Offset(_invoiceMargin, bodyY), Offset(_invoiceW - _invoiceMargin, bodyY), Paint()..color = rule..strokeWidth = 0.5);
      bodyY += 8;
      continue;
    }

    if (key == 'subtotal' || key == 'vat') {
      drawText(canvas, val, _invoiceMargin, bodyY, size: 12, color: darkGray);
      bodyY += _invoiceLineH;
      continue;
    }
    if (key == 'subtot_amt' || key == 'vat_amt') {
      drawTextRight(canvas, val, infoX, bodyY - _invoiceLineH, size: 12, color: darkGray);
      continue;
    }
    if (key == 'grand') {
      // Top border
      canvas.drawLine(Offset(_invoiceMargin, bodyY - 4), Offset(_invoiceW - _invoiceMargin, bodyY - 4), Paint()..color = accentColor..strokeWidth = 1.5);
      canvas.drawRect(Rect.fromLTWH(_invoiceMargin, bodyY - 2, _invoiceW - 2 * _invoiceMargin, _invoiceLineH + 8), Paint()..color = lightBg);
      drawText(canvas, val, _invoiceMargin, bodyY, size: 16, color: darkGray, weight: FontWeight.bold);
      bodyY += _invoiceLineH + 8;
      // Bottom border
      canvas.drawLine(Offset(_invoiceMargin, bodyY), Offset(_invoiceW - _invoiceMargin, bodyY), Paint()..color = accentColor..strokeWidth = 1.5);
      continue;
    }
    if (key == 'grand_amt') {
      drawTextRight(canvas, val, infoX, bodyY - (_invoiceLineH + 8), size: 16, color: darkGray, weight: FontWeight.bold);
      continue;
    }

    drawText(canvas, val, _invoiceMargin, bodyY, size: 12, color: darkGray);
    bodyY += _invoiceLineH;
  }

  // Notes
  bodyY += 8;
  if (s.showPaymentTerms) {
    drawText(canvas, 'Payment Terms: Due by $dueDate', _invoiceMargin, bodyY, size: 10, color: muted);
    bodyY += 16;
  }
  if (s.showThankYouNote && s.thankYouNote.isNotEmpty) {
    drawText(canvas, s.thankYouNote, _invoiceMargin, bodyY, size: 11, color: darkGray);
    bodyY += 16;
  }

  // Footer
  if (s.showFooter && s.footerText.isNotEmpty) {
    canvas.drawLine(Offset(_invoiceMargin, totalHeight - footerH), Offset(_invoiceW - _invoiceMargin, totalHeight - footerH), Paint()..color = rule..strokeWidth = 0.5);
    drawText(canvas, s.footerText, _invoiceMargin, totalHeight - footerH + 11, size: 10, color: muted);
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(_invoiceW.toInt(), totalHeight.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void drawText(ui.Canvas canvas, String txt, double x, double y, {
  double size = 14, Color color = const Color(0xFF000000), ui.FontWeight? weight,
}) {
  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: ui.TextAlign.left, fontSize: size, fontWeight: weight),
  )
    ..pushStyle(ui.TextStyle(color: color, fontSize: size, fontWeight: weight))
    ..addText(txt);
  final layout = pb.build()..layout(const ui.ParagraphConstraints(width: _invoiceW - 2 * _invoiceMargin));
  canvas.drawParagraph(layout, Offset(x, y));
}

void drawTextRight(ui.Canvas canvas, String txt, double rightX, double y, {
  double size = 14, Color color = const Color(0xFF000000), ui.FontWeight? weight,
}) {
  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: ui.TextAlign.right, fontSize: size, fontWeight: weight),
  )
    ..pushStyle(ui.TextStyle(color: color, fontSize: size, fontWeight: weight))
    ..addText(txt);
  final layout = pb.build()..layout(const ui.ParagraphConstraints(width: _invoiceW - _invoiceMargin - _invoiceMargin));
  canvas.drawParagraph(layout, Offset(rightX - layout.width, y));
}

Future<void> shareImage(Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/quote_receipt.png');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}

Future<void> sharePdf(List<QuoteEntry> items, {String fileName = 'invoice.pdf'}) async {
  final bytes = await generatePdfBytes(items);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}

Future<Uint8List> generatePdfBytes(List<QuoteEntry> items, {InvoiceSettings? settings}) async {
  final s = settings ?? InvoiceSettings.fromStorage();
  final biz = BusinessInfo.fromStorage();
  final grouped = <String, List<QuoteEntry>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.client, () => []).add(item);
  }

  final invNum = _invNum();
  final invDate = _invDate();
  final dueDate = _dueDate();

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INVOICE',
                    style: const pw.TextStyle(color: PdfColor.fromInt(0xFF333333), fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('SURVEY AIDE',
                    style: const pw.TextStyle(color: PdfColor.fromInt(0xFF888888), fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (s.showInvoiceNumber)
                    pw.Text('#$invNum',
                      style: const pw.TextStyle(color: PdfColor.fromInt(0xFF333333), fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: $invDate',
                    style: const pw.TextStyle(color: PdfColor.fromInt(0xFF888888), fontSize: 10)),
                  if (s.showDueDate)
                    pw.Text('Due: $dueDate',
                      style: const pw.TextStyle(color: PdfColor.fromInt(0xFF888888), fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: const PdfColor.fromInt(0xFFE8A06B), thickness: 2),
        ],
      ),
      footer: s.showFooter && s.footerText.isNotEmpty
          ? (context) => pw.Container(
              padding: const pw.EdgeInsets.only(top: 4),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5)),
              ),
              child: pw.Text(s.footerText,
                style: const pw.TextStyle(color: PdfColor.fromInt(0xFF666666), fontSize: 10)),
            )
          : null,
      build: (context) {
        final content = <pw.Widget>[];

        // Company info
        if (s.showCompanyInfo) {
          if (biz.company.isNotEmpty) {
            content.add(pw.Text(biz.company.toUpperCase(),
              style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)));
          }
          if (biz.address.isNotEmpty) {
            content.add(pw.Text(biz.address,
              style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666))));
          }
          if (biz.phone.isNotEmpty || biz.email.isNotEmpty) {
            content.add(pw.Text(
              [biz.phone, biz.email].where((s) => s.isNotEmpty).join('  |  '),
              style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666)),
            ));
          }
          if (biz.tin.isNotEmpty) {
            content.add(pw.Text('TIN: ${biz.tin}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666))));
          }
          if (biz.company.isNotEmpty) {
            content.add(pw.SizedBox(height: 8));
            content.add(pw.Divider());
          }
        }

        double grandTotal = 0;

        for (final entry in grouped.entries) {
          content.add(pw.SizedBox(height: 16));
          content.add(pw.Text('BILL TO',
            style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF888888), fontWeight: pw.FontWeight.bold)));
          content.add(pw.Text(entry.key,
            style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
          if (entry.value.first.location.isNotEmpty) {
            content.add(pw.Text(entry.value.first.location,
              style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666))));
          }
          if (s.showBillingAddress && entry.value.first.billingAddress.isNotEmpty) {
            content.add(pw.Text(entry.value.first.billingAddress,
              style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF666666))));
          }
          content.add(pw.SizedBox(height: 8));
          content.add(pw.Divider());

          double clientTotal = 0;
          final rows = <pw.TableRow>[];

          for (final item in entry.value) {
            rows.add(pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
                  child: pw.Text(serviceLabel(item.code, item.name),
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
                  child: pw.Text(''),
                ),
              ],
            ));
            for (final line in item.lines) {
              rows.add(pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20, top: 2, bottom: 2),
                    child: pw.Text(line.label, style: const pw.TextStyle(fontSize: 11)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(peso(line.amount), textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 11)),
                  ),
                ],
              ));
            }
            final st = item.lines.fold<double>(0, (s, l) => s + l.amount);
            rows.add(pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20, top: 4, bottom: 4),
                  child: pw.Text(''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(peso(st), textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ),
              ],
            ));
            clientTotal += st;
          }

          content.add(pw.Table(
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
            children: rows,
          ));

          content.add(pw.SizedBox(height: 8));
          content.add(pw.Container(
            color: const PdfColor.fromInt(0xFFF5F5F5),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal',
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(peso(clientTotal),
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ));
          grandTotal += clientTotal;
        }

        // Totals
        content.add(pw.SizedBox(height: 16));
        content.add(pw.Divider(thickness: 0.5));
        content.add(pw.SizedBox(height: 8));

        if (s.showVatBreakdown) {
          final vat = grandTotal * 0.12 / 1.12;
          final sub = grandTotal - vat;
          content.add(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF666666))),
              pw.Text(peso(sub), style: const pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF666666))),
            ],
          ));
          content.add(pw.SizedBox(height: 4));
          content.add(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('VAT (12%)', style: const pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF666666))),
              pw.Text(peso(vat), style: const pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF666666))),
            ],
          ));
          content.add(pw.SizedBox(height: 8));
        }

        content.add(pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColor.fromInt(0xFFE8A06B), width: 1.5),
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE8A06B), width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL',
                style: const pw.TextStyle(color: PdfColor.fromInt(0xFF333333), fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(peso(grandTotal),
                style: const pw.TextStyle(color: PdfColor.fromInt(0xFF333333), fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ));

        if (s.showPaymentTerms) {
          content.add(pw.SizedBox(height: 12));
          content.add(pw.Text('Payment Terms: Due by $dueDate',
            style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF888888))));
        }
        if (s.showThankYouNote && s.thankYouNote.isNotEmpty) {
          content.add(pw.SizedBox(height: 4));
          content.add(pw.Text(s.thankYouNote,
            style: const pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF333333))));
        }

        return content;
      },
    ),
  );

  return pdf.save();
}

Future<void> generatePdf(List<QuoteEntry> items) async {
  final bytes = await generatePdfBytes(items);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/quote_receipt.pdf');
  await file.writeAsBytes(bytes);
  await Printing.layoutPdf(onLayout: (_) => bytes);
}

Future<void> printPdf(List<QuoteEntry> items) async {
  final bytes = await generatePdfBytes(items);
  await Printing.layoutPdf(onLayout: (_) => bytes);
}
