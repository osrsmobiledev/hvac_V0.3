import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';

/// Top header for the email delivery tracker card in Historiek.
class EmailTrackerHeader extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onClose;

  const EmailTrackerHeader({
    super.key,
    required this.isProcessing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              EmailDeliveryDictionary.trackerDialogTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        if (isProcessing)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: EmailDeliveryDictionary.actionClose,
            onPressed: onClose,
          ),
      ],
    );
  }
}
