import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Informative status banner displayed above the outbox action buttons.
/// Informs the technician why sending is paused or offline.
class EmailOutboxBanner extends StatelessWidget {
  final bool isConfigured;
  final bool needsAttention;
  final bool isOffline;

  const EmailOutboxBanner({
    super.key,
    required this.isConfigured,
    required this.needsAttention,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) {
      return _buildContainer(
        color: AppColors.warningOrange,
        icon: Icons.warning_amber_rounded,
        message: EmailDeliveryDictionary.outboxUnconfiguredNotice,
      );
    }

    if (needsAttention) {
      return _buildContainer(
        color: AppColors.errorRed,
        icon: Icons.lock_reset,
        message: EmailDeliveryDictionary.outboxNeedsAttentionNotice,
      );
    }

    if (isOffline) {
      return _buildContainer(
        color: AppColors.slate,
        icon: Icons.wifi_off_rounded,
        message: EmailDeliveryDictionary.outboxOfflineNotice,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContainer({
    required Color color,
    required IconData icon,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
