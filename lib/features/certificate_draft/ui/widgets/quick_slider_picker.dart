import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable horizontal slider ribbon picker for fast 1-tap value selection.
///
/// Features:
/// - Horizontal bouncing scroll ribbon (height 32).
/// - Clean dark carbon styling with amber-gold border & subtle background highlight.
/// - Togglable tap behavior: tap to select, tap again to unselect (clears value).
/// - Haptic feedback on selection.
class QuickSliderPicker extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final List<String> options;
  final String suffix;

  const QuickSliderPicker({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
    this.suffix = '',
  });

  /// Convenience factory that binds directly to a [TextEditingController].
  static Widget forController({
    Key? key,
    required TextEditingController controller,
    required List<String> options,
    required VoidCallback onChanged,
    String suffix = '',
  }) {
    return ListenableBuilder(
      key: key,
      listenable: controller,
      builder: (context, _) {
        return QuickSliderPicker(
          selectedValue: controller.text,
          options: options,
          suffix: suffix,
          onSelected: (val) {
            controller.text = val;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: val.length),
            );
            onChanged();
          },
        );
      },
    );
  }

  Widget _buildChip(String val, bool isSelected) {
    final displayText = suffix.isEmpty ? val : '$val $suffix';

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected(isSelected ? '' : val);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: AppTheme.fontFamily,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedCurrent = selectedValue.trim().toLowerCase();

    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _buildChip(
                options[i],
                trimmedCurrent == options[i].trim().toLowerCase(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
