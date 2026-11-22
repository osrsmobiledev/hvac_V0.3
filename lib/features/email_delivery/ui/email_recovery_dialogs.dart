import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../data/email_sender_service.dart';

/// Modal dialogs supporting error recovery and manual resolution in Historiek.
class EmailRecoveryDialogs {
  const EmailRecoveryDialogs._();

  /// Prompts technician for a corrected recipient email address.
  static Future<String?> showAddressCorrection(
    BuildContext context, {
    required String currentEmail,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _AddressCorrectionDialog(currentEmail: currentEmail),
    );
  }

  /// Prompts technician to confirm resending after an in-flight network timeout.
  static Future<bool> showUncertainRetryConfirmation(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(EmailDeliveryDictionary.uncertainRetryTitle),
        content: const Text(EmailDeliveryDictionary.uncertainRetryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(EmailDeliveryDictionary.uncertainRetryCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(EmailDeliveryDictionary.uncertainRetryConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Prompts technician for resolution notes when manually resolving a delivery issue.
  static Future<String?> showManualResolution(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const _ManualResolutionDialog(),
    );
  }
}

class _AddressCorrectionDialog extends StatefulWidget {
  final String currentEmail;

  const _AddressCorrectionDialog({required this.currentEmail});

  @override
  State<_AddressCorrectionDialog> createState() =>
      _AddressCorrectionDialogState();
}

class _AddressCorrectionDialogState extends State<_AddressCorrectionDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final trimmed = _controller.text.trim();
    if (!EmailSenderService.isFormatValidEmail(trimmed)) {
      setState(() {
        _errorText = EmailDeliveryDictionary.correctEmailInvalid;
      });
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(EmailDeliveryDictionary.correctEmailTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(EmailDeliveryDictionary.correctEmailPrompt),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: EmailDeliveryDictionary.correctEmailFieldLabel,
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(EmailDeliveryDictionary.correctEmailCancel),
        ),
        FilledButton(
          onPressed: _onConfirm,
          child: const Text(EmailDeliveryDictionary.correctEmailConfirm),
        ),
      ],
    );
  }
}

class _ManualResolutionDialog extends StatefulWidget {
  const _ManualResolutionDialog();

  @override
  State<_ManualResolutionDialog> createState() =>
      _ManualResolutionDialogState();
}

class _ManualResolutionDialogState extends State<_ManualResolutionDialog> {
  late final TextEditingController _controller;
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateCanConfirm);
  }

  void _updateCanConfirm() {
    final valid = _controller.text.trim().isNotEmpty;
    if (_canConfirm != valid) {
      setState(() => _canConfirm = valid);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanConfirm);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(EmailDeliveryDictionary.manualResolveTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(EmailDeliveryDictionary.manualResolveMessage),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: EmailDeliveryDictionary.manualResolveNotesLabel,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(EmailDeliveryDictionary.manualResolveCancel),
        ),
        FilledButton(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text(EmailDeliveryDictionary.manualResolveConfirm),
        ),
      ],
    );
  }
}
