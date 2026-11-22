import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import 'email_recovery_dialogs.dart';
import 'email_status_badge.dart';

/// Bento-styled tile rendering a single email job's delivery status and recovery controls.
class EmailJobTile extends StatelessWidget {
  final Map<String, Object?> job;
  final bool isProcessing;
  final ValueChanged<String> onCorrectEmail;
  final VoidCallback onRetry;
  final ValueChanged<String> onResolveManually;

  const EmailJobTile({
    super.key,
    required this.job,
    required this.isProcessing,
    required this.onCorrectEmail,
    required this.onRetry,
    required this.onResolveManually,
  });

  static String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$min';
    } catch (_) {
      return ts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = job['status'] as String? ?? 'queued';
    final recipientType = job['recipient_type'] as String?;
    final recipientEmail = job['recipient_email'] as String? ?? '';
    final originalEmail = job['original_recipient_email'] as String?;
    final lastError = job['last_error'] as String?;
    final sentAt = job['sent_at'] as String?;
    final resolutionNotes = job['resolution_notes'] as String?;
    final isCustomer = recipientType == 'customer';
    final typeLabel = isCustomer
        ? EmailDeliveryDictionary.recipientCustomerLabel
        : EmailDeliveryDictionary.recipientTechnicianLabel;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCustomer ? Icons.person_outline : Icons.badge_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              EmailStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipientEmail,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (status == 'sent' && sentAt != null && sentAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${EmailDeliveryDictionary.labelSentAt} ${_formatTimestamp(sentAt)}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (originalEmail != null && originalEmail != recipientEmail)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${EmailDeliveryDictionary.labelOriginalEmail} $originalEmail',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          if (status == 'resolved_manually' &&
              resolutionNotes != null &&
              resolutionNotes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${EmailDeliveryDictionary.labelResolutionNotes} $resolutionNotes',
                style: const TextStyle(fontSize: 11, color: Colors.teal),
              ),
            ),
          if (lastError != null && lastError.isNotEmpty && status != 'sent')
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${EmailDeliveryDictionary.labelLastError} $lastError',
                  style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                ),
              ),
            ),
          if (status == 'recipient_rejected')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonalIcon(
                onPressed: isProcessing
                    ? null
                    : () async {
                        final email =
                            await EmailRecoveryDialogs.showAddressCorrection(
                          context,
                          currentEmail: recipientEmail,
                        );
                        if (email != null) onCorrectEmail(email);
                      },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text(EmailDeliveryDictionary.actionCorrectEmail),
              ),
            ),
          if (status == 'uncertain_timeout')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final ok = await EmailRecoveryDialogs
                                .showUncertainRetryConfirmation(context);
                            if (ok) onRetry();
                          },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(EmailDeliveryDictionary.actionRetry),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final notes =
                                await EmailRecoveryDialogs.showManualResolution(
                                    context);
                            if (notes != null) onResolveManually(notes);
                          },
                    child: const Text(
                        EmailDeliveryDictionary.actionResolveManually),
                  ),
                ],
              ),
            ),
          if (status == 'server_rejected' || status == 'failed')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonalIcon(
                onPressed: isProcessing ? null : onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(EmailDeliveryDictionary.actionRetry),
              ),
            ),
        ],
      ),
    );
  }
}
