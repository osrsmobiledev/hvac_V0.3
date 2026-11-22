import 'package:flutter/material.dart';

/// Reusable non-dismissible confirmation dialog for visit finalization recovery flows.
abstract final class FinalizationConfirmDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    required String cancelLabel,
    required String confirmLabel,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      );
}
