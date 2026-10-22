import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Dual 24-hour and 60-minute Cupertino wheel selector with BO2 tactical styling.
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
      height: 160,
      child: Center(
        child: SizedBox(
          width: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active time selection capsule
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.amberGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.amberGold,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWheel(hourController, 24, onHourChanged),
                  const SizedBox(width: 40),
                  _buildWheel(minuteController, 60, onMinuteChanged),
                ],
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
        itemExtent: 52,
        diameterRatio: 1.5,
        magnification: 1.25,
        useMagnifier: true,
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
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
