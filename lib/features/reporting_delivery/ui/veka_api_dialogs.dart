import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/veka_api_dictionary.dart';
import '../data/veka_api_attempt.dart';
import '../data/veka_api_transport.dart';
import 'veka_api_details.dart';

class VekaApiReviewDialog extends StatefulWidget {
  const VekaApiReviewDialog({
    super.key,
    required this.details,
    this.retry = false,
    this.accessRestored = false,
    this.correction = false,
  });

  final VekaApiPayloadDetails details;
  final bool retry;
  final bool accessRestored;
  final bool correction;

  @override
  State<VekaApiReviewDialog> createState() => _VekaApiReviewDialogState();
}

class _VekaApiReviewDialogState extends State<VekaApiReviewDialog> {
  VekaMockOutcome _outcome = VekaMockOutcome.accepted;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.retry
          ? VekaApiDictionary.retryReview
          : VekaApiDictionary.review),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(VekaApiDictionary.simulation),
          if (widget.correction)
            const Text(VekaApiDictionary.archivedCorrectionHint),
          Text(widget.accessRestored
              ? VekaApiDictionary.accessRetryHint
              : widget.retry
                  ? VekaApiDictionary.retryHint
                  : VekaApiDictionary.reviewHint),
          widget.details,
          DropdownButtonFormField<VekaMockOutcome>(
            isExpanded: true,
            initialValue: _outcome,
            decoration:
                const InputDecoration(labelText: VekaApiDictionary.outcome),
            items: const [
              DropdownMenuItem(
                value: VekaMockOutcome.accepted,
                child: Text(VekaApiDictionary.acceptOutcome),
              ),
              DropdownMenuItem(
                value: VekaMockOutcome.rejected,
                child: Text(VekaApiDictionary.rejectOutcome),
              ),
              DropdownMenuItem(
                value: VekaMockOutcome.technical,
                child: Text(VekaApiDictionary.technicalOutcome),
              ),
              DropdownMenuItem(
                value: VekaMockOutcome.uncertain,
                child: Text(VekaApiDictionary.uncertainOutcome),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _outcome = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppDictionary.btnCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _outcome),
          child: Text(widget.retry && !widget.accessRestored
              ? VekaApiDictionary.retry
              : VekaApiDictionary.submit),
        ),
      ],
    );
  }
}

enum VekaApiVerification { found, absent }

class VekaApiVerificationDialog extends StatelessWidget {
  const VekaApiVerificationDialog({super.key, required this.attempt});

  final VekaApiAttempt attempt;

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text(VekaApiDictionary.verify),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(VekaApiDictionary.simulation),
            const Text(VekaApiDictionary.verificationHint),
            VekaApiValue(
              label: VekaApiDictionary.address,
              value: attempt.report.address,
            ),
            VekaApiValue(
              label: VekaApiDictionary.reference,
              value: attempt.requestReference,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppDictionary.btnCancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, VekaApiVerification.absent),
            child: const Text(VekaApiDictionary.retryReview),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, VekaApiVerification.found),
            child: const Text(VekaApiDictionary.reconcile),
          ),
        ],
      );
}
