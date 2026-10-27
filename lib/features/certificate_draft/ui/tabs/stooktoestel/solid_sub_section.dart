import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/dark_input_box.dart';
import 'fuel_option_tiles.dart';

/// Unboxed sub-section for solid fuel selection (Pellets, Logs, Other).
class SolidSubSection extends StatelessWidget {
  final String selectedSubtype;
  final String otherText;
  final ValueChanged<String> onSubtypeChanged;
  final ValueChanged<String> onOtherTextChanged;

  const SolidSubSection({
    super.key,
    required this.selectedSubtype,
    required this.otherText,
    required this.onSubtypeChanged,
    required this.onOtherTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppDictionary.headerSolidSubtype,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.solidPellets,
                isSelected: selectedSubtype == 'houtpellets',
                onTap: () => onSubtypeChanged('houtpellets'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.solidLogs,
                isSelected: selectedSubtype == 'houtblokken',
                onTap: () => onSubtypeChanged('houtblokken'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TacticalOptionChip(
                label: AppDictionary.solidOther,
                isSelected: selectedSubtype == 'andere',
                onTap: () => onSubtypeChanged('andere'),
              ),
            ),
          ],
        ),
        if (selectedSubtype == 'andere') ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: otherText,
            style: DarkInputBox.inputStyle,
            decoration: DarkInputBox.decoration(
              hintText: AppDictionary.hintSpecifySolid,
            ),
            onChanged: onOtherTextChanged,
          ),
        ],
      ],
    );
  }
}
