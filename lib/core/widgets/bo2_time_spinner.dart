import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'bo2_time_wheels.dart';

/// BO2-themed 24-hour Cupertino time picker modal with Dutch localization.
Future<void> showBo2TimeSpinner(
  BuildContext context,
  TextEditingController controller, {
  VoidCallback? onTimeSelected,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();

  TimeOfDay selectedTime = TimeOfDay.now();
  if (controller.text.isNotEmpty && controller.text.contains(':')) {
    try {
      final parts = controller.text.split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {}
  }

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return _Bo2TimeSpinnerDialog(
        initialTime: selectedTime,
        onConfirmed: (timeStr) {
          controller.text = timeStr;
          onTimeSelected?.call();
        },
      );
    },
  );
}

class _Bo2TimeSpinnerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<String> onConfirmed;

  const _Bo2TimeSpinnerDialog({
    required this.initialTime,
    required this.onConfirmed,
  });

  @override
  State<_Bo2TimeSpinnerDialog> createState() => _Bo2TimeSpinnerDialogState();
}

class _Bo2TimeSpinnerDialogState extends State<_Bo2TimeSpinnerDialog> {
  late int _tempHour;
  late int _tempMinute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _tempHour = widget.initialTime.hour;
    _tempMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _tempHour);
    _minuteController = FixedExtentScrollController(initialItem: _tempMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.charcoalGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 22, bottom: 14),
                child: Text(
                  'Tijd instellen',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Bo2LaserDivider(),
              const Bo2WheelColumnLabels(),
              Bo2TimeWheels(
                hourController: _hourController,
                minuteController: _minuteController,
                onHourChanged: (v) => _tempHour = v,
                onMinuteChanged: (v) => _tempMinute = v,
              ),
              const SizedBox(height: 6),
              const Bo2LaserDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF1E1E1E),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text(
                          'Annuleren',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                          final hStr = _tempHour.toString().padLeft(2, '0');
                          final mStr = _tempMinute.toString().padLeft(2, '0');
                          widget.onConfirmed('$hStr:$mStr');
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.antiqueGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
