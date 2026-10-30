import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/horizontal_wheel_picker.dart';

/// A reusable row combining a 3D cylindrical horizontal wheel picker on the left (50%)
/// with a responsive, centered numeric input box featuring '-' and '+' decimal
/// nudge steppers on the right (50%).
///
/// Features:
/// - True 3D cylindrical wheel with Cupertino momentum physics and magnification.
/// - Tactile '-' and '+' buttons inside the input box for effortless 0.1 decimal stepping.
/// - Cycling decimal tenths: e.g. starting at 20 and tapping '-' yields 20,9 in 1 tap!
/// - Centered direct numeric keyboard typing remains fully accessible.
/// - Bi-directional 2-way synchronization between wheel and text controller.
/// - Responsive 50% / 50% flex distribution with unified 38px touch targets.
class WheelInputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final List<String> items;
  final String suffix;
  final String hintText;
  final String? preferredInitialItem;
  final TextInputAction textInputAction;
  final double height;
  final int wheelFlex;
  final int inputFlex;
  final double itemExtent;

  const WheelInputRow({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.items,
    this.suffix = '',
    this.hintText = '',
    this.preferredInitialItem,
    this.textInputAction = TextInputAction.next,
    this.height = 38.0,
    this.wheelFlex = 5,
    this.inputFlex = 5,
    this.itemExtent = 64.0,
  });

  /// Factory creating a continuous integer range (e.g. 15 to 37 mbar).
  factory WheelInputRow.range({
    Key? key,
    required TextEditingController controller,
    required VoidCallback onChanged,
    required int min,
    required int max,
    int step = 1,
    String suffix = '',
    String hintText = '',
    String? preferredInitialItem,
    TextInputAction textInputAction = TextInputAction.next,
    double height = 38.0,
    int wheelFlex = 5,
    int inputFlex = 5,
    double itemExtent = 64.0,
  }) {
    return WheelInputRow(
      key: key,
      controller: controller,
      onChanged: onChanged,
      items: List.generate(
        ((max - min) ~/ step) + 1,
        (i) => (min + i * step).toString(),
      ),
      suffix: suffix,
      hintText: hintText,
      preferredInitialItem: preferredInitialItem,
      textInputAction: textInputAction,
      height: height,
      wheelFlex: wheelFlex,
      inputFlex: inputFlex,
      itemExtent: itemExtent,
    );
  }

  void _nudgeDecimal(bool increment) {
    HapticFeedback.selectionClick();
    final raw = controller.text.trim().replaceAll(',', '.');
    final double? val = double.tryParse(raw);

    int integerPart;
    int tenth;

    if (val == null) {
      final fallbackRaw = preferredInitialItem ??
          (items.isNotEmpty ? items[(items.length / 2).floor()] : '0');
      final fallback = double.tryParse(fallbackRaw) ?? 0.0;
      integerPart = fallback.truncate();
      tenth = increment ? 1 : 9;
    } else {
      integerPart = val.truncate();
      tenth = ((val - integerPart).abs() * 10).round() % 10;
      if (increment) {
        tenth = (tenth + 1) % 10;
      } else {
        tenth = (tenth - 1 + 10) % 10;
      }
    }

    if (tenth == 0) {
      controller.text = integerPart.toString();
    } else {
      controller.text = '$integerPart,$tenth';
    }
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: 50% flex for the 3D cylindrical wheel
        Expanded(
          flex: wheelFlex,
          child: HorizontalWheelPicker(
            items: items,
            controller: controller,
            preferredInitialItem: preferredInitialItem,
            suffix: suffix,
            height: height,
            itemExtent: itemExtent,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        // Right: 50% flex for the input box with '-' and '+' decimal steppers
        Expanded(
          flex: inputFlex,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Nudge down (-)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _nudgeDecimal(false),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(7.0),
                    ),
                    child: Container(
                      width: 28,
                      height: height,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.remove,
                        size: 15,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ),
                ),
                // Editable centered numeric text field
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    style: DarkInputBox.inputStyle.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: textInputAction,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                // Nudge up (+)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _nudgeDecimal(true),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(7.0),
                    ),
                    child: Container(
                      width: 28,
                      height: height,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add,
                        size: 15,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
