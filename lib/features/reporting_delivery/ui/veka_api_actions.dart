import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/veka_api_dictionary.dart';
import '../../../app/localization/veka_dictionary.dart';
import '../../certificate_draft/ui/draft_save_scope.dart';
import '../data/veka_api_attempt.dart';
import '../data/veka_api_payload.dart';
import '../data/veka_api_repository.dart';
import '../data/veka_api_transport.dart';
import '../data/veka_report_repository.dart';
import 'veka_api_details.dart';
import 'veka_api_dialogs.dart';
import 'veka_api_history_dialog.dart';
import 'veka_report_dialog.dart';

/// Reviews or verifies a simulation without exposing a real transport action.
class VekaApiActions {
  const VekaApiActions({
    required this.visitId,
    required this.api,
    required this.reports,
  });

  final int visitId;
  final VekaApiRepository api;
  final VekaReportRepository reports;

  Future<void> review(BuildContext context, VekaApiAttempt? previous,
      {bool archived = false}) async {
    final saves = DraftSaveScope.of(context);
    await saves?.settle();
    var report = await reports.preview(visitId);
    if (!context.mounted) return;

    final corrects =
        archived && previous?.canCorrectActivityDate == true ? previous : null;
    if (corrects != null) {
      final now = DateUtils.dateOnly(DateTime.now());
      final savedDate = report.section('activity')['visit_date'];
      final firstDate = DateTime(1900);
      final initial = DateTime.tryParse(savedDate?.toString() ?? '');
      final date = await showDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: now,
        initialDate: initial != null &&
                !initial.isBefore(firstDate) &&
                !initial.isAfter(now)
            ? initial
            : now,
        helpText: VekaApiDictionary.correctDateHint,
        confirmText: AppDictionary.btnOk,
        cancelText: AppDictionary.btnCancel,
      );
      if (!context.mounted || date == null) return;
      report = report.withActivityDate(date.toIso8601String().split('T').first);
    }

    final missing = VekaApiPayload.missingTabs(report, DateTime.now());
    final prepared =
        report.supported && missing.isEmpty ? api.prepare(report) : null;
    final warning = switch ((report.supported, missing.contains(4), prepared)) {
      (false, _, _) => VekaDictionary.unsupported,
      (true, true, _) => VekaApiDictionary.addressBlocked,
      (true, false, null) => VekaApiDictionary.fieldsBlocked,
      (true, false, _)
          when corrects != null &&
              report.section('activity')['visit_date'] ==
                  corrects.report.section('activity')['visit_date'] =>
        VekaApiDictionary.unchangedRejected,
      (_, _, final candidate?)
          when !api.canSubmit(candidate, previous: previous) =>
        VekaApiDictionary.unchangedRejected,
      _ => null,
    };
    if (warning != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => VekaReportDialog(
          report: report,
          title: VekaApiDictionary.review,
          warning: warning,
          missingTabs: missing,
        ),
      );
      return;
    }

    final outcome = await showDialog<VekaMockOutcome>(
      context: context,
      builder: (_) => VekaApiReviewDialog(
        correction: corrects != null,
        details: VekaApiPayloadDetails(
          report: prepared!.report,
          requestReference: prepared.requestReference,
          contractVersion: prepared.contractVersion,
          requestJson: prepared.requestJson,
        ),
      ),
    );
    if (!context.mounted || outcome == null) return;
    await saves?.settle();
    if (!context.mounted) return;
    await api.submit(report,
        prepared: prepared, corrects: corrects, outcome: outcome);
  }

  Future<void> history(BuildContext context) async {
    final attempts = await api.history(visitId);
    final history = await Future.wait([
      for (final attempt in attempts)
        api
            .dispatches(attempt)
            .then((dispatches) => (attempt: attempt, dispatches: dispatches)),
    ]);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => VekaApiHistoryDialog(attempts: history),
    );
  }

  Future<void> recover(BuildContext context, VekaApiAttempt previous) async {
    final saves = DraftSaveScope.of(context);
    final latest = await api.read(visitId);
    if (!context.mounted) return;
    if (latest == null ||
        latest.status != previous.status ||
        latest.requestReference != previous.requestReference ||
        latest.dispatchNumber != previous.dispatchNumber) {
      throw const VekaException(VekaIssue.changed);
    }
    final accessRestored = latest.status == VekaApiStatus.technical;
    if (accessRestored) {
      await saves?.settle();
      final fresh = await reports.preview(visitId);
      if (!context.mounted) return;
      if (fresh.differsFrom(latest.report)) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(VekaApiDictionary.retryReview),
            content: const Text(VekaApiDictionary.accessRetryChanged),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(AppDictionary.btnOk),
              ),
            ],
          ),
        );
        return;
      }
    } else {
      final decision = await showDialog<VekaApiVerification>(
        context: context,
        builder: (_) => VekaApiVerificationDialog(attempt: latest),
      );
      if (!context.mounted || decision == null) return;
      if (decision == VekaApiVerification.found) {
        await api.reconcileReceipt(visitId, latest.requestReference,
            expectedDispatchNumber: latest.dispatchNumber);
        return;
      }
    }
    final outcome = await showDialog<VekaMockOutcome>(
      context: context,
      builder: (_) => VekaApiReviewDialog(
        details: VekaApiPayloadDetails(
          report: latest.report,
          requestReference: latest.requestReference,
          contractVersion: latest.contractVersion,
          requestJson: latest.requestJson,
        ),
        retry: true,
        accessRestored: accessRestored,
      ),
    );
    if (!context.mounted || outcome == null) return;
    if (accessRestored) {
      await saves?.settle();
      if (context.mounted) {
        await api.retryAfterAccessRestored(latest, outcome: outcome);
      }
      return;
    }
    await api.confirmAbsentAndRetry(visitId, latest.requestReference,
        outcome: outcome, expectedDispatchNumber: latest.dispatchNumber);
  }
}
