import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_text_form_field.dart';

/// Labeled dark input field helper used across Tab 4 (Klant) cards.
///
/// Reuses [DarkTextFormField] to guarantee zero-layout-shift red border validation
/// across all customer details and installation address inputs.
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
    return DarkTextFormField(
      fieldKey: fieldKey,
      controller: controller,
      label: label,
      hint: hint,
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}
