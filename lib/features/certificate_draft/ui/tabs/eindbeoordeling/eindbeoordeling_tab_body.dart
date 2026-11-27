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
import 'reiniging_next_inspection_section.dart';
import 'staat_van_werking_card.dart';

class EindbeoordelingTabBody extends StatelessWidget {
  final EindbeoordelingDraft draft;
  final String certificateType;
  final String fuelType;
  final String visitDate;
  final String boilerType;
  final TextEditingController defectsController;
  final TextEditingController remarksController;
  final TextEditingController? remedialController;
  final ValueChanged<String?> onGoedChanged;
  final ValueChanged<String?> onVeiligChanged;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String>? onChimneyDateChanged;
  final ValueChanged<EindbeoordelingDraft> onDraftChanged;
  final VoidCallback onTextInputsChanged;
  final VoidCallback onTestPdfPressed;
  final VoidCallback onSaveDevicePressed;
  final VoidCallback onCompletePressed;

  const EindbeoordelingTabBody({
    super.key,
    required this.draft,
    this.certificateType = 'verbranding',
    required this.fuelType,
    required this.visitDate,
    required this.boilerType,
    required this.defectsController,
    required this.remarksController,
    this.remedialController,
    required this.onGoedChanged,
    required this.onVeiligChanged,
    required this.onDateChanged,
    this.onChimneyDateChanged,
    required this.onDraftChanged,
    required this.onTextInputsChanged,
    required this.onTestPdfPressed,
    required this.onSaveDevicePressed,
    required this.onCompletePressed,
    this.reporting,
  });

  final Widget? reporting;

  @override
  Widget build(BuildContext context) {
    final isReiniging = certificateType == 'reiniging';

    return WorkflowTabContainer(
      scrollKey: 'eindbeoordeling_tab_scroll',
      children: [
        // Bento Card 1: Staat van werking (Verbranding) or Next Inspection Dates (Reiniging)
        if (isReiniging)
          ReinigingNextInspectionSection(
            nextBoilerDate: draft.nextInspectionDate,
            nextChimneyDate: draft.nextChimneyInspectionDate,
            visitDate: visitDate,
            onBoilerDateChanged: onDateChanged,
            onChimneyDateChanged: onChimneyDateChanged ?? (_) {},
          )
        else
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
          remedialController: isReiniging ? remedialController : null,
          hasNegativeAssessment: !isReiniging && draft.hasNegativeAssessment,
          fuelType: fuelType,
          boilerType: boilerType,
          onChanged: onTextInputsChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),

        // Bento Card 3: Handtekeningen
        HandtekeningenCard(
          draft: draft,
          certificateType: certificateType,
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
          label: isReiniging
              ? EindbeoordelingDictionary.btnVoltooienReiniging
              : EindbeoordelingDictionary.btnVoltooien,
          onPressed: onCompletePressed,
        ),
        if (!isReiniging && reporting != null) ...[
          const SizedBox(height: AppTheme.bentoCardSpacing),
          reporting!,
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
