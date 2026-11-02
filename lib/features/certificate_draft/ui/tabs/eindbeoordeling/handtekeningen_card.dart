// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/handtekeningen_card.dart
// Responsibility: Digital signature bento card for technician and customer in BO2 Bento styling.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/signature_pad_modal.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'signature_tile.dart';

class HandtekeningenCard extends StatelessWidget {
  const HandtekeningenCard({
    super.key,
    required this.draft,
    required this.onDraftChanged,
  });

  final EindbeoordelingDraft draft;
  final ValueChanged<EindbeoordelingDraft> onDraftChanged;

  Future<void> _openSignatureModal(
    BuildContext context, {
    required String title,
    required ValueChanged<String> onSigned,
  }) async {
    final result = await SignaturePadModal.show(context, title: title);
    if (result != null && result.isNotEmpty) {
      onSigned(result);
    }
  }

  Future<void> _confirmClearSignature(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirmed,
  }) async {
    HapticFeedback.selectionClick();
    final confirmed = await TacticalConfirmDialog.show(
      context: context,
      title: title,
      content: EindbeoordelingDictionary.dlgClearSignatureBody,
      confirmLabel: EindbeoordelingDictionary.btnWissen,
      cancelLabel: AppDictionary.btnCancel,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      onConfirmed();
      TacticalFeedback.showInfo(
        context,
        EindbeoordelingDictionary.feedbackSignatureCleared,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: EindbeoordelingDictionary.cardTitleHandtekeningen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Handtekening technicus
          SignatureTile(
            label: EindbeoordelingDictionary.lblHandtekeningTechnicus,
            signatureData: draft.technicianSignaturePath,
            onTapSign: () => _openSignatureModal(
              context,
              title: EindbeoordelingDictionary.modalTitleTechnicianSignature,
              onSigned: (path) => onDraftChanged(
                draft.copyWith(technicianSignaturePath: path),
              ),
            ),
            onClear: () => _confirmClearSignature(
              context,
              title: EindbeoordelingDictionary.dlgClearTechnicianSignatureTitle,
              onConfirmed: () => onDraftChanged(
                draft.copyWith(clearTechnicianSignature: true),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Handtekening klant
          SignatureTile(
            label: EindbeoordelingDictionary.lblHandtekeningKlant,
            signatureData: draft.customerSignaturePath,
            onTapSign: () => _openSignatureModal(
              context,
              title: EindbeoordelingDictionary.modalTitleCustomerSignature,
              onSigned: (path) => onDraftChanged(
                draft.copyWith(customerSignaturePath: path),
              ),
            ),
            onClear: () => _confirmClearSignature(
              context,
              title: EindbeoordelingDictionary.dlgClearCustomerSignatureTitle,
              onConfirmed: () => onDraftChanged(
                draft.copyWith(clearCustomerSignature: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
