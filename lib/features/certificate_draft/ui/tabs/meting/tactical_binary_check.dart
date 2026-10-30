import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Tactical binary toggle ([OK] / [Niet OK]) for statutory combustion assessments.
///
/// Styled according to the "Start" tab dark luxury aesthetic (antique gold / terracotta):
/// - Subtle tonal blend over dark base when active, avoiding bright blinding glare on OLED.
/// - Non-glaring amber/antique gold border (#8A6A1D) or terracotta border with crisp white typography.
/// - Tactile haptic feedback on touch ([HapticFeedback.selectionClick]).
/// - Tapping an already selected state deselects it back to neutral (null).
/// - Supports [isCompact] mode for high-density HUD cards without crowding.
class TacticalBinaryCheck extends StatelessWidget {
  final bool? value; // true = OK, false = Niet OK, null = unselected
  final ValueChanged<bool?> onChanged;
  final double height;
  final double? width;
  final bool isCompact;
  final bool useNokLabel;

  const TacticalBinaryCheck({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 42.0,
    this.width,
    this.isCompact = false,
    this.useNokLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact(context);
    }
    return _buildStandard(context);
  }

  Widget _buildCompact(BuildContext context) {
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
              child: _CompactCheckButton(
                label: MetingDictionary.lblOk,
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
              child: _CompactCheckButton(
                label: useNokLabel
                    ? MetingDictionary.lblNok
                    : MetingDictionary.lblNotOk,
                isActive: value == false,
                activeBg: Color.alphaBlend(
                  AppColors.terracotta.withValues(alpha: 0.22),
                  const Color(0xFF141414),
                ),
                activeBorder: AppColors.terracottaBorder,
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
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _CheckButton(
              label: MetingDictionary.lblOk,
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
            child: _CheckButton(
              label: MetingDictionary.lblNotOk,
              isActive: value == false,
              activeBackgroundColor: Color.alphaBlend(
                AppColors.terracotta.withValues(alpha: 0.14),
                const Color(0xFF141414),
              ),
              activeBorderColor: AppColors.terracottaBorder,
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

class _CompactCheckButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeBorder;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _CompactCheckButton({
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeBorder,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: isActive ? Border.all(color: activeBorder, width: 1.0) : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeTextColor : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBackgroundColor;
  final Color activeBorderColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _CheckButton({
    required this.label,
    required this.isActive,
    required this.activeBackgroundColor,
    required this.activeBorderColor,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBackgroundColor : const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isActive
                ? activeBorderColor
                : Colors.white.withValues(alpha: 0.12),
            width: isActive ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: isActive ? activeTextColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
