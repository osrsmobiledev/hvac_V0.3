import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_box.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';

/// Labeled dark input field helper used across Tab 4 (Klant) cards.
class KlantFormField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;

  const KlantFormField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixText,
    this.suffixIcon,
    this.readOnly = false,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarkInputLabel(label, isMuted: readOnly),
        TextFormField(
          key: fieldKey,
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: readOnly
              ? const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )
              : DarkInputBox.inputStyle,
          cursorColor:
              readOnly ? Colors.transparent : AppColors.amberGoldBorder,
          decoration: DarkInputBox.decoration(
            hintText: hint,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            readOnly: readOnly,
          ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
