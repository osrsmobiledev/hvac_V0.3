import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/veka_api_dictionary.dart';
import '../data/veka_api_attempt.dart';
import 'veka_api_details.dart';

class VekaApiHistoryDialog extends StatelessWidget {
  const VekaApiHistoryDialog({super.key, required this.attempts});

  final List<({VekaApiAttempt attempt, List<VekaApiDispatch> dispatches})>
      attempts;

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text(VekaApiDictionary.details),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(VekaApiDictionary.simulation),
            for (final entry in attempts)
              _AttemptDetails(entry.attempt, entry.dispatches),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppDictionary.btnOk),
          ),
        ],
      );
}

class _AttemptDetails extends StatelessWidget {
  const _AttemptDetails(this.attempt, this.dispatches);

  final VekaApiAttempt attempt;
  final List<VekaApiDispatch> dispatches;

  @override
  Widget build(BuildContext context) {
    final resolvedAt = attempt.resolvedAt;
    final reconciled = attempt.status == VekaApiStatus.accepted &&
        dispatches.isNotEmpty &&
        dispatches.first.status == VekaApiStatus.uncertain;
    return ExpansionTile(
      title: Text(vekaApiStatusLabel(attempt.status)),
      subtitle: Text(attempt.report.address),
      tilePadding: EdgeInsets.zero,
      children: [
        VekaApiAttemptSummary(attempt: attempt),
        VekaApiPayloadDetails(
          report: attempt.report,
          requestReference: attempt.requestReference,
          contractVersion: attempt.contractVersion,
          requestJson: attempt.requestJson,
        ),
        VekaApiValue(
          label: VekaApiDictionary.date,
          value: _formatDate(context, attempt.createdAt),
        ),
        if (reconciled) ...[
          const Text(VekaApiDictionary.reconciled),
          if (resolvedAt != null)
            VekaApiValue(
              label: VekaApiDictionary.resolved,
              value: _formatDate(context, resolvedAt),
            ),
          if (attempt.responseJson case final String json)
            VekaApiJson(label: VekaApiDictionary.responseJson, json: json),
        ],
        for (final dispatch in dispatches) _DispatchDetails(dispatch),
      ],
    );
  }
}

class _DispatchDetails extends StatelessWidget {
  const _DispatchDetails(this.dispatch);

  final VekaApiDispatch dispatch;

  @override
  Widget build(BuildContext context) {
    final responseStatus = dispatch.responseStatus;
    final responseJson = dispatch.responseJson;
    final finished = dispatch.finishedAt;
    return ExpansionTile(
      title: Text(VekaApiDictionary.dispatch(dispatch.number)),
      subtitle: Text(vekaApiStatusLabel(dispatch.status)),
      tilePadding: EdgeInsets.zero,
      children: [
        VekaApiValue(
          label: VekaApiDictionary.sent,
          value: _formatDate(context, dispatch.startedAt),
        ),
        if (finished != null)
          VekaApiValue(
            label: VekaApiDictionary.resolved,
            value: _formatDate(context, finished),
          ),
        if (responseStatus != null)
          VekaApiValue(
            label: VekaApiDictionary.responseCode,
            value: responseStatus.toString(),
          ),
        if (responseJson != null)
          VekaApiJson(
              label: VekaApiDictionary.responseJson, json: responseJson),
      ],
    );
  }
}

String _formatDate(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final strings = MaterialLocalizations.of(context);
  final time = strings.formatTimeOfDay(TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: true);
  return '${strings.formatShortDate(local)} $time';
}
