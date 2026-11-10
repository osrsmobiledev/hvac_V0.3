import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'data/pdf_visit_data.dart';
import 'builders/pdf_header_builder.dart';
import 'builders/pdf_firma_builder.dart';
import 'builders/pdf_klant_builder.dart';
import 'builders/pdf_toestel_kenmerken_builder.dart';
import 'builders/pdf_toestel_apparaat_builder.dart';
import 'builders/pdf_meting_builder.dart';
import 'builders/pdf_eindbeoordeling_builder.dart';
import 'builders/pdf_gebreken_handtekeningen_builder.dart';
import 'builders/pdf_legal_footer_builder.dart';

/// Master orchestrator generating the complete official Flemish Combustion Certificate A4 PDF.
abstract final class CombustionPdfGenerator {
  /// Generates the raw PDF bytes for the given [data].
  ///
  /// Fits strictly onto a single A4 page with 0.2pt borders, Libron typography,
  /// and 1-to-1 statutory fidelity to the official Flemish government template.
  static Future<Uint8List> generateCertificate(PdfVisitData data) async {
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
      debugPrint('[CombustionPdfGenerator] Font loading fallback: $e\n$stack');
      baseFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final pdf = pw.Document(
      title: 'Verbrandingsattest Vlaanderen',
      author: data.firmaNaam.isNotEmpty ? data.firmaNaam : 'Erkend Technicus',
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.only(
            top: 10.0,
            left: 24.9,
            right: 17.3,
            bottom: 10.0,
          ),
          buildBackground: (pw.Context context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header (Onderhoud vs Keuring, Volgnummer)
              PdfHeaderBuilder.buildHeader(data),
              pw.SizedBox(height: 2.0),

              // 2. Firma & Technicus
              PdfFirmaBuilder.buildFirmaSection(data),
              pw.SizedBox(height: 2.0),

              // 3. Klant & Installatieadres
              PdfKlantBuilder.buildKlantSection(data),
              pw.SizedBox(height: 2.0),

              // 4. Kenmerken van het stooktoestel (Type B/C, brandstof, premix)
              PdfToestelKenmerkenBuilder.buildKenmerkenSection(data),
              pw.SizedBox(height: 2.0),

              // 5. Toestel & Brander apparaat specificaties
              PdfToestelApparaatBuilder.buildApparaatSection(data),
              pw.SizedBox(height: 2.0),

              // 6. Goede staat van werking (Metingen, Bacharach, Rookgassen)
              PdfMetingBuilder.buildMetingSection(data),
              pw.SizedBox(height: 2.0),

              // 7. Eindbeoordeling (Official Flemish Template Row 36)
              PdfEindbeoordelingBuilder.buildEindbeoordelingSection(data),
              pw.SizedBox(height: 2.0),

              // 8. Gebreken en maatregelen + Handtekeningen (Official Table 4)
              PdfGebrekenHandtekeningenBuilder.buildGebrekenSection(data),
              pw.SizedBox(height: 2.0),

              // 9. Statutory Legal Footer (Official Table 5)
              PdfLegalFooterBuilder.buildLegalFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
