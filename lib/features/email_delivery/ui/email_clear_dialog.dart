import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';

/// Displays a confirmation dialog before clearing SMTP credentials.
Future<bool?> showEmailClearConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dCtx) => AlertDialog(
      backgroundColor: AppColors.carbonCard,
      title: const Text(
        EmailDeliveryDictionary.clearSettingsDialogTitle,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: const Text(
        EmailDeliveryDictionary.clearSettingsDialogMessage,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dCtx).pop(false),
          child: const Text(
            EmailDeliveryDictionary.clearSettingsCancel,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dCtx).pop(true),
          child: const Text(
            EmailDeliveryDictionary.clearSettingsConfirm,
            style: TextStyle(
              color: AppColors.destructiveRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
