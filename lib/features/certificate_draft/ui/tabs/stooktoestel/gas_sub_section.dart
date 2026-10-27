import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/two_way_sliding_bar.dart';
import 'fuel_option_tiles.dart';

/// Bare-bones, unboxed sub-section for gas installations.
///
/// Features:
/// - Gas subtype selection via tactical option chips.
/// - Symmetrical 2-way slider for the two primary burner technologies (Premix vs Niet-premix).
/// - Dedicated tactical tile for rare commercial forced-draft burners (GII).
/// - Clean typography with zero distracting info badges.
class GasSubSection extends StatelessWidget {
  final String selectedSubtype;
  final String otherText;
  final String burnerTechnology;
  final ValueChanged<String> onSubtypeChanged;
  final ValueChanged<String> onOtherTextChanged;
  final ValueChanged<String> onBurnerTechChanged;

  const GasSubSection({
    super.key,
    required this.selectedSubtype,
    required this.otherText,
    required this.burnerTechnology,
    required this.onSubtypeChanged,
    required this.onOtherTextChanged,
    required this.onBurnerTechChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFanBurner = burnerTechnology == 'ventilatorbrander';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Gas subtype selection
        const Text(
          AppDictionary.headerGasDetails,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.gasNatural,
                isSelected: selectedSubtype == 'aardgas',
                onTap: () => onSubtypeChanged('aardgas'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.gasLpg,
                isSelected: selectedSubtype == 'LPG',
                onTap: () => onSubtypeChanged('LPG'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.gasOther,
                isSelected: selectedSubtype == 'andere',
                onTap: () => onSubtypeChanged('andere'),
              ),
            ),
          ],
        ),
        if (selectedSubtype == 'andere') ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: otherText,
            style: DarkInputBox.inputStyle,
            decoration: DarkInputBox.decoration(
              hintText: AppDictionary.hintSpecifyGas,
            ),
            onChanged: onOtherTextChanged,
          ),
        ],
        const SizedBox(height: 14),

        // 2. Brandertechnologie header
        const Text(
          AppDictionary.headerBurnerTech,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // 2-Way Symmetrical Slider for the 2 primary choices
        TwoWaySlidingBar(
          selectedValue: burnerTechnology,
          onValueChanged: onBurnerTechChanged,
          optionAValue: 'premix',
          optionALabel: AppDictionary.techPremix,
          optionBValue: 'niet_premix',
          optionBLabel: AppDictionary.techNonPremix,
        ),
        const SizedBox(height: 6),

        // Dedicated tile for rare commercial forced-draft burner (GII)
        _FanBurnerTile(
          isSelected: isFanBurner,
          onTap: () => onBurnerTechChanged('ventilatorbrander'),
        ),
      ],
    );
  }
}

/// Tactical squircle tile for commercial forced-draft burners.
class _FanBurnerTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _FanBurnerTile({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amberGold.withValues(alpha: 0.18)
              : const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.amberGoldBorder
                : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppDictionary.techFanBurner,
            maxLines: 1,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
