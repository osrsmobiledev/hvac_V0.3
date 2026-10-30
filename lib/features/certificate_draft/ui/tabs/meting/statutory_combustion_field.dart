import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../../domain/combustion_statutory_rules.dart';
import '../../widgets/dark_text_field.dart';
import 'tactical_binary_check.dart';

/// Statutory combustion input field with embedded norm text and [OK] / [NOK] switch.
///
/// Features:
/// - Reuses [DarkTextField] to guarantee 100% unified title alignment with other boxes.
/// - Dynamic terracotta warning triangle `(!)` [Icons.warning_rounded] when non-compliant.
/// - Statutory norm (e.g. `≤ 150 mg/kWh`) embedded inside the input box beside the button.
/// - Compact embedded [TacticalBinaryCheck] inside the field suffix for technician authority.
class StatutoryCombustionField extends StatelessWidget {
  final String label;
  final String? normLabel;
  final String? normText;
  final String hintText;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;
  final bool Function(double val)? isCompliant;
  final bool? checkValue;
  final ValueChanged<bool?>? onCheckChanged;

  const StatutoryCombustionField({
    super.key,
    required this.label,
    this.normLabel,
    this.normText,
    required this.hintText,
    required this.controller,
    required this.textInputAction,
    required this.onChanged,
    this.isCompliant,
    this.checkValue,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayNorm = normText ?? normLabel;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final val = CombustionStatutoryRules.parseNumeric(controller.text);
        final bool isFailed =
            val != null && isCompliant != null && !isCompliant!(val);
        final bool? effectiveCheck = checkValue ??
            (val != null && isCompliant != null ? isCompliant!(val) : null);

        return DarkTextField(
          label: label,
          controller: controller,
          hintText: hintText,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: textInputAction,
          prefixIcon: isFailed
              ? const Icon(
                  Icons.warning_rounded,
                  color: AppColors.terracotta,
                  size: 20.0,
                )
              : null,
          suffixText: displayNorm,
          suffixIcon: onCheckChanged != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: TacticalBinaryCheck(
                    value: effectiveCheck,
                    onChanged: onCheckChanged!,
                    isCompact: true,
                    useNokLabel: true,
                    width: 104.0,
                    height: 40.0,
                  ),
                )
              : null,
          onChanged: onChanged,
        );
      },
    );
  }
}
