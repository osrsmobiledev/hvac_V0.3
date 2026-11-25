import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../core/widgets/tactical_dialog_button.dart';

/// Action button bar for [EmailRecipientDialog].
class RecipientDialogActions extends StatelessWidget {
  final bool canQueue;
  final String confirmActionLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onSkip;

  const RecipientDialogActions({
    super.key,
    required this.canQueue,
    required this.confirmActionLabel,
    required this.onConfirm,
    required this.onCancel,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (canQueue) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TacticalDialogButton.primary(
              label: confirmActionLabel,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TacticalDialogButton.secondary(
                    label: EmailDeliveryDictionary.recipientDialogAbort,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TacticalDialogButton.secondary(
                    label: EmailDeliveryDictionary.finalizeOnlySaveAction,
                    onPressed: onSkip,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TacticalDialogButton.secondary(
              label: EmailDeliveryDictionary.recipientDialogAbort,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TacticalDialogButton.primary(
              label: EmailDeliveryDictionary.finalizeOnlySaveAction,
              onPressed: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}
