import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bento Squircle Tile matching the legacy reference sizing.
///
/// Features:
/// - Single squircle box with colored rim border (compact, well-proportioned).
/// - Centered glowing icon glyph inside the tile.
/// - Centered 2-line title in Libron font directly beneath the tile.
class AppletBentoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final Color borderColor;
  final VoidCallback onTap;

  const AppletBentoTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tonal surface: blend 8% accent tint over the dark carbon background
    final tonalBackground = Color.alphaBlend(
      accentColor.withValues(alpha: 0.08),
      AppColors.carbonCard,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single compact squircle tile container with colored rim border
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: tonalBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: borderColor,
                  width: 1.4,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 42,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Centered 2-line title in Libron font
          SizedBox(
            height: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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
                      fontFamily: AppTheme.fontFamily,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
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
