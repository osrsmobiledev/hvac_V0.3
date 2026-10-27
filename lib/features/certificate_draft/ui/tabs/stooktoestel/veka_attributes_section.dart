import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/two_way_sliding_bar.dart';

/// Renders the VEKA heating type and boiler operation selectors using Layout B:
/// A full-width 50/50 symmetrical 2-way slider for the two primary choices,
/// paired with a separated "Onbekend" fallback chip in the section header.
class VekaAttributesSection extends StatelessWidget {
  final String heatingType;
  final String boilerOperation;
  final ValueChanged<String> onHeatingTypeChanged;
  final ValueChanged<String> onBoilerOperationChanged;

  const VekaAttributesSection({
    super.key,
    required this.heatingType,
    required this.boilerOperation,
    required this.onHeatingTypeChanged,
    required this.onBoilerOperationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Type verwarming
        _HeaderWithUnknownChip(
          title: AppDictionary.lblHeatingType,
          isUnknown: heatingType == 'onbekend',
          onUnknownTap: () => onHeatingTypeChanged('onbekend'),
        ),
        const SizedBox(height: 6),
        TwoWaySlidingBar(
          selectedValue: heatingType,
          onValueChanged: onHeatingTypeChanged,
          optionAValue: 'individueel',
          optionALabel: AppDictionary.optIndividual,
          optionBValue: 'collectief',
          optionBLabel: AppDictionary.optCollective,
        ),
        const SizedBox(height: 14),

        // 2. Werking ketel
        _HeaderWithUnknownChip(
          title: AppDictionary.lblOperation,
          isUnknown: boilerOperation == 'onbekend',
          onUnknownTap: () => onBoilerOperationChanged('onbekend'),
        ),
        const SizedBox(height: 6),
        TwoWaySlidingBar(
          selectedValue: boilerOperation,
          onValueChanged: onBoilerOperationChanged,
          optionAValue: 'condenserend',
          optionALabel: AppDictionary.optCondensing,
          optionBValue: 'niet_condenserend',
          optionBLabel: AppDictionary.optNonCondensing,
        ),
      ],
    );
  }
}

/// Title row with a separated statutory "Onbekend" chip on the right.
class _HeaderWithUnknownChip extends StatelessWidget {
  final String title;
  final bool isUnknown;
  final VoidCallback onUnknownTap;

  const _HeaderWithUnknownChip({
    required this.title,
    required this.isUnknown,
    required this.onUnknownTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onUnknownTap();
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isUnknown
                  ? AppColors.amberGold.withValues(alpha: 0.20)
                  : const Color(0xFF141414),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isUnknown
                    ? AppColors.amberGoldBorder
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              AppDictionary.optUnknown,
              style: TextStyle(
                color: isUnknown ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isUnknown ? FontWeight.w700 : FontWeight.w500,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
