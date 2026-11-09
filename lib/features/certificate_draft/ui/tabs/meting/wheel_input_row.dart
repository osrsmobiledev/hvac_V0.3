import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/dark_input_label.dart';
import '../../widgets/quick_slider_picker.dart';
import 'stepper_input_box.dart';

/// Reusable measurement field combining:
/// - A header line with parameter label on left and wider [- inputbox +] on right.
/// - Common preset option chips below (1-tap select, 1-tap deselect).
/// - FormField pre-flight validation with red error border styling on the input box.
class WheelInputRow extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final List<String> items;
  final String suffix, hintText;
  final String? preferredInitialItem;
  final TextInputAction textInputAction;
  final double height, inputWidth;
  final FormFieldValidator<String>? validator;

  const WheelInputRow({
    super.key,
    this.label,
    required this.controller,
    required this.onChanged,
    required this.items,
    this.suffix = '',
    this.hintText = '',
    this.preferredInitialItem,
    this.textInputAction = TextInputAction.next,
    this.height = 36.0,
    this.inputWidth = 148.0,
    this.validator,
  });

  /// Factory creating an integer range or preset options list.
  factory WheelInputRow.range({
    Key? key,
    String? label,
    required TextEditingController controller,
    required VoidCallback onChanged,
    required int min,
    required int max,
    int step = 1,
    List<String>? presets,
    String suffix = '',
    String hintText = '',
    String? preferredInitialItem,
    TextInputAction textInputAction = TextInputAction.next,
    double height = 36.0,
    double inputWidth = 148.0,
    FormFieldValidator<String>? validator,
  }) =>
      WheelInputRow(
        key: key,
        label: label,
        controller: controller,
        onChanged: onChanged,
        items: presets ??
            List.generate(
              ((max - min) ~/ step) + 1,
              (i) => (min + i * step).toString(),
            ),
        suffix: suffix,
        hintText: hintText,
        preferredInitialItem: preferredInitialItem,
        textInputAction: textInputAction,
        height: height,
        inputWidth: inputWidth,
        validator: validator,
      );

  void _nudgeDecimal(bool increment) {
    HapticFeedback.selectionClick();
    final raw = controller.text.trim().replaceAll(',', '.');
    final double? val = double.tryParse(raw);
    int integerPart, tenth;

    if (val == null) {
      final fallbackRaw = preferredInitialItem ??
          (items.isNotEmpty ? items[(items.length / 2).floor()] : '0');
      final fallback = double.tryParse(fallbackRaw.replaceAll(',', '.')) ?? 0.0;
      integerPart = fallback.truncate();
      tenth = increment ? 1 : 9;
    } else {
      integerPart = val.truncate();
      tenth = ((val - integerPart).abs() * 10).round() % 10;
      tenth = increment ? (tenth + 1) % 10 : (tenth - 1 + 10) % 10;
    }

    controller.text =
        tenth == 0 ? integerPart.toString() : '$integerPart,$tenth';
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row: Label on left, wider [- inputbox +] on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (label != null)
              Expanded(
                child: Text(
                  label!,
                  style: DarkInputLabel.style(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: 8),
            StepperInputBox(
              controller: controller,
              width: inputWidth,
              height: height,
              hintText: hintText,
              textInputAction: textInputAction,
              validator: validator,
              onChanged: onChanged,
              onNudgeDown: () => _nudgeDecimal(false),
              onNudgeUp: () => _nudgeDecimal(true),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 6),
          // 1-tap select / de-select preset chips
          QuickSliderPicker.forController(
            controller: controller,
            options: items,
            suffix: suffix,
            preferredInitialItem: preferredInitialItem,
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }
}
