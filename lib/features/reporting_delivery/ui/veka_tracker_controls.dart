import 'package:flutter/material.dart';

import '../../../app/localization/veka_api_dictionary.dart';
import '../../../app/localization/veka_dictionary.dart';
import '../data/veka_api_attempt.dart';
import '../data/veka_report.dart';
import 'veka_api_details.dart';

class VekaTrackerControls extends StatelessWidget {
  const VekaTrackerControls({
    super.key,
    required this.record,
    required this.archived,
    required this.apiAttempt,
    required this.simulation,
    required this.portalAvailable,
    required this.current,
    required this.open,
    required this.saved,
    required this.reopen,
    required this.replace,
    required this.confirm,
    required this.review,
    required this.history,
    required this.verify,
  });

  final VekaRecord record;
  final bool archived;
  final VekaApiAttempt? apiAttempt;
  final bool simulation;
  final bool portalAvailable;
  final VoidCallback? current;
  final VoidCallback? open;
  final VoidCallback? saved;
  final VoidCallback? reopen;
  final VoidCallback? replace;
  final VoidCallback? confirm;
  final VoidCallback? review;
  final VoidCallback? history;
  final VoidCallback? verify;

  @override
  Widget build(BuildContext context) {
    final attempt = apiAttempt;
    final archivedRejection = archived && attempt?.allowsNewAttempt == true;
    final apiCanStart = simulation &&
        record.report == null &&
        (attempt?.allowsNewAttempt ?? true) &&
        (!archivedRejection || attempt!.canCorrectActivityDate);
    final portalCanStart = portalAvailable && record.report == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (attempt != null && record.report == null)
          VekaApiAttemptSummary(attempt: attempt),
        if (archivedRejection &&
            !attempt!.canCorrectActivityDate &&
            record.report == null)
          const Text(VekaApiDictionary.unsupportedArchivedCorrection),
        if (apiCanStart)
          FilledButton(
            onPressed: review,
            child: Text(attempt == null
                ? VekaApiDictionary.start
                : archivedRejection
                    ? VekaApiDictionary.correctDate
                    : VekaApiDictionary.corrected),
          ),
        if (attempt?.status == VekaApiStatus.uncertain ||
            (simulation &&
                record.report == null &&
                attempt?.status == VekaApiStatus.technical))
          FilledButton(
            onPressed: verify,
            child: Text(attempt?.status == VekaApiStatus.technical
                ? VekaApiDictionary.accessRetry
                : VekaApiDictionary.verify),
          ),
        if (attempt != null)
          OutlinedButton(
            onPressed: history,
            child: const Text(VekaApiDictionary.details),
          ),
        OutlinedButton(
          onPressed: current,
          child: const Text(VekaDictionary.current),
        ),
        if (portalCanStart)
          if (apiCanStart || attempt?.status == VekaApiStatus.technical)
            OutlinedButton(
              onPressed: open,
              child: const Text(VekaDictionary.open),
            )
          else
            FilledButton(
              onPressed: open,
              child: const Text(VekaDictionary.open),
            ),
        if (record.report != null)
          OutlinedButton(
            onPressed: saved,
            child: const Text(VekaDictionary.saved),
          ),
        if (record.report != null && !record.confirmed && portalAvailable) ...[
          OutlinedButton(
            onPressed: reopen,
            child: const Text(VekaDictionary.reopen),
          ),
          TextButton(
            onPressed: replace,
            child: const Text(VekaDictionary.replace),
          ),
          FilledButton(
            onPressed: confirm,
            child: const Text(VekaDictionary.confirm),
          ),
          if (simulation) const Text(VekaApiDictionary.manualOpen),
        ],
        if (simulation && record.confirmed)
          const Text(VekaApiDictionary.manualConfirmed),
      ],
    );
  }
}
