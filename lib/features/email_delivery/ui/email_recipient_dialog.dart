import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../features/pdf_export/data/pdf_visit_data.dart';
import '../data/recipient_confirmation.dart';

export '../data/recipient_confirmation.dart';

/// Shows a Flemish recipient confirmation dialog.
///
/// The technician sees the customer's email and optionally a technician copy,
/// pre-populated from the frozen certificate snapshot and SMTP settings.
/// Returns a [RecipientConfirmation] if the technician confirms, or null if
/// they cancel (the archived PDF is kept, but no email jobs are created).
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

  /// Shows the dialog and returns the confirmed [RecipientConfirmation],
  /// or null if the technician taps "Overslaan".
  static Future<RecipientConfirmation?> show(
    BuildContext context, {
    required PdfVisitData snapshot,
    required bool defaultCopyTechnician,
    required String technicianEmail,
  }) {
    return showDialog<RecipientConfirmation>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailRecipientDialog(
        snapshot: snapshot,
        defaultCopyTechnician: defaultCopyTechnician,
        technicianEmail: technicianEmail,
      ),
    );
  }

  @override
  State<EmailRecipientDialog> createState() => _EmailRecipientDialogState();
}

class _EmailRecipientDialogState extends State<EmailRecipientDialog> {
  late bool _copyTechnician;

  @override
  void initState() {
    super.initState();
    // Default technician copy from SMTP settings; only shown when
    // a technician email address is available.
    _copyTechnician =
        widget.defaultCopyTechnician && widget.technicianEmail.isNotEmpty;
  }

  String get _customerEmail => widget.snapshot.klantEmail.trim();
  String get _customerName {
    final parts = [
      widget.snapshot.klantVoornaam.trim(),
      widget.snapshot.klantAchternaam.trim(),
    ].where((p) => p.isNotEmpty);
    return parts.isNotEmpty
        ? parts.join(' ')
        : widget.snapshot.klantNaam.trim();
  }

  bool get _hasCustomerEmail => _customerEmail.isNotEmpty;
  bool get _hasTechnicianEmail => widget.technicianEmail.isNotEmpty;

  void _onConfirm() {
    final result = RecipientConfirmation(
      sendToCustomer: _hasCustomerEmail,
      customerEmail: _customerEmail,
      customerName: _customerName,
      sendToTechnician: _copyTechnician && _hasTechnicianEmail,
      technicianEmail: widget.technicianEmail,
    );
    Navigator.of(context).pop(result);
  }

  void _onCancel() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(EmailDeliveryDictionary.recipientDialogTitle),
      content: _DialogContent(
        customerName: _customerName,
        customerEmail: _customerEmail,
        hasCustomerEmail: _hasCustomerEmail,
        hasTechnicianEmail: _hasTechnicianEmail,
        technicianEmail: widget.technicianEmail,
        copyTechnician: _copyTechnician,
        onCopyTechnicianChanged: _hasTechnicianEmail
            ? (val) => setState(() => _copyTechnician = val ?? false)
            : null,
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text(EmailDeliveryDictionary.recipientDialogCancel),
        ),
        FilledButton(
          onPressed:
              _hasCustomerEmail || (_copyTechnician && _hasTechnicianEmail)
                  ? _onConfirm
                  : null,
          child: const Text(EmailDeliveryDictionary.recipientDialogConfirm),
        ),
      ],
    );
  }
}

/// Pure layout widget; keeps [_EmailRecipientDialogState.build] under 250 lines.
class _DialogContent extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  final bool hasCustomerEmail;
  final bool hasTechnicianEmail;
  final String technicianEmail;
  final bool copyTechnician;
  final ValueChanged<bool?>? onCopyTechnicianChanged;

  const _DialogContent({
    required this.customerName,
    required this.customerEmail,
    required this.hasCustomerEmail,
    required this.hasTechnicianEmail,
    required this.technicianEmail,
    required this.copyTechnician,
    required this.onCopyTechnicianChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EmailDeliveryDictionary.recipientDialogIntro,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),

        // Customer recipient row
        _RecipientRow(
          label: EmailDeliveryDictionary.recipientCustomerLabel,
          name: customerName,
          email: hasCustomerEmail
              ? customerEmail
              : EmailDeliveryDictionary.recipientNoCustomerEmail,
          isAvailable: hasCustomerEmail,
        ),

        // Technician copy checkbox row (only shown if email is available)
        if (hasTechnicianEmail) ...[
          const SizedBox(height: 8),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(EmailDeliveryDictionary.recipientTechnicianLabel),
            subtitle: Text(
              technicianEmail,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: copyTechnician,
            onChanged: onCopyTechnicianChanged,
          ),
        ],

        // Warn if neither recipient is available
        if (!hasCustomerEmail && !hasTechnicianEmail) ...[
          const SizedBox(height: 8),
          Text(
            EmailDeliveryDictionary.recipientNoneAvailable,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

/// Displays a single recipient row with label, name and email.
class _RecipientRow extends StatelessWidget {
  final String label;
  final String name;
  final String email;
  final bool isAvailable;

  const _RecipientRow({
    required this.label,
    required this.name,
    required this.email,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (name.isNotEmpty)
            Text(name, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isAvailable ? null : Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ),
    );
  }
}
