import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../core/widgets/tactical_dialog_window.dart';
import '../../../features/pdf_export/data/pdf_visit_data.dart';
import '../data/recipient_confirmation.dart';
import 'recipient_dialog_actions.dart';
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
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _copyTechnician =
        widget.defaultCopyTechnician && widget.technicianEmail.isNotEmpty;
    _sendCustomer = widget.snapshot.klantEmail.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
    final note = _noteController.text.trim();
    final effectiveCustomerSend = _sendCustomer && _hasCustomerEmail;
    final result = RecipientConfirmation(
      sendToCustomer: effectiveCustomerSend,
      customerEmail: _customerEmail,
      customerName: _customerName,
      sendToTechnician: _copyTechnician && _hasTechnicianEmail,
      technicianEmail: widget.technicianEmail,
      customNote: (effectiveCustomerSend && note.isNotEmpty) ? note : null,
    );
    Navigator.of(context).pop(RecipientDialogResult.queue(result));
  }

  void _onSkip() =>
      Navigator.of(context).pop(const RecipientDialogResult.skip());

  void _onCancel() =>
      Navigator.of(context).pop(const RecipientDialogResult.cancel());

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
        actions: RecipientDialogActions(
          canQueue: _canQueue,
          confirmActionLabel: _confirmActionLabel,
          onConfirm: _onConfirm,
          onCancel: _onCancel,
          onSkip: _onSkip,
        ),
        child: RecipientDialogContent(
          customerName: _customerName,
          customerEmail: _customerEmail,
          hasInitialCustomerEmail: _hasCustomerEmail,
          sendCustomer: _sendCustomer,
          onSendCustomerChanged: _hasCustomerEmail
              ? (val) {
                  final next = val ?? false;
                  setState(() {
                    _sendCustomer = next;
                    if (!next) {
                      _noteController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  });
                }
              : null,
          hasTechnicianEmail: _hasTechnicianEmail,
          technicianEmail: widget.technicianEmail,
          copyTechnician: _copyTechnician,
          onCopyTechnicianChanged: _hasTechnicianEmail
              ? (val) => setState(() => _copyTechnician = val ?? false)
              : null,
          noteController: _noteController,
        ),
      ),
    );
  }
}
