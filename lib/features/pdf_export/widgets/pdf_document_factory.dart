import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Shared factory for Flemish A4 PDF documents, Libron font loading, and
/// calibrated single-page A4 margins.
abstract final class PdfDocumentFactory {
  /// Creates a [pw.Document] configured with Libron fonts (falling back to
  /// Helvetica if asset loading fails in headless environments).
  static Future<pw.Document> createA4Document({
    required String title,
    required String author,
  }) async {
    pw.Font baseFont;
    pw.Font boldFont;

    try {
      final libronRegularData =
          await rootBundle.load('assets/fonts/libron-regular.ttf');
      final libronBoldData =
          await rootBundle.load('assets/fonts/libron-bold.ttf');
      baseFont = pw.Font.ttf(libronRegularData);
      boldFont = pw.Font.ttf(libronBoldData);
    } catch (e, stack) {
      debugPrint('[PdfDocumentFactory] Font loading fallback: $e\n$stack');
      baseFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    return pw.Document(
      title: title,
      author: author.isNotEmpty ? author : 'Erkend Technicus',
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
  }

  /// Returns the calibrated single-page A4 [pw.PageTheme] matching the
  /// official Flemish certificate geometry.
  static pw.PageTheme a4PageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(
        top: 8.0,
        left: 24.9,
        right: 17.3,
        bottom: 8.0,
      ),
      buildBackground: (pw.Context context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: PdfColors.white),
      ),
    );
  }
}
