import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';

/// Warning banner displayed when SMTP state is 'needs_attention'.
class EmailNeedsAttentionBanner extends StatelessWidget {
  const EmailNeedsAttentionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1C0E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.amberGoldBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.amberGold, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              EmailDeliveryDictionary.needsAttentionWarning,
              style: TextStyle(color: AppColors.amberGold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner displayed when an SMTP clear operation failed or is pending.
class EmailClearingErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  final bool enabled;

  const EmailClearingErrorBanner(
      {super.key, required this.onRetry, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0E0E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.errorRed, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  EmailDeliveryDictionary.clearSettingsError,
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: enabled ? onRetry : null,
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: AppColors.amberGold),
              label: const Text(
                EmailDeliveryDictionary.btnRetryInit,
                style: TextStyle(
                  color: AppColors.amberGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
