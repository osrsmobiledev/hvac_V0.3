import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/pdf_visit_data.dart';
import '../widgets/pdf_components.dart';
import 'pdf_firma_builder.dart';
import 'pdf_gebreken_handtekeningen_builder.dart';

/// Renders "Gebreken en maatregelen", edge-to-edge grey dual next-inspection
/// date band, and technician/customer signatures for Reinigingsattest.
abstract final class CleaningGebrekenBuilder {
  static pw.Widget buildGebrekenSection(PdfVisitData data) {
    final defects = PdfGebrekenHandtekeningenBuilder.formatInlineItems(
      data.gebrekenOpmerkingen,
    );
    final measures = PdfGebrekenHandtekeningenBuilder.formatInlineItems(
      data.cleaning.remedialMeasuresNotes,
    );
    final remarks = PdfGebrekenHandtekeningenBuilder.formatInlineItems(
      data.andereOpmerkingen,
    );

    return PdfComponents.fullWidthBox(
      titleHeight: 9.8,
      titleContent: pw.Text(
        'Gebreken en maatregelen',
        style: PdfComponents.titleBoldText,
      ),
      contentHeight: 202.0,
      mainContent: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Zone 1: Bounded 3-field notes area (112pt)
          pw.Container(
            height: 112.0,
            padding: const pw.EdgeInsets.fromLTRB(4.0, 2.5, 4.0, 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildNoteBlock(
                  label:
                      'Gebreken die niet door de reinigingsbeurt kunnen worden weggewerkt:',
                  value: defects,
                  emptyFallback: 'Geen tekortkomingen vastgesteld.',
                ),
                _buildNoteBlock(
                  label:
                      'Te treffen maatregelen om deze gebreken weg te werken:',
                  value: measures,
                  emptyFallback: 'Geen.',
                ),
                _buildNoteBlock(
                  label: 'Andere opmerkingen:',
                  value: remarks,
                  emptyFallback: 'Geen.',
                ),
              ],
            ),
          ),

          // Zone 2: Edge-to-edge grey dual next-inspection date band (32pt)
          pw.Container(
            height: 32.0,
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 4.0,
              vertical: 3.5,
            ),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                top: PdfComponents.borderSide,
                bottom: PdfComponents.borderSide,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildNextDateLine(
                  'De eerstvolgende reiniging van het stooktoestel moet gebeuren vóór',
                  data.volgendeControleDatum,
                ),
                _buildNextDateLine(
                  'De eerstvolgende reiniging en controle van het rookgasafvoerkanaal moet gebeuren vóór',
                  data.cleaning.nextChimneyInspectionDate,
                ),
              ],
            ),
          ),

          // Zone 3: Signatures Row filling exact remaining height (58pt)
          pw.Expanded(child: _buildSignaturesRow(data)),
        ],
      ),
    );
  }

  static pw.Widget _buildNoteBlock({
    required String label,
    required String value,
    required String emptyFallback,
  }) {
    final hasValue = value.isNotEmpty;
    return pw.SizedBox(
      height: 34.5,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 5.8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 1.0),
            child: pw.Text(
              hasValue ? value : emptyFallback,
              style: hasValue
                  ? const pw.TextStyle(fontSize: 5.4, color: PdfColors.blue800)
                  : const pw.TextStyle(
                      fontSize: 5.4,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNextDateLine(String label, String rawDate) {
    final date = PdfFirmaBuilder.formatDate(rawDate, emptyFallback: '');
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          child: pw.Text(label, style: PdfComponents.titleBoldText),
        ),
        pw.SizedBox(
          width: 122.0,
          child: pw.Text(
            date.isNotEmpty ? date : '_______-________-___________',
            style: date.isNotEmpty
                ? PdfComponents.inputBlue
                : PdfComponents.titleText,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignaturesRow(PdfVisitData data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          width: 315.9,
          padding: const pw.EdgeInsets.fromLTRB(4.0, 2.5, 4.0, 2.0),
          decoration: const pw.BoxDecoration(
            border: pw.Border(right: PdfComponents.borderSide),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '(handtekening erkende technicus (gas of stookolie) / geschoolde vakman (vaste brandstof))',
                style: const pw.TextStyle(
                  fontSize: 5.0,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Expanded(
                child: pw.Center(
                  child: (data.technicusHandtekeningBytes != null &&
                          data.technicusHandtekeningBytes!.isNotEmpty)
                      ? PdfGebrekenHandtekeningenBuilder
                          .buildSafeSignatureImage(
                          data.technicusHandtekeningBytes!,
                        )
                      : pw.Text(
                          '(Nog niet ondertekend)',
                          style: PdfComponents.subTitleText,
                        ),
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(4.0, 2.5, 4.0, 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'voor kennisname (handtekening klant)',
                  style: const pw.TextStyle(
                    fontSize: 5.0,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: PdfGebrekenHandtekeningenBuilder
                        .buildCustomerSignatureArea(data),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
