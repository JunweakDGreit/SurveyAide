import 'package:flutter/material.dart';
import '../core/constants.dart';

void showToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 5),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
      duration: duration,
      backgroundColor: AppTheme.marker,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    ),
  );
  Future.delayed(duration, () => messenger.hideCurrentSnackBar());
}
