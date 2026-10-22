import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Single Bento Squircle Tile for the Home Dashboard.
///
/// Features:
/// - One single solid/tonal squircle tile (no nested inner tiles).
/// - Centered glowing icon glyph inside the tile.
/// - Two-line centered title text directly beneath the tile.
class AppletBentoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const AppletBentoTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tonal surface: blend 8% accent tint over dark carbon card
    final tonalBackground = Color.alphaBlend(
      accentColor.withValues(alpha: 0.08),
      AppColors.carbonCard,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.bentoCornerRadius),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single squircle tile container with centered icon
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: tonalBackground,
                borderRadius: BorderRadius.circular(AppTheme.bentoCornerRadius),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Centered title text (Line 1 and optional Line 2)
          SizedBox(
            height: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
