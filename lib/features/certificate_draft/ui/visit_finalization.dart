import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/localization/visit_history_dictionary.dart';
import '../../../core/services/app_warmup_service.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../email_delivery/data/email_delivery_coordinator.dart';
import '../../email_delivery/data/pdf_archiving_coordinator.dart';
import '../../email_delivery/ui/email_recipient_dialog.dart';
import '../../pdf_export/data/pdf_visit_data.dart';
import '../../pdf_export/data/pdf_visit_loader.dart';
import '../../reporting_delivery/data/veka_report_repository.dart';
import '../../visit_history/data/visit_history_repository.dart';
import 'draft_save_scope.dart';
import 'finalization_retry_handlers.dart';

class VisitFinalizationException implements Exception {
  final String message;
  const VisitFinalizationException(this.message);
}

/// Orchestrates combustion visit finalization, recipient selection, and PDF archiving.
abstract final class VisitFinalization {
  /// Confirms finalization intent with the technician.
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

  /// Finalizes the visit draft in SQLite and invalidates warmup caches.
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

  /// Unified finalization workflow: prompts for recipients BEFORE database finalization.
  /// Cancelling keeps the draft active and prevents finalization, snapshot
  /// freezing, PDF archiving, outbox creation, and dispatch.
  static Future<bool> executeWorkflow(
    BuildContext context, {
    required int visitId,
    required DraftSaveScope saveScope,
    PdfArchivingCoordinator? coordinatorOverride,
  }) async {
    await saveScope.settle();

    final visitData = await PdfVisitLoader.loadVisitData(visitId);
    final coordinator = coordinatorOverride ?? PdfArchivingCoordinator();
    final smtp = await coordinator.loadSmtpDefaults();
    if (!context.mounted) return false;

    final dialogResult = await EmailRecipientDialog.show(
      context,
      snapshot: visitData,
      defaultCopyTechnician: smtp.copyTechnician,
      technicianEmail: smtp.technicianEmail,
    );
    if (!context.mounted || dialogResult.isCancel) return false;

    final confirmation = dialogResult.confirmation;

    final followUp = await save(saveScope, visitId);
    if (!context.mounted) return false;

    final archiveOutcome = await FinalizationRetryHandlers.archivePdfWithRetry(
        context, coordinator, visitId);
    if (!context.mounted || !archiveOutcome.archiveSuccess) return true;

    if (dialogResult.isQueue && confirmation != null) {
      await FinalizationRetryHandlers.queueJobsWithRetry(
          context, coordinator, visitId, confirmation, archiveOutcome);
      unawaited(EmailDeliveryCoordinator.instance.processOutbox());
    } else {
      TacticalFeedback.showSuccess(
          context, EmailDeliveryDictionary.recipientDialogSkipped);
    }

    if (followUp && context.mounted) {
      TacticalFeedback.showSuccess(
          context, VisitHistoryDictionary.reportPending);
    }
    return true;
  }

  /// Preserved for backwards compatibility with existing failure unit tests.
  @visibleForTesting
  static Future<bool> archiveAndPromptRecipients(
    BuildContext context,
    int visitId, {
    PdfArchivingCoordinator? coordinatorOverride,
  }) async {
    final coordinator = coordinatorOverride ?? PdfArchivingCoordinator();
    final archiveOutcome = await FinalizationRetryHandlers.archivePdfWithRetry(
        context, coordinator, visitId);
    if (!context.mounted || !archiveOutcome.archiveSuccess) return false;

    PdfVisitData? visitData;
    try {
      if (archiveOutcome.snapshot.isNotEmpty) {
        visitData = PdfVisitLoader.fromSnapshot(archiveOutcome.snapshot);
      }
    } catch (_) {}

    final dialogResult = await EmailRecipientDialog.show(
      context,
      snapshot: visitData ?? const PdfVisitData(),
      defaultCopyTechnician: archiveOutcome.copyTechnicianDefault,
      technicianEmail: archiveOutcome.technicianEmail,
    );
    if (!context.mounted) return false;

    if (dialogResult.isCancel) {
      await VisitHistoryRepository().revertFinalization(visitId);
      if (archiveOutcome.archivePath.isNotEmpty) {
        await coordinator
            .deleteUnregisteredArchiveFile(archiveOutcome.archivePath);
      }
      AppWarmupService.instance.invalidate();
      if (context.mounted) {
        TacticalFeedback.showInfo(
            context, EmailDeliveryDictionary.finalizationCancelled);
      }
      return false;
    }

    if (dialogResult.isSkip) {
      if (context.mounted) {
        TacticalFeedback.showSuccess(
            context, EmailDeliveryDictionary.recipientDialogSkipped);
      }
      return true;
    }

    final confirmation = dialogResult.confirmation!;
    if (confirmation.customerEmail.isNotEmpty) {
      await VisitHistoryRepository()
          .updateCustomerEmailForVisit(visitId, confirmation.customerEmail);
    }
    if (context.mounted) {
      await FinalizationRetryHandlers.queueJobsWithRetry(
          context, coordinator, visitId, confirmation, archiveOutcome);
    }
    return true;
  }
}
