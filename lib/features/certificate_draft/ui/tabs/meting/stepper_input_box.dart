import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/dark_input_box.dart';

/// Tactical [- inputbox +] stepper field with FormField validation and error styling.
class StepperInputBox extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final double height;
  final String hintText;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final VoidCallback onChanged;
  final VoidCallback? onNudgeDown;
  final VoidCallback? onNudgeUp;

  const StepperInputBox({
    super.key,
    required this.controller,
    required this.onChanged,
    this.width = 148.0,
    this.height = 36.0,
    this.hintText = '',
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onNudgeDown,
    this.onNudgeUp,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FormField<String>(
          validator: (_) => validator?.call(controller.text),
          builder: (fieldState) {
            final hasError = fieldState.hasError &&
                (validator?.call(controller.text) != null);
            final borderColor = hasError
                ? AppColors.errorRed
                : Colors.white.withValues(alpha: 0.18);

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: borderColor,
                  width: hasError ? 1.2 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  _stepperBtn(
                    icon: Icons.remove,
                    isLeft: true,
                    onTap: () {
                      onNudgeDown?.call();
                      fieldState.didChange(controller.text);
                    },
                  ),
                  _divider(),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: DarkInputBox.inputStyle.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: textInputAction,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                      ),
                      onChanged: (val) {
                        fieldState.didChange(val);
                        onChanged();
                      },
                    ),
                  ),
                  _divider(),
                  _stepperBtn(
                    icon: Icons.add,
                    isLeft: false,
                    onTap: () {
                      onNudgeUp?.call();
                      fieldState.didChange(controller.text);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepperBtn({
    required IconData icon,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isLeft ? 7.0 : 0.0),
          right: Radius.circular(isLeft ? 0.0 : 7.0),
        ),
        child: SizedBox(
          width: 36,
          height: height,
          child: Icon(icon, size: 16, color: AppColors.amberGold),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1.0,
      height: height - 16,
      color: Colors.white.withValues(alpha: 0.10),
    );
  }
}
