import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Dual 24-hour and 60-minute Cupertino wheel selector with BO2 tactical styling.
///
/// Features:
/// - Smooth vertical [ShaderMask] gradient: numbers fade gracefully into the dark shadows.
/// - Tactical glowing selection capsule in antique gold with subtle HUD bloom.
/// - Generous 48px item spacing preventing visual crowding.
/// - Curved 3D cylindrical drum projection using Flutter SDK's [CupertinoPicker].
class Bo2TimeWheels extends StatelessWidget {
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const Bo2TimeWheels({
    super.key,
    required this.hourController,
    required this.minuteController,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 184,
      child: Center(
        child: SizedBox(
          width: 270,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active tactical selection capsule with subtle gold glow
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.08),
                    const Color(0xFF181818),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.antiqueGold.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.antiqueGold.withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),

              // Golden separator colon in the center
              const Positioned(
                child: Text(
                  ':',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.antiqueGold,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),

              // Scrollable Hour and Minute wheels masked with top/bottom fade
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.28, 0.72, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWheel(hourController, 24, onHourChanged),
                    const SizedBox(width: 36),
                    _buildWheel(minuteController, 60, onMinuteChanged),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWheel(
    FixedExtentScrollController controller,
    int count,
    ValueChanged<int> onChanged,
  ) {
    return SizedBox(
      width: 100,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 50,
        diameterRatio: 1.6,
        looping: true,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: List<Widget>.generate(
          count,
          (index) => Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tactical gold laser hairline with smooth radial gradient falloff at the edges.
/// Shared between [Bo2TimeWheels] siblings to stay within file-length limits.
class Bo2LaserDivider extends StatelessWidget {
  const Bo2LaserDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.antiqueGold.withValues(alpha: 0.55),
            AppColors.antiqueGold.withValues(alpha: 0.55),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.75, 1.0],
        ),
      ),
    );
  }
}

/// Column label row showing 'UREN' and 'MINUTEN' above the time wheels.
/// Extracted from [Bo2TimeSpinnerDialog] to keep that file under 250 lines.
class Bo2WheelColumnLabels extends StatelessWidget {
  const Bo2WheelColumnLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                AppDictionary.lblHours,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.antiqueGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          SizedBox(width: 36),
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                AppDictionary.lblMinutes,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.antiqueGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
