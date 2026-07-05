import 'package:flutter/material.dart';

class AppTheme {
  static const Color brass = Color(0xFFE8A06B);
  static const Color accent = Color(0xFFC4813B);
  static const Color marker = Color(0xFFC84A1E);
  static const Color ink = Color(0xFF1A1E1D);
  static const Color steel = Color(0xFF6D6355);
  static const Color page = Color(0xFFF2EFE6);
  static const Color white = Color(0xFFFBF9F2);
  static const Color rule = Color(0xFFE0DACB);
  static const Color muted = Color(0xFF6D6355);
}

class ServiceCategory {
  final String key;
  final String label;
  final Color color;
  final String iconName;
  const ServiceCategory({
    required this.key,
    required this.label,
    required this.color,
    this.iconName = '',
  });
}

class ServiceFieldOption {
  final String value;
  final String label;
  const ServiceFieldOption({required this.value, required this.label});
}

class ServiceField {
  final String key;
  final String label;
  final String type;
  final double step;
  final double min;
  final double def;
  final List<ServiceFieldOption> options;
  const ServiceField({
    required this.key,
    required this.label,
    this.type = 'number',
    this.step = 0.0001,
    this.min = 0,
    this.def = 0,
    this.options = const [],
  });
}

class TallyLine {
  final String label;
  final double amount;
  const TallyLine({required this.label, required this.amount});
}

class Service {
  final String code;
  final String name;
  final String cat;
  final String group;
  final String? note;
  final String? shortDescription;
  final List<ServiceField> fields;
  final Map<String, double> rates;
  final Map<String, String> labels;
  const Service({
    required this.code,
    required this.name,
    required this.cat,
    this.group = '',
    this.note,
    this.shortDescription,
    required this.fields,
    required this.rates,
    this.labels = const {},
  });
}

BoxDecoration glassDecoration({
  double opacity = 0.25,
  double radius = 12,
  Color? background,
  bool dark = false,
}) {
  final bg = background ?? (dark ? const Color(0xFF2A2A2A) : const Color(0xFFFBF9F2));
  return BoxDecoration(
    color: bg.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
  );
}

InputDecoration glassInputDecoration(BuildContext context, {
  String? labelText,
  String? hintText,
  String? prefixText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? suffixText,
  bool isDense = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? const Color(0xFF2A2A2A) : cs.surface;
  return InputDecoration(
    filled: true,
    fillColor: bg.withValues(alpha: isDark ? 0.35 : 0.40),
    isDense: isDense,
    contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelText: labelText,
    hintText: hintText,
    prefixText: prefixText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixText: suffixText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.error, width: 1.5),
    ),
  );
}

Widget glassBackdrop(BuildContext context, {required Widget child, double radius = 0, Color? background, double? opacity}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    decoration: glassDecoration(
      opacity: opacity ?? (isDark ? 0.15 : 0.18),
      radius: radius,
      dark: isDark,
      background: background,
    ),
    child: child,
  );
}

