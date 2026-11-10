import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../app/localization/eindbeoordeling_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../combustion_pdf_generator.dart';
import '../data/pdf_visit_data.dart';
import '../services/pdf_file_saver.dart';

/// Modal dialog providing interactive full-screen preview, zoom, and print
/// of the generated Flemish combustion certificate.
class PdfPreviewDialog extends StatelessWidget {
  final PdfVisitData data;

  const PdfPreviewDialog({
    super.key,
    required this.data,
  });

  /// Displays the preview modal as a responsive dialog.
  static Future<void> show(BuildContext context, PdfVisitData data) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xD9000000),
      builder: (ctx) => PdfPreviewDialog(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.carbonCard,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
      ),
      child: Column(
        children: [
          // Top bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.hairlineBorder, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.amberGold,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                const Expanded(
                  child: Text(
                    'Verbrandingsattest Vlaanderen (A4)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Libron',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded,
                      color: AppColors.amberGold),
                  tooltip: 'Save-Device',
                  onPressed: () async {
                    final pdfBytes =
                        await CombustionPdfGenerator.generateCertificate(data);
                    final result = await PdfFileSaver.saveToDevice(
                      pdfBytes: pdfBytes,
                      attestNumber: data.volgnummerAttest,
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
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Sluiten',
                ),
              ],
            ),
          ),

          // Interactive PDF Canvas Preview
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              child: PdfPreview(
                build: (PdfPageFormat format) =>
                    CombustionPdfGenerator.generateCertificate(data),
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                initialPageFormat: PdfPageFormat.a4,
                maxPageWidth: 700.0,
                pdfFileName:
                    'Verbrandingsattest_${data.volgnummerAttest.isNotEmpty ? data.volgnummerAttest : 'concept'}.pdf',
                previewPageMargin: const EdgeInsets.all(8.0),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.amberGold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
