import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tactical HUD inward-merging brackets and laser line indicator.
///
/// Features:
/// - Optical track with dynamic central laser beam growth.
/// - Left white bracket and right amber gold bracket gliding inward.
/// - Merges into a central lock pulse.
class InwardMergeIndicator extends StatelessWidget {
  final double progress;
  final double pulse;

  const InwardMergeIndicator({
    super.key,
    required this.progress,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    const double trackWidth = 140.0;
    // Brackets start at the outer edges (70px out) and merge inward to center (0px)
    final double offset = (1.0 - progress) * (trackWidth / 2 - 8);

    return SizedBox(
      width: trackWidth,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle hairline track
          Container(
            width: trackWidth,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.08),
          ),

          // Central growing laser bar as brackets approach
          Container(
            width: (progress * trackWidth).clamp(0.0, trackWidth),
            height: 2.0,
            decoration: BoxDecoration(
              color:
                  AppColors.amberGold.withValues(alpha: 0.4 + 0.6 * progress),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amberGold.withValues(alpha: 0.35 * pulse),
                  blurRadius: 8 * pulse,
                ),
              ],
            ),
          ),

          // Left bracket gliding inward (white optical reticle)
          Transform.translate(
            offset: Offset(-offset, 0),
            child: Container(
              width: 8,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: AppColors.amberGold, blurRadius: 6),
                ],
              ),
            ),
          ),

          // Right bracket gliding inward (amber gold reticle)
          Transform.translate(
            offset: Offset(offset, 0),
            child: Container(
              width: 8,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.amberGold,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: AppColors.amberGold, blurRadius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
