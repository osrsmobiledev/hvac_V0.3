import 'dart:typed_data';
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
import 'widgets/pdf_document_factory.dart';

/// Master orchestrator generating the complete official Flemish Combustion Certificate A4 PDF.
abstract final class CombustionPdfGenerator {
  /// Generates the raw PDF bytes for the given [data].
  ///
  /// Fits strictly onto a single A4 page with 0.2pt borders, Libron typography,
  /// and 1-to-1 statutory fidelity to the official Flemish government template.
  static Future<Uint8List> generateCertificate(PdfVisitData data) async {
    final pdf = await PdfDocumentFactory.createA4Document(
      title: 'Verbrandingsattest Vlaanderen',
      author: data.firmaNaam,
    );

    pdf.addPage(
      pw.Page(
        pageTheme: PdfDocumentFactory.a4PageTheme(),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header (Onderhoud vs Keuring, Volgnummer)
              PdfHeaderBuilder.buildHeader(data),
              pw.SizedBox(height: 1.2),

              // 2. Firma & Technicus
              PdfFirmaBuilder.buildFirmaSection(data),
              pw.SizedBox(height: 1.2),

              // 3. Klant & Installatieadres
              PdfKlantBuilder.buildKlantSection(data),
              pw.SizedBox(height: 1.2),

              // 4. Kenmerken van het stooktoestel (Type B/C, brandstof, premix)
              PdfToestelKenmerkenBuilder.buildKenmerkenSection(data),
              pw.SizedBox(height: 1.2),

              // 5. Toestel & Brander apparaat specificaties
              PdfToestelApparaatBuilder.buildApparaatSection(data),
              pw.SizedBox(height: 1.2),

              // 6. Goede staat van werking (Metingen, Bacharach, Rookgassen)
              PdfMetingBuilder.buildMetingSection(data),
              pw.SizedBox(height: 1.2),

              // 7. Eindbeoordeling (Official Flemish Template Row 36)
              PdfEindbeoordelingBuilder.buildEindbeoordelingSection(data),
              pw.SizedBox(height: 1.2),

              // 8. Gebreken en maatregelen + Handtekeningen (Official Table 4)
              PdfGebrekenHandtekeningenBuilder.buildGebrekenSection(data),
              pw.SizedBox(height: 1.0),

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
