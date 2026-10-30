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
    required this.prefix,
    required this.typeLabel,
    required this.suffix,
    required this.hint,
    required this.controller,
    required this.onSelect,
    this.onCodeChanged,
  });

  void _openPicker(BuildContext context) {
    showNbnTypePickerModal(
      context: context,
      typeLetter: prefix,
      currentCode: controller.text,
      onSelected: (code) {
        controller.text = code;
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
        : Colors.white.withValues(alpha: 0.16);

    return Row(
      children: [
        // 1. Text button styled like Tab "Start" with 2-line layout
        Expanded(
          child: OutlinedButton(
            onPressed: isCentral
                ? () {
                    if (!isActive) {
                      HapticFeedback.selectionClick();
                      onSelect();
                    }
                  }
                : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              side: BorderSide(
                color: borderColor,
                width: isActive ? 1.5 : 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.amberGold
                          : Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    color: Colors.transparent,
                  ),
                  child: isActive
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.amberGold,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),

                // 2-line text column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppDictionary.lblConnected,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.65)
                              : const Color(0xFF6E6E6E),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$typeLabel $suffix',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF8E8E8E),
                            fontSize: 13.0,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Tactical NBN picker box (72dp: fits prefix and code cleanly without clipping)
        IgnorePointer(
          ignoring: !isCentral,
          child: SizedBox(
            width: 72,
            height: 48,
            child: InkWell(
              onTap: isActive ? () => _openPicker(context) : onSelect,
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                key: ValueKey('nbn_input_$prefix'),
                controller: controller,
                readOnly: true,
                onTap: isActive ? () => _openPicker(context) : onSelect,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
