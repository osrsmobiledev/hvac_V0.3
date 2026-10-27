import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Tactical horizontal quick-selection ribbon for top boiler brands in Flanders.
///
/// Features:
/// - Provides 1-tap brand population without requiring touchscreen typing.
/// - Distinct individual brands (never merged, e.g. Bosch and Junkers separate).
/// - Case-insensitive real-time synchronization with active text controller.
/// - Amber-gold tactical active highlight with dot reticle indicator.
class BrandQuickPicker extends StatelessWidget {
  final String selectedBrand;
  final ValueChanged<String> onBrandSelected;
  final List<String> brands;

  static const List<String> defaultBoilerBrands = [
    'Vaillant',
    'Viessmann',
    'Remeha',
    'Bulex',
    'Bosch',
    'Junkers',
    'Daikin',
    'Weishaupt',
    'ACV',
    'Buderus',
    'ATAG',
  ];

  static const List<String> defaultBurnerBrands = [
    'Weishaupt',
    'Riello',
    'Elco',
    'Bentone',
    'Buderus',
    'Viessmann',
    'MAN / MHG',
    'Giersch',
    'ACV',
  ];

  const BrandQuickPicker({
    super.key,
    required this.selectedBrand,
    required this.onBrandSelected,
    this.brands = defaultBoilerBrands,
  });

  Widget _buildChip(String brand, bool isSelected) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onBrandSelected(isSelected ? '' : brand);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amberGold.withValues(alpha: 0.18)
              : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.amberGoldBorder
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.amberGold,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              brand,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: AppTheme.fontFamily,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedCurrent = selectedBrand.trim().toLowerCase();

    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < brands.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _buildChip(brands[i], trimmedCurrent == brands[i].toLowerCase()),
            ],
          ],
        ),
      ),
    );
  }
}
