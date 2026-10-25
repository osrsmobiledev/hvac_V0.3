import 'package:flutter/material.dart';
import 'package:hvac_app/core/widgets/tactical_squircle_box.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bento Squircle Tile matching the legacy reference sizing.
///
/// Features:
/// - Single squircle box with colored rim border (compact, well-proportioned).
/// - Centered glowing icon glyph inside the tile.
/// - Ink ripple and highlight are constrained strictly to the squircle box,
///   preventing text underneath from being highlighted.
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Squircle tile container using centralized TacticalSquircleBox
          AspectRatio(
            aspectRatio: 1.0,
            child: TacticalSquircleBox(
              icon: icon,
              accentColor: accentColor,
              borderColor: borderColor,
              borderRadius: 22,
              iconSize: 42,
              borderWidth: 1.4,
              onTap: onTap,
            ),
          ),
          // 12dp spacing following Flutter Material 3 guidelines for button/card labels
          const SizedBox(height: 12),

          // Centered 2-line title in Libron font (never highlighted)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
