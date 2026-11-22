import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';

/// Pure layout widget for visits in Historiek without queued email delivery jobs.
class EmailEmptyOutboxView extends StatelessWidget {
  final String? pdfPath;
  final bool isProcessing;
  final VoidCallback onSharePdf;
  final VoidCallback onAddEmail;
  final VoidCallback onClose;

  const EmailEmptyOutboxView({
    super.key,
    required this.pdfPath,
    required this.isProcessing,
    required this.onSharePdf,
    required this.onAddEmail,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPdf = pdfPath != null && pdfPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      EmailDeliveryDictionary.trackerDialogTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      EmailDeliveryDictionary.trackerNoJobs,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: EmailDeliveryDictionary.actionClose,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            EmailDeliveryDictionary.trackerEmptyExplanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: isProcessing ? null : onAddEmail,
            icon: const Icon(Icons.alternate_email, size: 16),
            label: const Text(EmailDeliveryDictionary.actionSendEmailLater),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: (isProcessing || !hasPdf) ? null : onSharePdf,
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text(EmailDeliveryDictionary.actionSharePdf),
          ),
        ],
      ),
    );
  }
}
