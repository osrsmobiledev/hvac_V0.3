import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';

/// Tactical tile representing an existing customer in search results.
/// Supports both customer selection and customer deletion from SQLite.
class CustomerResultTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CustomerResultTile({
    super.key,
    required this.customer,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.charcoalGlass,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.goldHairline,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.antiqueGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.formattedAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customer.phone != null &&
                        customer.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tel: ${customer.phone}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE57373),
                    size: 20,
                  ),
                  tooltip: AppDictionary.dlgDeleteFromDbConfirm,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onDelete!();
                  },
                ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.antiqueGold,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
