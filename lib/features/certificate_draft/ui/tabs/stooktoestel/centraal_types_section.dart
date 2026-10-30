import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'centraal_type_row.dart';

/// Renders the Centraal Type B & C connection fields with Tab "Start" button style
/// on the left and tactical NBN CR 1749 modal picker box on the right.
class CentraalTypesSection extends StatelessWidget {
  final bool isCentral;
  final String centraalType;
  final TextEditingController typeBController;
  final TextEditingController typeCController;
  final ValueChanged<String> onCentraalTypeChanged;
  final ValueChanged<String>? onTypeBCodeChanged;
  final ValueChanged<String>? onTypeCCodeChanged;

  const CentraalTypesSection({
    super.key,
    required this.isCentral,
    required this.centraalType,
    required this.typeBController,
    required this.typeCController,
    required this.onCentraalTypeChanged,
    this.onTypeBCodeChanged,
    this.onTypeCCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCentral
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Type B (open)
          CentraalTypeRow(
            isCentral: isCentral,
            isSelected: centraalType == 'B',
            prefix: 'B',
            typeLabel: AppDictionary.lblAsTypeB,
            suffix: AppDictionary.suffixOpen,
            hint: AppDictionary.hintSubtypeB,
            controller: typeBController,
            onSelect: () => onCentraalTypeChanged('B'),
            onCodeChanged: onTypeBCodeChanged,
          ),
          const SizedBox(height: 8),

          // Type C (gesloten)
          CentraalTypeRow(
            isCentral: isCentral,
            isSelected: centraalType == 'C',
            prefix: 'C',
            typeLabel: AppDictionary.lblAsTypeC,
            suffix: AppDictionary.suffixClosed,
            hint: AppDictionary.hintSubtypeC,
            controller: typeCController,
            onSelect: () => onCentraalTypeChanged('C'),
            onCodeChanged: onTypeCCodeChanged,
          ),
        ],
      ),
    );
  }
}
