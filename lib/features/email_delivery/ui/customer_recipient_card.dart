import 'package:flutter/material.dart';
import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Tactical card presenting customer recipient information.
/// Symmetrical with [TechnicianRecipientCard].
class CustomerRecipientCard extends StatelessWidget {
  final String name;
  final String email;
  final bool hasEmail;
  final bool sendCustomer;
  final ValueChanged<bool?>? onChanged;

  const CustomerRecipientCard({
    super.key,
    required this.name,
    required this.email,
    required this.hasEmail,
    required this.sendCustomer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = name.isNotEmpty
        ? '${EmailDeliveryDictionary.recipientCustomerLabel}: $name'
        : EmailDeliveryDictionary.recipientCustomerLabel;

    if (hasEmail) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.carbonCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: InkWell(
          onTap: onChanged != null ? () => onChanged!(!sendCustomer) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.antiqueGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: sendCustomer,
                  activeColor: AppColors.amberGold,
                  checkColor: Colors.black,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Clean, full-width status card when customer has no email (no truncating badges)
    return Container(
      decoration: BoxDecoration(
        color: AppColors.carbonCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: AppColors.antiqueGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                const Text(
                  EmailDeliveryDictionary.recipientNoCustomerEmail,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  EmailDeliveryDictionary.recipientPaperNotice,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
