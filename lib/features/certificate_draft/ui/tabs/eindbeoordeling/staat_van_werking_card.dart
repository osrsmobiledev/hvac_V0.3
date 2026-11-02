// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/staat_van_werking_card.dart
// Responsibility: Unified Bento card for appliance operating conclusions and next combustion inspection date.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_binary_check.dart';
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
          // 1. Conclusion toggles
          const DarkInputLabel(
            EindbeoordelingDictionary.headerHetStooktoestelWerkt,
          ),
          TacticalBinaryCheck(
            value: selectedGoed == null
                ? null
                : (selectedGoed == EindbeoordelingDictionary.optGoed),
            positiveLabel: EindbeoordelingDictionary.optGoed,
            negativeLabel: EindbeoordelingDictionary.optNietGoed,
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
          const SizedBox(height: 8),
          TacticalBinaryCheck(
            value: selectedVeilig == null
                ? null
                : (selectedVeilig == EindbeoordelingDictionary.optVeilig),
            positiveLabel: EindbeoordelingDictionary.optVeilig,
            negativeLabel: EindbeoordelingDictionary.optNietVeilig,
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

          // 2. Comfortable spacing between conclusions and next inspection
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
