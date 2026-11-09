import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/two_way_sliding_bar.dart';
import 'fuel_option_tiles.dart';

/// Bare-bones, unboxed sub-section for gas installations.
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
        FormField<String>(
          initialValue: selectedSubtype,
          validator: (_) => selectedSubtype.isEmpty ? '' : null,
          builder: (subtypeState) {
            final hasSubtypeError =
                subtypeState.hasError && selectedSubtype.isEmpty;
            return Row(
              children: [
                Expanded(
                  child: TacticalOptionChip(
                    label: AppDictionary.gasNatural,
                    isSelected: selectedSubtype == 'aardgas',
                    isError: hasSubtypeError,
                    onTap: () {
                      final next =
                          selectedSubtype == 'aardgas' ? '' : 'aardgas';
                      onSubtypeChanged(next);
                      subtypeState.didChange(next);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TacticalOptionChip(
                    label: AppDictionary.gasLpg,
                    isSelected: selectedSubtype == 'LPG',
                    isError: hasSubtypeError,
                    onTap: () {
                      final next = selectedSubtype == 'LPG' ? '' : 'LPG';
                      onSubtypeChanged(next);
                      subtypeState.didChange(next);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TacticalOptionChip(
                    label: AppDictionary.gasOther,
                    isSelected: selectedSubtype == 'andere',
                    isError: hasSubtypeError,
                    onTap: () {
                      final next = selectedSubtype == 'andere' ? '' : 'andere';
                      onSubtypeChanged(next);
                      subtypeState.didChange(next);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        if (selectedSubtype == 'andere') ...[
          const SizedBox(height: 8),
          FormField<String>(
            initialValue: otherText,
            validator: (_) => otherText.trim().isEmpty ? '' : null,
            builder: (otherState) {
              return TextFormField(
                initialValue: otherText,
                style: DarkInputBox.inputStyle,
                decoration: DarkInputBox.decoration(
                  hintText: AppDictionary.hintSpecifyGas,
                  isError: otherState.hasError,
                ),
                onChanged: (val) {
                  onOtherTextChanged(val);
                  otherState.didChange(val);
                },
              );
            },
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

        // Burner technology FormField validating premix, niet-premix, or ventilatorbrander
        FormField<String>(
          initialValue: burnerTechnology,
          validator: (_) => burnerTechnology.isEmpty ? '' : null,
          builder: (techState) {
            final hasTechError = techState.hasError && burnerTechnology.isEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TwoWaySlidingBar(
                  selectedValue: burnerTechnology,
                  onValueChanged: (val) {
                    onBurnerTechChanged(val);
                    techState.didChange(val);
                  },
                  optionAValue: 'premix',
                  optionALabel: AppDictionary.techPremix,
                  optionBValue: 'niet_premix',
                  optionBLabel: AppDictionary.techNonPremix,
                  isError: hasTechError,
                ),
                const SizedBox(height: 6),
                _FanBurnerTile(
                  isSelected: isFanBurner,
                  isError: hasTechError,
                  onTap: () {
                    final next = isFanBurner ? '' : 'ventilatorbrander';
                    onBurnerTechChanged(next);
                    techState.didChange(next);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Tactical squircle tile for commercial forced-draft burners.
class _FanBurnerTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final bool isError;

  const _FanBurnerTile({
    required this.isSelected,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      canRequestFocus: false,
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
                : (isError
                    ? AppColors.errorRed
                    : Colors.white.withValues(alpha: 0.10)),
            width: (isSelected || isError) ? 1.2 : 1.0,
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
