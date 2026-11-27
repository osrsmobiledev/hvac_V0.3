import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/pdf_export/certificate_pdf_dispatcher.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_data_mapper.dart';
import 'package:hvac_app/features/pdf_export/services/pdf_file_saver.dart';
import 'package:hvac_app/features/pdf_export/ui/pdf_preview_dialog.dart';

/// Handles PDF preview and device-save actions for Tab 6/7 (Eindbeoordeling).
abstract final class EindbeoordelingPdfActions {
  static Future<void> handleTestPdf(
    BuildContext context, {
    required int visitId,
    required String certificateType,
    required Debouncer debouncer,
  }) async {
    await debouncer.settle(ignoreFailure: true);
    if (!context.mounted) return;
    final data = await PdfDataMapper.loadVisitData(visitId);
    if (!context.mounted) return;
    await PdfPreviewDialog.show(context, data);
  }

  static Future<void> handleSaveDevice(
    BuildContext context, {
    required int visitId,
    required String certificateType,
    required Debouncer debouncer,
  }) async {
    await debouncer.settle(ignoreFailure: true);
    if (!context.mounted) return;
    final data = await PdfDataMapper.loadVisitData(visitId);
    final effectiveType = certificateType == 'reiniging' ||
            data.cleaning.certificateType == 'reiniging'
        ? 'reiniging'
        : 'verbranding';
    final pdfBytes = await CertificatePdfDispatcher.generateCertificate(
      data,
      certificateTypeOverride: effectiveType,
    );
    final result = await PdfFileSaver.saveToDevice(
      pdfBytes: pdfBytes,
      attestNumber: data.volgnummerAttest,
      certificateType: effectiveType,
    );
    if (!context.mounted) return;
    if (result.isSuccess) {
      TacticalFeedback.showSuccess(
        context,
        '${EindbeoordelingDictionary.toastPdfSaved}${result.filePath}',
        duration: const Duration(seconds: 4),
      );
    } else {
      TacticalFeedback.showError(
        context,
        '${EindbeoordelingDictionary.toastPdfSaveFailed}${result.errorMessage}',
        duration: const Duration(seconds: 4),
      );
    }
  }
}
