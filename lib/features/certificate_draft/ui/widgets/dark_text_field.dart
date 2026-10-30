import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'dark_input_box.dart';
import 'dark_input_label.dart';

/// Reusable dark text form field with integrated label, prefix, and suffix slots.
///
/// Ensures unified title alignment across all workflow tabs and bento cards.
/// Supports embedding statutory norm text and tactical action buttons (e.g. [OK | NOK]).
class DarkTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? unit;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool readOnly;
  final VoidCallback? onChanged;

  const DarkTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.unit,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasExplicitSuffix =
        (suffixText != null && suffixText!.isNotEmpty) || suffixIcon != null;

    Widget? effectiveSuffixIcon;
    if (hasExplicitSuffix) {
      effectiveSuffixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suffixText != null && suffixText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                suffixText!,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.antiqueGold,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          if (suffixIcon != null) suffixIcon!,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DarkInputLabel(label, isMuted: readOnly),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: readOnly
              ? DarkInputBox.inputStyle.copyWith(color: Colors.white60)
              : DarkInputBox.inputStyle,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: [
            if (unit != null && unit!.isNotEmpty) UnitSuffixFormatter(unit!),
          ],
          decoration: DarkInputBox.decoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            suffixIcon: effectiveSuffixIcon,
            readOnly: readOnly,
          ),
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}

/// Standard input formatter that cleanly appends a unit suffix (e.g. ` %` or ` °C`)
/// directly inside the text, keeping the cursor right after the number.
class UnitSuffixFormatter extends TextInputFormatter {
  final String unit;

  const UnitSuffixFormatter(this.unit);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText =
        newValue.text.replaceAll(' $unit', '').replaceAll(unit, '').trim();

    if (rawText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = '$rawText $unit';
    final targetOffset = rawText.length.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: targetOffset),
    );
  }
}
