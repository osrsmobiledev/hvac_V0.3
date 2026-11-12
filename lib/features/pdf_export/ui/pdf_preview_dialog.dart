import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../app/localization/eindbeoordeling_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../combustion_pdf_generator.dart';
import '../data/pdf_visit_data.dart';
import '../services/pdf_file_saver.dart';
import 'pdf_page_card.dart';

/// Modal dialog providing interactive preview, pinch-to-zoom, pan,
/// print, and file export for the generated Flemish combustion certificate.
class PdfPreviewDialog extends StatefulWidget {
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
  State<PdfPreviewDialog> createState() => _PdfPreviewDialogState();
}

class _PdfPreviewDialogState extends State<PdfPreviewDialog> {
  late final TransformationController _transformationController;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomBy(double factor) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(1.0, 5.0);
    if (newScale <= 1.0) {
      _resetZoom();
      return;
    }
    final w = _viewportSize.width > 0 ? _viewportSize.width : 400.0;
    final h = _viewportSize.height > 0 ? _viewportSize.height : 600.0;
    final dx = (w * (1.0 - newScale)) / 2.0;
    final dy = (h * (1.0 - newScale)) / 2.0;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0.0, 1.0)
      ..scaleByDouble(newScale, newScale, 1.0, 1.0);
  }

  void _zoomIn() => _zoomBy(1.35);
  void _zoomOut() => _zoomBy(1 / 1.35);
  void _resetZoom() => _transformationController.value = Matrix4.identity();

  void _handleDoubleTap() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    scale > 1.2 ? _resetZoom() : _zoomBy(2.5 / scale);
  }

  Future<void> _savePdfToDevice() async {
    final bytes = await CombustionPdfGenerator.generateCertificate(widget.data);
    final result = await PdfFileSaver.saveToDevice(
      pdfBytes: bytes,
      attestNumber: widget.data.volgnummerAttest,
    );
    if (!mounted) return;
    final msg = result.isSuccess
        ? '${EindbeoordelingDictionary.toastPdfSaved}${result.filePath}'
        : '${EindbeoordelingDictionary.toastPdfSaveFailed}${result.errorMessage}';
    if (result.isSuccess) {
      TacticalFeedback.showSuccess(context, msg, duration: const Duration(seconds: 4));
    } else {
      TacticalFeedback.showError(context, msg, duration: const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.carbonCard,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
      ),
      child: Column(
        children: [
          // Top bar with title and quick zoom / export actions
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded, size: 20.0),
                  color: AppColors.textSecondary,
                  tooltip: 'Uitzoomen',
                  visualDensity: VisualDensity.compact,
                  onPressed: _zoomOut,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded, size: 20.0),
                  color: AppColors.textSecondary,
                  tooltip: 'Inzoomen',
                  visualDensity: VisualDensity.compact,
                  onPressed: _zoomIn,
                ),
                IconButton(
                  icon: const Icon(Icons.fit_screen_rounded, size: 20.0),
                  color: AppColors.textSecondary,
                  tooltip: 'Passend maken',
                  visualDensity: VisualDensity.compact,
                  onPressed: _resetZoom,
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded,
                      color: AppColors.amberGold, size: 20.0),
                  tooltip: 'Opslaan op toestel',
                  visualDensity: VisualDensity.compact,
                  onPressed: _savePdfToDevice,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20.0),
                  tooltip: 'Sluiten',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Interactive PDF Canvas with 240 DPI & pinch-to-zoom
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              child: PdfPreview.builder(
                build: (PdfPageFormat format) =>
                    CombustionPdfGenerator.generateCertificate(widget.data),
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                initialPageFormat: PdfPageFormat.a4,
                maxPageWidth: 700.0,
                dpi: 240.0,
                pdfFileName:
                    'Verbrandingsattest_${widget.data.volgnummerAttest.isNotEmpty ? widget.data.volgnummerAttest : 'concept'}.pdf',
                previewPageMargin: const EdgeInsets.all(8.0),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.amberGold,
                  ),
                ),
                actionBarTheme: const PdfActionBarTheme(
                  backgroundColor: AppColors.carbonCard,
                  iconColor: AppColors.amberGold,
                  elevation: 0,
                ),
                pagesBuilder: (context, pages) {
                  if (pages.isEmpty) return const SizedBox.shrink();
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      _viewportSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return GestureDetector(
                        onDoubleTap: _handleDoubleTap,
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 5.0,
                          boundaryMargin: const EdgeInsets.all(48.0),
                          clipBehavior: Clip.hardEdge,
                          child: Center(
                            child: PdfPageCard(page: pages.first),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
