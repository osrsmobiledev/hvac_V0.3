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
    if (!isCentral) {
      return Column(
        children: [
          CentraalTypeRow(
            isCentral: false,
            isSelected: false,
            prefix: 'B',
            typeLabel: AppDictionary.lblAsTypeB,
            suffix: AppDictionary.suffixOpen,
            hint: AppDictionary.hintSubtypeB,
            controller: typeBController,
            onSelect: () => onCentraalTypeChanged('B'),
            onCodeChanged: onTypeBCodeChanged,
          ),
          const SizedBox(height: 8),
          CentraalTypeRow(
            isCentral: false,
            isSelected: false,
            prefix: 'C',
            typeLabel: AppDictionary.lblAsTypeC,
            suffix: AppDictionary.suffixClosed,
            hint: AppDictionary.hintSubtypeC,
            controller: typeCController,
            onSelect: () => onCentraalTypeChanged('C'),
            onCodeChanged: onTypeCCodeChanged,
          ),
        ],
      );
    }

    return FormField<String>(
      initialValue: centraalType,
      validator: (_) => (isCentral && centraalType.isEmpty) ? '' : null,
      builder: (state) {
        final hasError = state.hasError && centraalType.isEmpty;
        return Column(
          children: [
            CentraalTypeRow(
              isCentral: isCentral,
              isSelected: centraalType == 'B',
              isError: hasError,
              prefix: 'B',
              typeLabel: AppDictionary.lblAsTypeB,
              suffix: AppDictionary.suffixOpen,
              hint: AppDictionary.hintSubtypeB,
              controller: typeBController,
              onSelect: () {
                onCentraalTypeChanged('B');
                state.didChange('B');
              },
              onCodeChanged: onTypeBCodeChanged,
            ),
            const SizedBox(height: 8),
            CentraalTypeRow(
              isCentral: isCentral,
              isSelected: centraalType == 'C',
              isError: hasError,
              prefix: 'C',
              typeLabel: AppDictionary.lblAsTypeC,
              suffix: AppDictionary.suffixClosed,
              hint: AppDictionary.hintSubtypeC,
              controller: typeCController,
              onSelect: () {
                onCentraalTypeChanged('C');
                state.didChange('C');
              },
              onCodeChanged: onTypeCCodeChanged,
            ),
          ],
        );
      },
    );
  }
}
