import 'package:flutter/material.dart';

import '../../../app/localization/veka_dictionary.dart';
import '../../certificate_draft/ui/draft_save_scope.dart';
import '../data/veka_report.dart';
import '../data/veka_report_repository.dart';
import 'veka_confirmation_dialog.dart';
import 'veka_report_dialog.dart';

/// Presents and confirms manual evidence separately from the simulation.
class VekaPortalActions {
  const VekaPortalActions({
    required this.visitId,
    required this.reports,
    required this.openPortal,
    required this.verifyAvailable,
  });

  final int visitId;
  final VekaReportRepository reports;
  final Future<void> Function() openPortal;
  final Future<void> Function() verifyAvailable;

  Future<bool> _launch(BuildContext context) async {
    await verifyAvailable();
    if (!context.mounted) return false;
    try {
      await openPortal();
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _showReport(
    BuildContext context,
    VekaReport report,
    String title, {
    String? action,
    String? warning,
    List<int> missing = const [],
    Map<String, Object?>? confirmation,
  }) async =>
      await showDialog<bool>(
          context: context,
          builder: (_) => VekaReportDialog(
                report: report,
                title: title,
                action: action,
                warning: warning,
                missingTabs: missing,
                confirmation: confirmation,
              )) ==
      true;

  Future<bool> current(BuildContext context,
      {bool prepare = false, bool replace = false}) async {
    final record = await reports.read(visitId);
    if (!context.mounted) return false;
    if (prepare && (record.confirmed || replace != (record.report != null))) {
      throw const VekaException(VekaIssue.changed);
    }
    if (prepare) await verifyAvailable();
    if (!context.mounted) return false;
    final saves = DraftSaveScope.of(context);
    await saves?.settle();
    final report = await reports.preview(visitId);
    if (!context.mounted) return false;
    if (replace &&
        !await _showReport(context, record.report!, VekaDictionary.saved,
            action: VekaDictionary.replaceConfirm,
            warning: VekaDictionary.replaceWarning)) {
      return false;
    }
    if (!context.mounted) return false;
    final missing = report.missingTabs(DateTime.now());
    final eligible = report.supported && missing.isEmpty;
    final approved = await _showReport(context, report,
        prepare ? VekaDictionary.portalReview : VekaDictionary.current,
        missing: missing,
        warning:
            VekaDictionary.reviewMessage(report.supported, prepare, eligible),
        action: eligible && prepare
            ? (replace ? VekaDictionary.replace : VekaDictionary.reserve)
            : null);
    if (!context.mounted || !approved) return false;
    await saves?.settle();
    if (!context.mounted) return false;
    await reports.reserve(report, replaces: replace ? record.report!.id : null);
    return !replace && context.mounted ? await _launch(context) : false;
  }

  Future<bool> saved(BuildContext context,
      {bool launch = false, bool confirm = false}) async {
    final record = await reports.read(visitId);
    if (!context.mounted) return false;
    final report = record.report;
    if (report == null) return false;
    if (launch || confirm) await verifyAvailable();
    if (!context.mounted) return false;
    final approved = await _showReport(context, report,
        record.confirmed ? VekaDictionary.reported : VekaDictionary.saved,
        action: record.confirmed
            ? null
            : launch
                ? VekaDictionary.open
                : confirm
                    ? VekaDictionary.confirm
                    : null,
        confirmation: record.confirmation);
    if (!context.mounted || !approved) return false;
    if (launch) {
      final latest = await reports.read(visitId);
      if (latest.report?.id != report.id || latest.confirmed) {
        throw const VekaException(VekaIssue.changed);
      }
      return context.mounted ? await _launch(context) : false;
    }
    if (confirm && !record.confirmed) {
      final details = await showDialog<VekaConfirmation>(
          context: context,
          builder: (_) => VekaConfirmationDialog(address: report.address));
      if (!context.mounted || details == null) return false;
      await reports.confirm(visitId, report.id!,
          actor: details.actor,
          reference: details.reference,
          submittedAt: details.submittedAt);
    }
    return false;
  }
}
