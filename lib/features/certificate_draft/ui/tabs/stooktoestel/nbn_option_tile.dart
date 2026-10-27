import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/nbn_subtype_options.dart';

/// Single option card in the NBN connection type picker sheet.
class NbnOptionTile extends StatelessWidget {
  final NbnSubtypeOption option;
  final String typeLetter;
  final bool isSelected;
  final VoidCallback onTap;

  const NbnOptionTile({
    super.key,
    required this.option,
    required this.typeLetter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.alphaBlend(
                  AppColors.amberGold.withValues(alpha: 0.12),
                  AppColors.carbonCard,
                )
              : AppColors.carbonCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.amberGoldBorder
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.amberGold
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$typeLetter${option.code}',
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.amberGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isSelected ? AppColors.amberGold : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.amberGold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
