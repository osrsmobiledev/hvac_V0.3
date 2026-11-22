import 'package:flutter/material.dart';
import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Bento card presenting technician copy option and email dispatch toggle.
/// Symmetrical with [CustomerRecipientCard].
class TechnicianRecipientCard extends StatelessWidget {
  final String email;
  final bool copyTechnician;
  final ValueChanged<bool?>? onChanged;

  const TechnicianRecipientCard({
    super.key,
    required this.email,
    required this.copyTechnician,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.carbonCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(!copyTechnician) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 20,
                color: AppColors.antiqueGold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      EmailDeliveryDictionary.recipientTechnicianLabel,
                      style: TextStyle(
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
                value: copyTechnician,
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
}
