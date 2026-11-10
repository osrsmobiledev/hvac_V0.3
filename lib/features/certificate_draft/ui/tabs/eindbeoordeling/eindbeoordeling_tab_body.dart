// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/eindbeoordeling_tab_body.dart
// Responsibility: Pure UI layout for Tab 7 (Eindbeoordeling) cards and completion action.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'gebreken_opmerkingen_card.dart';
import 'handtekeningen_card.dart';
import 'staat_van_werking_card.dart';

class EindbeoordelingTabBody extends StatelessWidget {
  final EindbeoordelingDraft draft;
  final String fuelType;
  final String visitDate;
  final String boilerType;
  final TextEditingController defectsController;
  final TextEditingController remarksController;
  final ValueChanged<String?> onGoedChanged;
  final ValueChanged<String?> onVeiligChanged;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<EindbeoordelingDraft> onDraftChanged;
  final VoidCallback onTextInputsChanged;
  final VoidCallback onTestPdfPressed;
  final VoidCallback onSaveDevicePressed;
  final VoidCallback onCompletePressed;

  const EindbeoordelingTabBody({
    super.key,
    required this.draft,
    required this.fuelType,
    required this.visitDate,
    required this.boilerType,
    required this.defectsController,
    required this.remarksController,
    required this.onGoedChanged,
    required this.onVeiligChanged,
    required this.onDateChanged,
    required this.onDraftChanged,
    required this.onTextInputsChanged,
    required this.onTestPdfPressed,
    required this.onSaveDevicePressed,
    required this.onCompletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return WorkflowTabContainer(
      scrollKey: 'eindbeoordeling_tab_scroll',
      children: [
        // Bento Card 1: Staat van werking & Veiligheid
        StaatVanWerkingCard(
          selectedGoed: draft.toestelWerkingGoed,
          selectedVeilig: draft.toestelWerkingVeilig,
          selectedDate: draft.nextInspectionDate,
          fuelType: fuelType,
          visitDate: visitDate,
          onGoedChanged: onGoedChanged,
          onVeiligChanged: onVeiligChanged,
          onDateChanged: onDateChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),

        // Bento Card 2: Gebreken & Opmerkingen
        GebrekenOpmerkingenCard(
          defectsController: defectsController,
          remarksController: remarksController,
          hasNegativeAssessment: draft.hasNegativeAssessment,
          fuelType: fuelType,
          boilerType: boilerType,
          onChanged: onTextInputsChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),

        // Bento Card 3: Handtekeningen
        HandtekeningenCard(
          draft: draft,
          onDraftChanged: onDraftChanged,
        ),
        const SizedBox(height: 24),

        // Tactical Actions: Test-PDF Preview, Save-Device & Formal Completion
        TacticalDialogButton.secondary(
          label: EindbeoordelingDictionary.btnTestPdf,
          onPressed: onTestPdfPressed,
        ),
        const SizedBox(height: 10),
        TacticalDialogButton.secondary(
          label: EindbeoordelingDictionary.btnSaveDevice,
          onPressed: onSaveDevicePressed,
        ),
        const SizedBox(height: 12),
        TacticalDialogButton.primary(
          label: EindbeoordelingDictionary.btnVoltooien,
          onPressed: onCompletePressed,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
