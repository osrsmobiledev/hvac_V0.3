import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/tactical_dialog_button.dart';

/// Primary action buttons (Test Connection & Save Settings) for [EmailSettingsCard].
class EmailSettingsActionButtons extends StatelessWidget {
  final bool isTesting;
  final bool isSaving;
  final bool canAct;
  final VoidCallback? onTest;
  final VoidCallback? onSave;

  const EmailSettingsActionButtons({
    super.key,
    required this.isTesting,
    required this.isSaving,
    required this.canAct,
    required this.onTest,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TacticalDialogButton.secondary(
            label: isTesting
                ? EmailDeliveryDictionary.testingConnection
                : EmailDeliveryDictionary.testConnectionButton,
            onPressed: canAct ? onTest : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TacticalDialogButton.primary(
            label: isSaving
                ? EmailDeliveryDictionary.savingSettings
                : EmailDeliveryDictionary.saveSettingsButton,
            onPressed: canAct ? onSave : null,
          ),
        ),
      ],
    );
  }
}

/// Destructive clear settings button for [EmailSettingsCard].
class EmailSettingsClearButton extends StatelessWidget {
  final bool isClearing;
  final bool isEnabled;
  final VoidCallback? onClear;

  const EmailSettingsClearButton({
    super.key,
    required this.isClearing,
    required this.isEnabled,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: isEnabled ? onClear : null,
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: 16,
          color: AppColors.destructiveRed,
        ),
        label: Text(
          isClearing
              ? EmailDeliveryDictionary.clearingSettings
              : EmailDeliveryDictionary.clearSettingsButton,
          style: const TextStyle(
            color: AppColors.destructiveRed,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
