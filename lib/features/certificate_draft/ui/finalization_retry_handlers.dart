import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../email_delivery/data/archive_outcome.dart';
import '../../email_delivery/data/email_outbox_repository.dart';
import '../../email_delivery/data/pdf_archiving_coordinator.dart';
import '../../email_delivery/data/recipient_confirmation.dart';
import 'finalization_confirm_dialog.dart';

/// Helper handling interactive retry loops for database registration and outbox queuing.
abstract final class FinalizationRetryHandlers {
  /// Archives the PDF with interactive retry and deletion recovery.
  static Future<ArchiveOutcome> archivePdfWithRetry(
    BuildContext context,
    PdfArchivingCoordinator coordinator,
    int visitId,
  ) async {
    final outcome = await coordinator.archiveAndUpdateStatus(visitId);
    if (!context.mounted || outcome.archiveSuccess) return outcome;

    if (outcome.isDatabaseRegistrationFailure &&
        outcome.archivePath.isNotEmpty) {
      var registered = false;
      while (!registered) {
        if (!context.mounted) return outcome;
        final shouldRetry = await FinalizationConfirmDialog.show(
          context,
          title: EmailDeliveryDictionary.pdfRegistrationRetryTitle,
          content: EmailDeliveryDictionary.pdfRegistrationRetryMessage,
          cancelLabel: EmailDeliveryDictionary.pdfRegistrationRetryCancel,
          confirmLabel: EmailDeliveryDictionary.pdfRegistrationRetryAction,
        );
        if (!context.mounted) return outcome;

        if (shouldRetry != true) {
          final confirmDelete = await FinalizationConfirmDialog.show(
            context,
            title: EmailDeliveryDictionary.pdfRegistrationDeleteConfirmTitle,
            content:
                EmailDeliveryDictionary.pdfRegistrationDeleteConfirmMessage,
            cancelLabel:
                EmailDeliveryDictionary.pdfRegistrationDeleteConfirmCancel,
            confirmLabel:
                EmailDeliveryDictionary.pdfRegistrationDeleteConfirmAction,
          );
          if (!context.mounted || confirmDelete != true) continue;

          final deleted = await coordinator.deleteUnregisteredArchiveFile(
            outcome.archivePath,
          );
          if (context.mounted) {
            TacticalFeedback.showError(
              context,
              deleted
                  ? EmailDeliveryDictionary.pdfRegistrationFailed
                  : EmailDeliveryDictionary.pdfDeleteFailedError,
            );
          }
          return outcome;
        }

        if (!await coordinator.archiveFileExists(outcome.archivePath)) {
          if (context.mounted) {
            TacticalFeedback.showError(
                context, EmailDeliveryDictionary.pdfFileNotFoundError);
          }
          continue;
        }

        registered = await coordinator.registerArchivedPdf(
          visitId: visitId,
          archivePath: outcome.archivePath,
        );
        if (registered) {
          return ArchiveOutcome(
            archiveSuccess: true,
            archivePath: outcome.archivePath,
            copyTechnicianDefault: outcome.copyTechnicianDefault,
            technicianEmail: outcome.technicianEmail,
            snapshot: outcome.snapshot,
          );
        }
        if (!registered && context.mounted) {
          TacticalFeedback.showError(
              context, EmailDeliveryDictionary.pdfRegistrationFailed);
        }
      }
    } else {
      TacticalFeedback.showError(
          context, EmailDeliveryDictionary.archiveFailure);
    }
    return outcome;
  }

  /// Queues email jobs with interactive retry on SQLite failures.
  static Future<void> queueJobsWithRetry(
    BuildContext context,
    PdfArchivingCoordinator coordinator,
    int visitId,
    RecipientConfirmation confirmation,
    ArchiveOutcome archiveOutcome,
  ) async {
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
        debugPrint('[FinalizationRetryHandlers] Outbox queue error: $e');
        if (!context.mounted) return;
        final retry = await FinalizationConfirmDialog.show(
          context,
          title: EmailDeliveryDictionary.outboxRetryDialogTitle,
          content: EmailDeliveryDictionary.outboxRetryDialogMessage,
          cancelLabel: EmailDeliveryDictionary.outboxRetryCancel,
          confirmLabel: EmailDeliveryDictionary.outboxRetryAction,
        );
        if (retry != true) {
          if (context.mounted) {
            TacticalFeedback.showInfo(context,
                EmailDeliveryDictionary.outboxQueueSkippedAfterFailure);
          }
          return;
        }
      }
    }
  }
}
