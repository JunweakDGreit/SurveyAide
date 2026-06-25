import 'package:intl/intl.dart';

String displayCode(String code) => code.split('.').last;

String serviceLabel(String code, String name) => name;

String serviceDisplayName(String name, String group) {
  // Remove the group prefix when the service name already includes it.
  // Handles both hyphen '-' and en‑dash '—' (U+2014) with surrounding spaces.
  final separators = [' - ', ' — ', ' – ', ' – ', ' – ', ' – ']; // common dash variants with spaces
  if (group.isNotEmpty) {
    for (final sep in separators) {
      final prefix = '$group$sep';
      if (name.startsWith(prefix)) {
        return name.substring(prefix.length);
      }
    }
  }
  return name;
}

String peso(double amount) {
  final dec = amount == amount.roundToDouble() ? 0 : 2;
  final format = NumberFormat.currency(locale: 'en_PH', symbol: '\u20B1', decimalDigits: dec);
  return format.format(amount);
}

String fmtArea(double hectares) {
  if (hectares >= 10000) return '${(hectares / 10000).toStringAsFixed(2)}k ha';
  return '${hectares.toStringAsFixed(4)} ha';
}

String escHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

String iconName(String name) {
  return 'assets/icons/$name.svg';
}
