import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// A full-width 50/50 symmetrical 2-way sliding bar.
///
/// Features:
/// - Smooth gliding amber pill thumb when one of the 2 primary options is active.
/// - Fades out thumb when an external fallback (like 'onbekend') is active.
/// - Big, comfortable 12.5pt bold text for maximum legibility.
class TwoWaySlidingBar extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onValueChanged;
  final String optionAValue;
  final String optionALabel;
  final String optionBValue;
  final String optionBLabel;

  const TwoWaySlidingBar({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.optionAValue,
    required this.optionALabel,
    required this.optionBValue,
    required this.optionBLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isA = selectedValue == optionAValue;
    final bool isB = selectedValue == optionBValue;
    final bool hasActiveSelection = isA || isB;
    final double alignX = isB ? 1.0 : -1.0;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          // 1. Sliding illuminated amber pill
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: hasActiveSelection ? 1.0 : 0.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment(alignX, 0.0),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: AppColors.amberGold.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: AppColors.amberGoldBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amberGold.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Symmetrical 50/50 options
          Row(
            children: [
              _SlideOption(
                label: optionALabel,
                isSelected: isA,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(9),
                ),
                onTap: () => onValueChanged(optionAValue),
              ),
              _SlideOption(
                label: optionBLabel,
                isSelected: isB,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(9),
                ),
                onTap: () => onValueChanged(optionBValue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlideOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const _SlideOption({
    required this.label,
    required this.isSelected,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: borderRadius,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
