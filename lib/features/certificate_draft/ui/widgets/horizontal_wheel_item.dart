import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Single clickable tactical dial item within [HorizontalWheelPicker].
class HorizontalWheelItem extends StatelessWidget {
  final String value;
  final String suffix;
  final bool isSelected;
  final VoidCallback onTap;

  const HorizontalWheelItem({
    super.key,
    required this.value,
    required this.suffix,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: isSelected ? 12.5 : 11.0,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: isSelected ? Colors.white : AppColors.textMuted,
    );
    final unitStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: isSelected ? 10.5 : 9.5,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      color: isSelected
          ? AppColors.amberGold.withValues(alpha: 0.9)
          : AppColors.textMuted.withValues(alpha: 0.7),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: RotatedBox(
        quarterTurns: 1,
        child: Center(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: numStyle),
              if (suffix.isNotEmpty)
                TextSpan(text: ' $suffix', style: unitStyle),
            ]),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
    );
  }
}
