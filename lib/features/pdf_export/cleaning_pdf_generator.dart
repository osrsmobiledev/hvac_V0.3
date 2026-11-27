import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

import 'builders/cleaning_controls_builder.dart';
import 'builders/cleaning_firma_builder.dart';
import 'builders/cleaning_gebreken_builder.dart';
import 'builders/cleaning_header_builder.dart';
import 'builders/cleaning_legal_footer_builder.dart';
import 'builders/pdf_klant_builder.dart';
import 'builders/pdf_toestel_apparaat_builder.dart';
import 'builders/pdf_toestel_kenmerken_builder.dart';
import 'data/pdf_visit_data.dart';
import 'widgets/pdf_document_factory.dart';

/// Master orchestrator generating the official Flemish Reinigingsattest A4 PDF.
abstract final class CleaningPdfGenerator {
  /// Generates single-page A4 PDF bytes for the given [data].
  static Future<Uint8List> generateCertificate(PdfVisitData data) async {
    final pdf = await PdfDocumentFactory.createA4Document(
      title: 'Reinigingsattest Vlaanderen',
      author: data.firmaNaam,
    );

    pdf.addPage(
      pw.Page(
        pageTheme: PdfDocumentFactory.a4PageTheme(),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              CleaningHeaderBuilder.buildHeader(data),
              pw.SizedBox(height: 1.2),
              CleaningFirmaBuilder.buildFirmaSection(data),
              pw.SizedBox(height: 1.2),
              PdfKlantBuilder.buildKlantSection(data),
              pw.SizedBox(height: 1.2),
              PdfToestelKenmerkenBuilder.buildKenmerkenSection(data),
              pw.SizedBox(height: 1.2),
              PdfToestelApparaatBuilder.buildApparaatSection(data),
              pw.SizedBox(height: 1.2),
              CleaningControlsBuilder.buildFlueSection(data),
              pw.SizedBox(height: 1.2),
              CleaningControlsBuilder.buildBoilerSection(data),
              pw.SizedBox(height: 1.2),
              CleaningGebrekenBuilder.buildGebrekenSection(data),
              pw.SizedBox(height: 1.0),
              CleaningLegalFooterBuilder.buildLegalFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
