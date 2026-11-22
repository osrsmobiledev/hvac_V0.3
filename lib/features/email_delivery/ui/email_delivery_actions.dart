import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import 'email_outbox_banner.dart';

/// Bottom action buttons and informative banner for [EmailDeliveryCard].
class EmailDeliveryActions extends StatelessWidget {
  final bool hasQueuedJobs;
  final bool isProcessing;
  final bool isConfigured;
  final bool needsAttention;
  final bool isOffline;
  final String? firstPdfPath;
  final VoidCallback? onSendNow;
  final VoidCallback? onSharePdf;
  final VoidCallback onClose;

  const EmailDeliveryActions({
    super.key,
    required this.hasQueuedJobs,
    required this.isProcessing,
    required this.isConfigured,
    required this.needsAttention,
    required this.isOffline,
    required this.firstPdfPath,
    required this.onSendNow,
    required this.onSharePdf,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasQueuedJobs) ...[
          EmailOutboxBanner(
            isConfigured: isConfigured,
            needsAttention: needsAttention,
            isOffline: isOffline,
          ),
          FilledButton.icon(
            onPressed: (isProcessing || !isConfigured || needsAttention)
                ? null
                : onSendNow,
            icon: const Icon(Icons.send, size: 16),
            label: const Text(EmailDeliveryDictionary.actionSendNow),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text(EmailDeliveryDictionary.actionSharePdf),
                onPressed:
                    (isProcessing || firstPdfPath == null) ? null : onSharePdf,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onClose,
              child: const Text(EmailDeliveryDictionary.actionClose),
            ),
          ],
        ),
      ],
    );
  }
}
