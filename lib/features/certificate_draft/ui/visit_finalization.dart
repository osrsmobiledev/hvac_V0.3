import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/visit_history_dictionary.dart';
import '../../../core/services/app_warmup_service.dart';
import '../../reporting_delivery/data/veka_report_repository.dart';
import '../../visit_history/data/visit_history_repository.dart';
import 'draft_save_scope.dart';

class VisitFinalizationException implements Exception {
  final String message;
  const VisitFinalizationException(this.message);
}

abstract final class VisitFinalization {
  static Future<bool> confirm(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(VisitHistoryDictionary.confirmTitle),
          content: const Text(VisitHistoryDictionary.confirmBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppDictionary.btnCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(VisitHistoryDictionary.confirmAction)),
          ],
        ),
      ) ==
      true;

  static Future<bool> save(DraftSaveScope scope, int visitId) async {
    try {
      await scope.settle();
      final needsFollowUp = await VisitHistoryRepository().finalize(visitId);
      AppWarmupService.instance.invalidate();
      return needsFollowUp;
    } catch (error) {
      throw VisitFinalizationException(
        error is VekaException && error.issue == VekaIssue.customerEditing
            ? VisitHistoryDictionary.customerEditing
            : VisitHistoryDictionary.archiveError,
      );
    }
  }
}
