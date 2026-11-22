import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';

/// Color-coded status badge with icon for an email delivery job.
class EmailStatusBadge extends StatelessWidget {
  final String status;
  const EmailStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'sent' => (
          EmailDeliveryDictionary.badgeSent,
          Colors.green,
          Icons.check_circle
        ),
      'sending' => (
          EmailDeliveryDictionary.badgeSending,
          Colors.blue,
          Icons.sync
        ),
      'recipient_rejected' => (
          EmailDeliveryDictionary.badgeRecipientRejected,
          Colors.red,
          Icons.error_outline
        ),
      'uncertain_timeout' => (
          EmailDeliveryDictionary.badgeUncertainTimeout,
          Colors.orange,
          Icons.help_outline
        ),
      'server_rejected' || 'failed' => (
          EmailDeliveryDictionary.badgeServerRejected,
          Colors.red,
          Icons.warning_amber_rounded
        ),
      'resolved_manually' => (
          EmailDeliveryDictionary.badgeResolvedManually,
          Colors.teal,
          Icons.verified_outlined
        ),
      _ => (EmailDeliveryDictionary.badgeQueued, Colors.grey, Icons.schedule),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
