import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import '../../../data/measurement_draft_repository.dart';
import 'eurolyzer_scanner_modal.dart';
import 'meting_form_controllers.dart';

/// Helper actions for importing, direct QR scanning, and clearing combustion test slots.
abstract final class MetingSlotActions {
  /// Resolves the readable title for a slot key.
  static String slotTitle(String activeSlot) {
    switch (activeSlot) {
      case 'proef2_laaglast':
        return MetingDictionary.slotProef2LaagShort;
      case 'proef2_hooglast':
        return MetingDictionary.slotProef2HoogShort;
      default:
        return MetingDictionary.slotProef1Short;
    }
  }

  /// Copies captured flue-gas telemetry from Tab 1 into the active slot.
  static Future<void> copyFromDataTab({
    required BuildContext context,
    required MeasurementDraftRepository repository,
    required int visitId,
    required MetingFormControllers controllers,
    required String activeSlot,
    required VoidCallback onFormChanged,
  }) async {
    final slotCtrl = controllers.slots[activeSlot];
    if (slotCtrl == null) return;

    final tab1Draft = await repository.loadTab1RawMeasurement(visitId);

    if (tab1Draft == null || tab1Draft.o2Percent == null) {
      if (!context.mounted) return;
      await showTacticalDialog<void>(
        context: context,
        builder: (ctx) => TacticalDialogWindow(
          title: MetingDictionary.dlgNoTab1DataTitle,
          maxWidth: 360,
          actions: TacticalDialogActions(
            cancelLabel: AppDictionary.btnCancel,
            confirmLabel: MetingDictionary.btnScanDirect,
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () {
              Navigator.of(ctx).pop();
              scanEurolyzer(
                context: context,
                repository: repository,
                visitId: visitId,
                controllers: controllers,
                activeSlot: activeSlot,
                onFormChanged: onFormChanged,
              );
            },
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              MetingDictionary.dlgNoTab1DataBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ),
      );
      return;
    }

    if (slotCtrl.hasAnyValues) {
      if (!context.mounted) return;
      final shouldOverwrite = await TacticalConfirmDialog.show(
        context: context,
        title: MetingDictionary.dlgConfirmOverwriteTitle,
        content: MetingDictionary.dlgConfirmOverwriteBodyWithTitle(
          slotTitle(activeSlot),
        ),
        confirmLabel: AppDictionary.btnEdit,
        cancelLabel: AppDictionary.btnCancel,
      );
      if (shouldOverwrite != true) return;
    }

    try {
      slotCtrl.populate(tab1Draft.copyWith(slot: activeSlot));
      await repository.saveMeasurementSlot(
          visitId, slotCtrl.buildDraft(activeSlot));
      onFormChanged();
      if (!context.mounted) return;
      TacticalFeedback.showSuccess(
        context,
        '${MetingDictionary.snackImportSuccess} (${slotTitle(activeSlot)})',
      );
    } catch (e, stack) {
      debugPrint('[MetingSlotActions] copyFromDataTab error: $e\n$stack');
      if (!context.mounted) return;
      TacticalFeedback.showError(context, '$e');
    }
  }

  /// Launches the in-slot Eurolyzer QR scanner.
  static Future<void> scanEurolyzer({
    required BuildContext context,
    required MeasurementDraftRepository repository,
    required int visitId,
    required MetingFormControllers controllers,
    required String activeSlot,
    required VoidCallback onFormChanged,
  }) async {
    final slotCtrl = controllers.slots[activeSlot];
    if (slotCtrl == null) return;

    final title = slotTitle(activeSlot);
    final scannedDraft = await EurolyzerScannerModal.scan(
      context,
      slotKey: activeSlot,
      slotTitle: title,
    );

    if (scannedDraft != null) {
      try {
        slotCtrl.populate(scannedDraft);
        await repository.saveMeasurementSlot(visitId, scannedDraft);
        onFormChanged();
        if (!context.mounted) return;
        TacticalFeedback.showSuccess(
          context,
          '${MetingDictionary.snackScanSuccess}$title',
        );
      } catch (e, stack) {
        debugPrint('[MetingSlotActions] scanEurolyzer error: $e\n$stack');
        if (!context.mounted) return;
        TacticalFeedback.showError(context, '$e');
      }
    }
  }

  /// Clears the active slot with confirmation.
  static Future<void> clearSlot({
    required BuildContext context,
    required MeasurementDraftRepository repository,
    required int visitId,
    required MetingFormControllers controllers,
    required String activeSlot,
    required VoidCallback onFormChanged,
  }) async {
    final slotCtrl = controllers.slots[activeSlot];
    if (slotCtrl == null || !slotCtrl.hasAnyValues) return;

    final title = slotTitle(activeSlot);

    final shouldClear = await TacticalConfirmDialog.show(
      context: context,
      title: MetingDictionary.dlgConfirmClearTitle,
      content: MetingDictionary.dlgConfirmClearBodyWithTitle(title),
      confirmLabel: AppDictionary.btnDelete,
      cancelLabel: AppDictionary.btnCancel,
      isDestructive: true,
    );

    if (shouldClear != true) return;

    try {
      slotCtrl.clear();
      await repository.clearMeasurementSlot(visitId, activeSlot);
      onFormChanged();
      if (!context.mounted) return;
      TacticalFeedback.showInfo(
        context,
        MetingDictionary.snackSlotClearedWithTitle(title),
      );
    } catch (e, stack) {
      debugPrint('[MetingSlotActions] clearSlot error: $e\n$stack');
      if (!context.mounted) return;
      TacticalFeedback.showError(context, '$e');
    }
  }
}
