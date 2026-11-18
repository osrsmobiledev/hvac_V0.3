import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/localization/visit_history_dictionary.dart';
import '../../../core/services/app_warmup_service.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../email_delivery/data/email_outbox_repository.dart';
import '../../email_delivery/data/pdf_archiving_coordinator.dart';
import '../../email_delivery/ui/email_recipient_dialog.dart';
import '../../pdf_export/data/pdf_visit_data.dart';
import '../../pdf_export/data/pdf_visit_loader.dart';
import '../../reporting_delivery/data/veka_report_repository.dart';
import '../../visit_history/data/visit_history_repository.dart';
import 'draft_save_scope.dart';

class VisitFinalizationException implements Exception {
  final String message;
  const VisitFinalizationException(this.message);
}

abstract final class VisitFinalization {
  static Future<bool> confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(VisitHistoryDictionary.confirmTitle),
        content: const Text(VisitHistoryDictionary.confirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppDictionary.btnCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(VisitHistoryDictionary.confirmAction)),
        ],
      ),
    );
    return ok ?? false;
  }

  static Future<bool> save(DraftSaveScope scope, int visitId) async {
    try {
      await scope.settle();
      final needsFollowUp = await VisitHistoryRepository().finalize(visitId);
      AppWarmupService.instance.invalidate();
      return needsFollowUp;
    } catch (error) {
      final isCust =
          error is VekaException && error.issue == VekaIssue.customerEditing;
      throw VisitFinalizationException(isCust
          ? VisitHistoryDictionary.customerEditing
          : VisitHistoryDictionary.archiveError);
    }
  }

  /// Archives the PDF from the frozen snapshot, presents recipient choices,
  /// and atomically queues email delivery jobs.
  ///
  /// Outbox queue errors do not invalidate the finalized visit or archived PDF.
  static Future<void> archiveAndPromptRecipients(
    BuildContext context,
    int visitId, {
    PdfArchivingCoordinator? coordinatorOverride,
  }) async {
    final coordinator = coordinatorOverride ?? PdfArchivingCoordinator();
    final archiveOutcome = await coordinator.archiveAndUpdateStatus(visitId);
    if (!context.mounted) return;

    if (!archiveOutcome.archiveSuccess) {
      if (archiveOutcome.isDatabaseRegistrationFailure &&
          archiveOutcome.archivePath.isNotEmpty) {
        var registered = false;
        while (!registered) {
          if (!context.mounted) return;
          final shouldRetryReg = await _showConfirmDialog(
            context,
            title: EmailDeliveryDictionary.pdfRegistrationRetryTitle,
            content: EmailDeliveryDictionary.pdfRegistrationRetryMessage,
            cancelLabel: EmailDeliveryDictionary.pdfRegistrationRetryCancel,
            confirmLabel: EmailDeliveryDictionary.pdfRegistrationRetryAction,
          );
          if (!context.mounted) return;

          if (shouldRetryReg != true) {
            final confirmDelete = await _showConfirmDialog(
              context,
              title: EmailDeliveryDictionary.pdfRegistrationDeleteConfirmTitle,
              content:
                  EmailDeliveryDictionary.pdfRegistrationDeleteConfirmMessage,
              cancelLabel:
                  EmailDeliveryDictionary.pdfRegistrationDeleteConfirmCancel,
              confirmLabel:
                  EmailDeliveryDictionary.pdfRegistrationDeleteConfirmAction,
            );
            if (!context.mounted) return;
            if (confirmDelete != true) continue;

            final deleted = await coordinator.deleteUnregisteredArchiveFile(
              archiveOutcome.archivePath,
            );
            if (context.mounted) {
              TacticalFeedback.showError(
                context,
                deleted
                    ? EmailDeliveryDictionary.pdfRegistrationFailed
                    : EmailDeliveryDictionary.pdfDeleteFailedError,
              );
            }
            return;
          }

          if (!await coordinator
              .archiveFileExists(archiveOutcome.archivePath)) {
            if (context.mounted) {
              TacticalFeedback.showError(
                  context, EmailDeliveryDictionary.pdfFileNotFoundError);
            }
            continue;
          }

          registered = await coordinator.registerArchivedPdf(
            visitId: visitId,
            archivePath: archiveOutcome.archivePath,
          );
          if (!registered && context.mounted) {
            TacticalFeedback.showError(
                context, EmailDeliveryDictionary.pdfRegistrationFailed);
          }
        }
        if (!context.mounted) return;
      } else {
        TacticalFeedback.showError(
            context, EmailDeliveryDictionary.archiveFailure);
        return;
      }
    }

    PdfVisitData? visitData;
    try {
      if (archiveOutcome.snapshot.isNotEmpty) {
        visitData = PdfVisitLoader.fromSnapshot(archiveOutcome.snapshot);
      }
    } catch (_) {}

    final confirmation = await EmailRecipientDialog.show(
      context,
      snapshot: visitData ?? const PdfVisitData(),
      defaultCopyTechnician: archiveOutcome.copyTechnicianDefault,
      technicianEmail: archiveOutcome.technicianEmail,
    );
    if (!context.mounted) return;

    if (confirmation == null) {
      TacticalFeedback.showSuccess(
          context, EmailDeliveryDictionary.recipientDialogSkipped);
      return;
    }

    while (context.mounted) {
      try {
        final result = await coordinator.createEmailJobs(
          visitId: visitId,
          pdfPath: archiveOutcome.archivePath,
          sendToCustomer: confirmation.sendToCustomer,
          customerName: confirmation.customerName,
          customerEmail: confirmation.customerEmail,
          sendToTechnician: confirmation.sendToTechnician,
          technicianEmail: confirmation.technicianEmail,
          attestNumber: PdfArchivingCoordinator.attestNumberFromSnapshot(
              archiveOutcome.snapshot),
        );
        if (!context.mounted) return;

        final msg = switch (result) {
          EmailQueueResult.queued =>
            EmailDeliveryDictionary.recipientJobsQueued,
          EmailQueueResult.alreadyQueued =>
            EmailDeliveryDictionary.recipientJobsAlreadyQueued,
          EmailQueueResult.skipped =>
            EmailDeliveryDictionary.recipientDialogSkipped,
        };
        TacticalFeedback.showSuccess(context, msg);
        return;
      } catch (e) {
        debugPrint('[VisitFinalization] Outbox queue error: $e');
        if (!context.mounted) return;

        final shouldRetry = await _showConfirmDialog(
          context,
          title: EmailDeliveryDictionary.outboxRetryDialogTitle,
          content: EmailDeliveryDictionary.outboxRetryDialogMessage,
          cancelLabel: EmailDeliveryDictionary.outboxRetryCancel,
          confirmLabel: EmailDeliveryDictionary.outboxRetryAction,
        );
        if (!context.mounted) return;

        if (shouldRetry != true) {
          TacticalFeedback.showInfo(
              context, EmailDeliveryDictionary.outboxQueueSkippedAfterFailure);
          return;
        }
      }
    }
  }

  static Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String cancelLabel,
    required String confirmLabel,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      );
}
