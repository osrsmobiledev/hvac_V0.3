import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_box.dart';

/// Labeled dark input field helper used across Tab 4 (Klant) cards.
class KlantFormField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefixText;
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: DarkInputBox.inputStyle,
          cursorColor: AppColors.amberGold,
          decoration: DarkInputBox.decoration(
            hintText: hint,
            prefixText: prefixText,
          ),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
