import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../core/widgets/tactical_dialog_button.dart';
import '../../../core/widgets/tactical_dialog_window.dart';
import '../../../features/pdf_export/data/pdf_visit_data.dart';
import '../data/recipient_confirmation.dart';
import 'recipient_dialog_content.dart';

export '../data/recipient_confirmation.dart';

/// Flemish recipient confirmation dialog presented upon visit finalization.
///
/// Features:
/// - Shares the exact BO2 Tactical HUD styling as the Basisregisters dialog:
///   dark charcoal glass surface, glowing laser divider, and tactile buttons.
/// - Reads customer email and phone directly from Tab 4 snapshot.
/// - Dynamic action labeling ('Voltooien & E-mailen' vs 'Kopie naar technicus').
/// - Explicit 3-way actions: 'Annuleren' (abort & keep draft),
///   'Alleen bewaren' (finalize without emailing), and primary send action.
/// - Intercepts hardware Back gesture and close button to cancel safely.
class EmailRecipientDialog extends StatefulWidget {
  final PdfVisitData snapshot;
  final bool defaultCopyTechnician;
  final String technicianEmail;

  const EmailRecipientDialog({
    super.key,
    required this.snapshot,
    required this.defaultCopyTechnician,
    required this.technicianEmail,
  });

  /// Shows the dialog using [showTacticalDialog] and returns a [RecipientDialogResult].
  static Future<RecipientDialogResult> show(
    BuildContext context, {
    required PdfVisitData snapshot,
    required bool defaultCopyTechnician,
    required String technicianEmail,
  }) async {
    final result = await showTacticalDialog<RecipientDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailRecipientDialog(
        snapshot: snapshot,
        defaultCopyTechnician: defaultCopyTechnician,
        technicianEmail: technicianEmail,
      ),
    );
    return result ?? const RecipientDialogResult.cancel();
  }

  @override
  State<EmailRecipientDialog> createState() => _EmailRecipientDialogState();
}

class _EmailRecipientDialogState extends State<EmailRecipientDialog> {
  late bool _copyTechnician;
  late bool _sendCustomer;

  @override
  void initState() {
    super.initState();
    _copyTechnician =
        widget.defaultCopyTechnician && widget.technicianEmail.isNotEmpty;
    _sendCustomer = widget.snapshot.klantEmail.trim().isNotEmpty;
  }

  String get _customerEmail => widget.snapshot.klantEmail.trim();
  bool get _hasCustomerEmail => _customerEmail.isNotEmpty;
  bool get _hasTechnicianEmail => widget.technicianEmail.isNotEmpty;

  String get _customerName {
    final parts = [
      widget.snapshot.klantVoornaam.trim(),
      widget.snapshot.klantAchternaam.trim(),
    ].where((p) => p.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    if (widget.snapshot.klantNaam.trim().isNotEmpty) {
      return widget.snapshot.klantNaam.trim();
    }
    if (widget.snapshot.klantBedrijf.trim().isNotEmpty) {
      return widget.snapshot.klantBedrijf.trim();
    }
    return '';
  }

  bool get _canQueue =>
      (_sendCustomer && _hasCustomerEmail) ||
      (_copyTechnician && _hasTechnicianEmail);

  String get _confirmActionLabel {
    if (_sendCustomer && _hasCustomerEmail) {
      return EmailDeliveryDictionary.finalizeAndEmailAction;
    }
    if (_copyTechnician && _hasTechnicianEmail) {
      return EmailDeliveryDictionary.finalizeTechnicianCopyOnlyAction;
    }
    return EmailDeliveryDictionary.finalizeAndEmailAction;
  }

  void _onConfirm() {
    final result = RecipientConfirmation(
      sendToCustomer: _sendCustomer && _hasCustomerEmail,
      customerEmail: _customerEmail,
      customerName: _customerName,
      sendToTechnician: _copyTechnician && _hasTechnicianEmail,
      technicianEmail: widget.technicianEmail,
    );
    Navigator.of(context).pop(RecipientDialogResult.queue(result));
  }

  void _onSkip() =>
      Navigator.of(context).pop(const RecipientDialogResult.skip());

  void _onCancel() =>
      Navigator.of(context).pop(const RecipientDialogResult.cancel());

  Widget _buildActions() {
    if (_canQueue) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TacticalDialogButton.primary(
              label: _confirmActionLabel,
              onPressed: _onConfirm,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TacticalDialogButton.secondary(
                    label: EmailDeliveryDictionary.recipientDialogAbort,
                    onPressed: _onCancel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TacticalDialogButton.secondary(
                    label: EmailDeliveryDictionary.finalizeOnlySaveAction,
                    onPressed: _onSkip,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TacticalDialogButton.secondary(
              label: EmailDeliveryDictionary.recipientDialogAbort,
              onPressed: _onCancel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TacticalDialogButton.primary(
              label: EmailDeliveryDictionary.finalizeOnlySaveAction,
              onPressed: _onSkip,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onCancel();
      },
      child: TacticalDialogWindow(
        title: EmailDeliveryDictionary.recipientDialogTitle,
        maxWidth: 440,
        maxHeight: 580,
        onClose: _onCancel,
        actions: _buildActions(),
        child: RecipientDialogContent(
          customerName: _customerName,
          customerEmail: _customerEmail,
          hasInitialCustomerEmail: _hasCustomerEmail,
          sendCustomer: _sendCustomer,
          onSendCustomerChanged: _hasCustomerEmail
              ? (val) => setState(() => _sendCustomer = val ?? false)
              : null,
          hasTechnicianEmail: _hasTechnicianEmail,
          technicianEmail: widget.technicianEmail,
          copyTechnician: _copyTechnician,
          onCopyTechnicianChanged: _hasTechnicianEmail
              ? (val) => setState(() => _copyTechnician = val ?? false)
              : null,
        ),
      ),
    );
  }
}
