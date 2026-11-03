// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/gebreken_opmerkingen_card.dart
// Responsibility: Multiline entry for defects, remarks, presets selector, and reactive clear buttons.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/domain/statutory_defect_preset.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';
import 'gebreken_action_buttons.dart';
import 'statutory_defects_modal.dart';

class GebrekenOpmerkingenCard extends StatelessWidget {
  const GebrekenOpmerkingenCard({
    super.key,
    required this.defectsController,
    required this.remarksController,
    required this.hasNegativeAssessment,
    required this.onChanged,
    this.fuelType = 'gas',
    this.boilerType = 'C',
  });

  final TextEditingController defectsController;
  final TextEditingController remarksController;
  final bool hasNegativeAssessment;
  final VoidCallback onChanged;
  final String fuelType;
  final String boilerType;

  void _openSnelselectie(BuildContext context) {
    HapticFeedback.selectionClick();
    StatutoryDefectsModal.show(
      context: context,
      fuelType: fuelType,
      boilerType: boilerType,
      onApply: (presets) => _applyPresets(context, presets),
    );
  }

  void _applyPresets(
      BuildContext context, List<StatutoryDefectPreset> presets) {
    if (presets.isEmpty) return;

    final existingDefects = defectsController.text.trim();
    final newDefects = presets.map((p) => '• ${p.defectText}').join('\n');
    defectsController.text =
        existingDefects.isEmpty ? newDefects : '$existingDefects\n$newDefects';

    final existingRemarks = remarksController.text.trim();
    final newMeasures = presets.map((p) => '• ${p.measureText}').join('\n');
    remarksController.text = existingRemarks.isEmpty
        ? newMeasures
        : '$existingRemarks\n$newMeasures';

    onChanged();
    TacticalFeedback.showSuccess(
      context,
      '${presets.length} ${EindbeoordelingDictionary.feedbackApplied}',
    );
  }

  Future<void> _confirmClear(
    BuildContext context, {
    required TextEditingController controller,
    required String title,
    required String message,
    required String feedback,
  }) async {
    HapticFeedback.selectionClick();
    final confirmed = await TacticalConfirmDialog.show(
      context: context,
      title: title,
      content: message,
      confirmLabel: EindbeoordelingDictionary.btnWissen,
      cancelLabel: AppDictionary.btnCancel,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      controller.clear();
      onChanged();
      TacticalFeedback.showInfo(context, feedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: EindbeoordelingDictionary.cardTitleGebreken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasNegativeAssessment) ...[
            const RemediationBanner(),
            const SizedBox(height: 14),
          ],

          // 1. Vastgestelde gebreken
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    EindbeoordelingDictionary.lblGebrekenNietWeggewerkt,
                    style: DarkInputLabel.style(),
                  ),
                ),
                const SizedBox(width: 8),
                SnelselectieButton(onTap: () => _openSnelselectie(context)),
              ],
            ),
          ),
          TacticalMultilineInput(
            controller: defectsController,
            hintText: EindbeoordelingDictionary.hintGebreken,
            onChanged: onChanged,
            onClear: () => _confirmClear(
              context,
              controller: defectsController,
              title: EindbeoordelingDictionary.dlgClearDefectsTitle,
              message: EindbeoordelingDictionary.dlgClearDefectsBody,
              feedback: EindbeoordelingDictionary.feedbackDefectsCleared,
            ),
          ),
          const SizedBox(height: 14),

          // 2. Andere opmerkingen
          const DarkInputLabel(EindbeoordelingDictionary.lblAndereOpmerkingen),
          TacticalMultilineInput(
            controller: remarksController,
            hintText: EindbeoordelingDictionary.hintOpmerkingen,
            onChanged: onChanged,
            onClear: () => _confirmClear(
              context,
              controller: remarksController,
              title: EindbeoordelingDictionary.dlgClearRemarksTitle,
              message: EindbeoordelingDictionary.dlgClearRemarksBody,
              feedback: EindbeoordelingDictionary.feedbackRemarksCleared,
            ),
          ),
        ],
      ),
    );
  }
}
