// File: lib/core/widgets/bo2_time_spinner.dart
// Line Count: ~110 lines
// Responsibility: A globally accessible, BO2-themed Cupertino time picker.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hvac_field_service/core/theme/app_colors.dart';

Future<void> showBo2TimeSpinner(
    BuildContext context, TextEditingController controller) async {
  // ACTION TRIGGER [LOGIC]: Kill ghost focus to prevent keyboard collisions
  FocusManager.instance.primaryFocus?.unfocus();

  TimeOfDay selectedTime = TimeOfDay.now();

  if (controller.text.isNotEmpty && controller.text.contains(':')) {
    try {
      final parts = controller.text.split(':');
      selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {}
  }

  int tempHour = selectedTime.hour;
  int tempMinute = selectedTime.minute;

  final FixedExtentScrollController hourController =
      FixedExtentScrollController(initialItem: tempHour);
  final FixedExtentScrollController minuteController =
      FixedExtentScrollController(initialItem: tempMinute);

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.charcoalGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 40,
                    offset: const Offset(0, 20))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: const Text('Set Time',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                ),
                Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent
                    ]))),
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                          width: 100,
                          child: Center(
                              child: Text('HOURS',
                                  style: TextStyle(
                                      color: AppColors.goldAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5)))),
                      const SizedBox(width: 40),
                      const SizedBox(
                          width: 100,
                          child: Center(
                              child: Text('MINUTES',
                                  style: TextStyle(
                                      color: AppColors.goldAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5)))),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: Center(
                    child: SizedBox(
                      width: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: AppColors.goldAccent
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: AppColors.goldAccent
                                        .withValues(alpha: 0.25),
                                    width: 1.2)),
                          ),
                          const Text(':',
                              style: TextStyle(
                                  color: AppColors.goldAccent,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                child: CupertinoPicker(
                                  scrollController: hourController,
                                  itemExtent: 56,
                                  diameterRatio: 1.5,
                                  magnification: 1.25,
                                  useMagnifier: true,
                                  looping: true,
                                  selectionOverlay: const SizedBox.shrink(),
                                  onSelectedItemChanged: (int value) =>
                                      tempHour = value,
                                  children: List<Widget>.generate(
                                      24,
                                      (int index) => Center(
                                          child: Text(
                                              index.toString().padLeft(2, '0'),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight:
                                                      FontWeight.w500)))),
                                ),
                              ),
                              const SizedBox(width: 40),
                              SizedBox(
                                width: 100,
                                child: CupertinoPicker(
                                  scrollController: minuteController,
                                  itemExtent: 56,
                                  diameterRatio: 1.5,
                                  magnification: 1.25,
                                  useMagnifier: true,
                                  looping: true,
                                  selectionOverlay: const SizedBox.shrink(),
                                  onSelectedItemChanged: (int value) =>
                                      tempMinute = value,
                                  children: List<Widget>.generate(
                                      60,
                                      (int index) => Center(
                                          child: Text(
                                              index.toString().padLeft(2, '0'),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight:
                                                      FontWeight.w500)))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent
                    ]))),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.goldAccent
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              // ACTION TRIGGER [LOGIC]: Push data directly back to the text controller
                              controller.text =
                                  "${tempHour.toString().padLeft(2, '0')}:${tempMinute.toString().padLeft(2, '0')}";
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: AppColors.goldAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: const Text('OK',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
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
    },
  );
  hourController.dispose();
  minuteController.dispose();
}
