import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Primary test slot button (Proef I vs Proef II) in the statutory measurement selector.
///
/// Styled according to the "Start" tab dark luxury aesthetic:
/// - Subtle antique-gold tonal blend over dark base when selected (#141414).
/// - Non-glaring amber/antique gold border (#8A6A1D), hairline border when unselected.
/// - Crisp white title with left-aligned layout and antique gold subtitle.
class MainSlotTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;
  final bool hasData;

  const MainSlotTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.hasData = false,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle antique-gold tonal blend over dark base when selected (matching Tab 'Start')
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.10),
            const Color(0xFF141414),
          )
        : const Color(0xFF0C0C0C);

    // Muted amber/antique gold border when selected (#8A6A1D), hairline when unselected
    final borderColor = isSelected
        ? AppColors.amberGoldBorder
        : Colors.white.withValues(alpha: 0.12);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border:
                Border.all(color: borderColor, width: isSelected ? 1.2 : 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                        if (hasData) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.antiqueGold,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.antiqueGold
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                badge!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
