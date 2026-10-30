import 'package:flutter/material.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/quick_slider_picker.dart';

/// A symmetrical row combining the horizontal quick slider chips on the left
/// with a responsive, centered numeric input box on the right.
///
/// Uses an adaptive 60% / 40% flex ratio by default (matching the 3D wheel dial
/// for Keteltemperatuur), ensuring pixel-perfect vertical alignment and symmetry.
class SliderInputRow extends StatelessWidget {
  final TextEditingController controller;
  final List<String> options;
  final String suffix;
  final VoidCallback onChanged;
  final String hintText;
  final TextInputAction textInputAction;
  final int pickerFlex;
  final int inputFlex;
  final double height;
  final double? inputWidth;

  const SliderInputRow({
    super.key,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.suffix = '',
    this.hintText = '',
    this.pickerFlex = 6,
    this.inputFlex = 4,
    this.height = 38.0,
    this.inputWidth,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final inputWidget = SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        style: DarkInputBox.inputStyle.copyWith(fontSize: 13.5),
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: textInputAction,
        decoration: DarkInputBox.decoration(hintText: hintText).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
    );

    return Row(
      children: [
        // Left: QuickSliderPicker (default 60% flex)
        Expanded(
          flex: pickerFlex,
          child: SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: QuickSliderPicker.forController(
                controller: controller,
                options: options,
                suffix: suffix,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Right: Responsive input box (default 40% flex, or fixed if inputWidth specified)
        if (inputWidth != null)
          SizedBox(width: inputWidth, child: inputWidget)
        else
          Expanded(flex: inputFlex, child: inputWidget),
      ],
    );
  }
}
