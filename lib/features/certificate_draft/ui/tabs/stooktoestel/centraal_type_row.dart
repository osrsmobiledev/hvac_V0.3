import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/dark_input_box.dart';
import 'nbn_type_picker_modal.dart';

/// A single row with a selection button on the left and NBN picker box on the right.
class CentraalTypeRow extends StatelessWidget {
  final bool isCentral;
  final bool isSelected;
  final bool isError;
  final String prefix;
  final String typeLabel;
  final String suffix;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSelect;
  final ValueChanged<String>? onCodeChanged;

  const CentraalTypeRow({
    super.key,
    required this.isCentral,
    required this.isSelected,
    this.isError = false,
    required this.prefix,
    required this.typeLabel,
    required this.suffix,
    required this.hint,
    required this.controller,
    required this.onSelect,
    this.onCodeChanged,
  });

  void _openPicker(BuildContext context, [FormFieldState<String>? fieldState]) {
    showNbnTypePickerModal(
      context: context,
      typeLetter: prefix,
      currentCode: controller.text,
      onSelected: (code) {
        controller.text = code;
        fieldState?.didChange(code);
        onCodeChanged?.call(code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = isCentral && isSelected;

    final backgroundColor = isActive
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.08),
            const Color(0xFF141414),
          )
        : const Color(0xFF0C0C0C);

    final borderColor = isActive
        ? AppColors.amberGoldBorder
        : (isCentral && isError
            ? AppColors.errorRed
            : Colors.white.withValues(alpha: 0.16));

    final borderWidth = (isActive || (isCentral && isError)) ? 1.4 : 1.0;

    return Row(
      children: [
        // 1. Text button styled like Tab "Start" with 2-line layout
        Expanded(
          child: OutlinedButton(
            focusNode: FocusNode(canRequestFocus: false, skipTraversal: true),
            onPressed: () {
              HapticFeedback.selectionClick();
              onSelect();
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              side: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6.0,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${AppDictionary.lblConnected} $typeLabel $suffix',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                    fontSize: 13.0,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Tactical NBN picker box (72dp: fits prefix and code cleanly without clipping)
        SizedBox(
          width: 72,
          height: 48,
          child: FormField<String>(
            initialValue: controller.text,
            validator: (_) {
              if (isActive && controller.text.trim().isEmpty) return '';
              return null;
            },
            builder: (boxState) {
              final isBoxError = boxState.hasError &&
                  isActive &&
                  controller.text.trim().isEmpty;
              return InkWell(
                onTap: () {
                  if (isActive) {
                    _openPicker(context, boxState);
                  } else {
                    onSelect();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: TextField(
                  key: ValueKey('nbn_input_$prefix'),
                  controller: controller,
                  readOnly: true,
                  onTap: () {
                    if (isActive) {
                      _openPicker(context, boxState);
                    } else {
                      onSelect();
                    }
                  },
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                  decoration: DarkInputBox.decoration(
                    prefixText: prefix,
                    hintText: hint,
                    readOnly: !isActive,
                    isError: isBoxError,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    fontSize: 15,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
