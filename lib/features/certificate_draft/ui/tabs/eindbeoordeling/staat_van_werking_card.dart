// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/staat_van_werking_card.dart
// Responsibility: Unified Bento card for appliance operating conclusions and next combustion inspection date.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_binary_check.dart';
import 'package:hvac_app/core/widgets/tactical_group_outline.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';
import 'volgende_controle_section.dart';

class StaatVanWerkingCard extends StatelessWidget {
  const StaatVanWerkingCard({
    super.key,
    required this.selectedGoed,
    required this.selectedVeilig,
    required this.selectedDate,
    required this.fuelType,
    this.visitDate,
    required this.onGoedChanged,
    required this.onVeiligChanged,
    required this.onDateChanged,
  });

  final String? selectedGoed;
  final String? selectedVeilig;
  final String? selectedDate;
  final String fuelType;
  final String? visitDate;
  final ValueChanged<String?> onGoedChanged;
  final ValueChanged<String?> onVeiligChanged;
  final ValueChanged<String> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: EindbeoordelingDictionary.cardTitleConclusie,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Toestelwerking Goed / Niet goed — required pre-flight field
          const DarkInputLabel(
              EindbeoordelingDictionary.headerHetStooktoestelWerkt),
          _ValidatedBinaryCheck(
            value: selectedGoed == null
                ? null
                : (selectedGoed == EindbeoordelingDictionary.optGoed),
            positiveLabel: EindbeoordelingDictionary.optGoed,
            negativeLabel: EindbeoordelingDictionary.optNietGoed,
            isAnswered: selectedGoed != null,
            onChanged: (val) {
              if (val == null) {
                onGoedChanged(null);
              } else {
                onGoedChanged(val
                    ? EindbeoordelingDictionary.optGoed
                    : EindbeoordelingDictionary.optNietGoed);
              }
            },
          ),
          const SizedBox(height: 12),

          // 2. Veiligheid verluchtingsopeningen & rookgasafvoer — required pre-flight field
          const DarkInputLabel(
              EindbeoordelingDictionary.lblVerluchtingRookgasafvoer),
          _ValidatedBinaryCheck(
            value: selectedVeilig == null
                ? null
                : (selectedVeilig == EindbeoordelingDictionary.optVeilig),
            positiveLabel: EindbeoordelingDictionary.optVeilig,
            negativeLabel: EindbeoordelingDictionary.optNietVeilig,
            isAnswered: selectedVeilig != null,
            onChanged: (val) {
              if (val == null) {
                onVeiligChanged(null);
              } else {
                onVeiligChanged(val
                    ? EindbeoordelingDictionary.optVeilig
                    : EindbeoordelingDictionary.optNietVeilig);
              }
            },
          ),
          const SizedBox(height: 16),

          // 3. Next combustion inspection section inside the same card
          VolgendeControleSection(
            selectedDate: selectedDate,
            fuelType: fuelType,
            visitDate: visitDate,
            onDateChanged: onDateChanged,
          ),
        ],
      ),
    );
  }
}

/// A required binary toggle wrapped in a [FormField<bool?>].
/// Shows a red border when no answer has been given (isAnswered is false).
class _ValidatedBinaryCheck extends StatelessWidget {
  final bool? value;
  final String positiveLabel;
  final String negativeLabel;
  final bool isAnswered;
  final ValueChanged<bool?> onChanged;

  const _ValidatedBinaryCheck({
    required this.value,
    required this.positiveLabel,
    required this.negativeLabel,
    required this.isAnswered,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool?>(
      initialValue: value,
      validator: (_) => !isAnswered ? '' : null,
      builder: (field) {
        final hasError = field.hasError && !isAnswered;
        return TacticalGroupOutline(
          hasError: hasError,
          child: TacticalBinaryCheck(
            value: value,
            positiveLabel: positiveLabel,
            negativeLabel: negativeLabel,
            onChanged: (val) {
              onChanged(val);
              field.didChange(val);
            },
          ),
        );
      },
    );
  }
}
