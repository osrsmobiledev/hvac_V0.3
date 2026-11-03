// File: lib/core/widgets/tactical_binary_check.dart
// Responsibility: Centralized BO2 Tactical binary toggle ([OK]/[Niet OK], Goed/Niet goed, or custom pairs).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'compact_check_button.dart';
import 'tactical_check_button.dart';

/// Centralized BO2 Tactical binary toggle with haptic feedback and tap-to-deselect.
class TacticalBinaryCheck extends StatelessWidget {
  final bool?
      value; // true = positive/first, false = negative/second, null = unselected
  final ValueChanged<bool?> onChanged;
  final String? positiveLabel;
  final String? negativeLabel;
  final double height;
  final double? width;
  final bool isCompact;
  final bool useNokLabel;
  final bool isSymmetricalGold;

  const TacticalBinaryCheck({
    super.key,
    required this.value,
    required this.onChanged,
    this.positiveLabel,
    this.negativeLabel,
    this.height = 42.0,
    this.width,
    this.isCompact = false,
    this.useNokLabel = false,
    this.isSymmetricalGold = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact(context);
    }
    return _buildStandard(context);
  }

  Widget _buildCompact(BuildContext context) {
    final effectivePositive = positiveLabel ?? MetingDictionary.lblOk;
    final effectiveNegative = negativeLabel ??
        (useNokLabel ? MetingDictionary.lblNok : MetingDictionary.lblNotOk);

    final negBg = isSymmetricalGold
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.22),
            const Color(0xFF141414),
          )
        : Color.alphaBlend(
            AppColors.terracotta.withValues(alpha: 0.22),
            const Color(0xFF141414),
          );

    final negBorder = isSymmetricalGold
        ? AppColors.amberGoldBorder
        : AppColors.terracottaBorder;

    return SizedBox(
      width: width ?? 136.0,
      height: height == 42.0 ? 32.0 : height,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: const Color(0xFF080808),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: CompactCheckButton(
                label: effectivePositive,
                isActive: value == true,
                activeBg: Color.alphaBlend(
                  AppColors.antiqueGold.withValues(alpha: 0.22),
                  const Color(0xFF141414),
                ),
                activeBorder: AppColors.amberGoldBorder,
                activeTextColor: Colors.white,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(value == true ? null : true);
                },
              ),
            ),
            const SizedBox(width: 2.0),
            Expanded(
              child: CompactCheckButton(
                label: effectiveNegative,
                isActive: value == false,
                activeBg: negBg,
                activeBorder: negBorder,
                activeTextColor: Colors.white,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(value == false ? null : false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandard(BuildContext context) {
    final effectivePositive = positiveLabel ?? MetingDictionary.lblOk;
    final effectiveNegative = negativeLabel ??
        (useNokLabel ? MetingDictionary.lblNok : MetingDictionary.lblNotOk);

    final negBg = isSymmetricalGold
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.12),
            const Color(0xFF141414),
          )
        : Color.alphaBlend(
            AppColors.terracotta.withValues(alpha: 0.14),
            const Color(0xFF141414),
          );

    final negBorder = isSymmetricalGold
        ? AppColors.amberGoldBorder
        : AppColors.terracottaBorder;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: TacticalCheckButton(
              label: effectivePositive,
              isActive: value == true,
              activeBackgroundColor: Color.alphaBlend(
                AppColors.antiqueGold.withValues(alpha: 0.12),
                const Color(0xFF141414),
              ),
              activeBorderColor: AppColors.amberGoldBorder,
              activeTextColor: Colors.white,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value == true ? null : true);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TacticalCheckButton(
              label: effectiveNegative,
              isActive: value == false,
              activeBackgroundColor: negBg,
              activeBorderColor: negBorder,
              activeTextColor: Colors.white,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value == false ? null : false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
