import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/dark_action_field.dart';
import '../../widgets/dark_text_form_field.dart';

/// Standard labeled text input field for the Firma - Technicus tab.
///
/// Reuses [DarkTextFormField] to guarantee zero-layout-shift red border validation
/// across all company and technician profile fields.
class FirmaField extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final VoidCallback onChanged;
  final ValueChanged<String>? onSubmitted;

  const FirmaField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return DarkTextFormField(
      fieldKey: fieldKey,
      label: label,
      controller: controller,
      hint: hint,
      prefixText: prefixText,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// Standard labeled action/picker field with trailing button for date/time.
class FirmaActionField extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final bool enabled;
  final bool showErrorText;

  const FirmaActionField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.textAlign = TextAlign.center,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.enabled = true,
    this.showErrorText = true,
  });

  @override
  Widget build(BuildContext context) {
    return DarkActionField(
      fieldKey: fieldKey,
      label: label,
      controller: controller,
      hint: hint,
      icon: icon,
      onTap: onTap,
      textAlign: textAlign,
      validator: validator,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      showErrorText: showErrorText,
    );
  }
}
