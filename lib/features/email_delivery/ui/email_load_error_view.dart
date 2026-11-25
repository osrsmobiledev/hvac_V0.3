import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/localization/email_failure_dictionary.dart';
import 'email_tracker_header.dart';

/// Error state view for [EmailDeliveryCard] when loading outbox state fails.
class EmailLoadErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const EmailLoadErrorView({
    super.key,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailTrackerHeader(isProcessing: false, onClose: onClose),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  EmailFailureDictionary.trackerLoadError,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text(EmailDeliveryDictionary.actionRetry),
          ),
        ],
      ),
    );
  }
}
