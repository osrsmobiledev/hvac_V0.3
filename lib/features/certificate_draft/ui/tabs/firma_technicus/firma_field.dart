import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/dark_input_box.dart';

/// Standard labeled text input field for the Firma - Technicus tab.
class FirmaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;

  const FirmaField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: (_) => onChanged(),
          validator: validator,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style: DarkInputBox.inputStyle,
          cursorColor: AppColors.amberGold,
          decoration: DarkInputBox.decoration(
            hintText: hint,
            prefixText: prefixText,
          ),
        ),
      ],
    );
  }
}

/// Standard labeled action/picker field with trailing button for date/time.
class FirmaActionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const FirmaActionField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: DarkInputBox.inputStyle,
          decoration: DarkInputBox.decoration(hintText: hint).copyWith(
            suffixIcon: IconButton(
              icon: Icon(icon, color: AppColors.amberGold, size: 20),
              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
