import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/pdf_visit_data.dart';
import '../widgets/pdf_components.dart';
import 'pdf_firma_builder.dart';

/// Renders the Firma (left) and Technicus with role checkboxes (right) section
/// for the official Reinigingsattest Vlaanderen A4 PDF.
abstract final class CleaningFirmaBuilder {
  static pw.Widget buildFirmaSection(PdfVisitData data) {
    const double technicusLabelWidth = 95.0;
    const double subLabelWidth = 91.5;
    const double boxHeight = 76.0;

    final isErkend = data.cleaning.technicianRoleErkend;
    final gvFormatted = isErkend
        ? PdfFirmaBuilder.formatErkenningsnummer(data.technicusGv, 'GV')
        : '';
    final tvFormatted = isErkend
        ? PdfFirmaBuilder.formatErkenningsnummer(data.technicusTv, 'TV')
        : '';
    final fullTechName =
        '${data.technicusVoornaam} ${data.technicusAchternaam}'.trim();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfFirmaBuilder.buildFirmaColumn(data, boxHeight: boxHeight),
        pw.SizedBox(width: 1.4),
        // RIGHT COLUMN (Technicus + Roles + Datum reiniging)
        PdfComponents.halfWidthBox(
          titleContent:
              pw.Text('Technicus', style: PdfComponents.titleBoldText),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(3.6, 2.0, 3.6, 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine(
                  'voornaam en achternaam: ',
                  fullTechName,
                  technicusLabelWidth,
                ),
                _buildErkendRow(
                  isChecked: isErkend,
                  gv: gvFormatted,
                  tv: tvFormatted,
                ),
                PdfComponents.labeledCheckbox(
                  label: 'schoorsteenveger',
                  isChecked: data.cleaning.technicianRoleSchoorsteenveger,
                  textStyle: PdfComponents.titleText,
                ),
                _buildDateTimeBox(data, subLabelWidth),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildErkendRow({
    required bool isChecked,
    required String gv,
    required String tv,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        PdfComponents.labeledCheckbox(
          label: 'erkend technicus: ',
          isChecked: isChecked,
          textStyle: PdfComponents.titleText,
        ),
        pw.RichText(
          text: pw.TextSpan(
            style: PdfComponents.titleText,
            children: [
              if (gv.isNotEmpty)
                pw.TextSpan(text: gv, style: PdfComponents.inputBlue)
              else
                const pw.TextSpan(text: 'GV _____________'),
              const pw.TextSpan(text: ' / '),
              if (tv.isNotEmpty)
                pw.TextSpan(text: tv, style: PdfComponents.inputBlue)
              else
                const pw.TextSpan(text: 'TV _________________'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDateTimeBox(PdfVisitData data, double labelWidth) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3.6, vertical: 2.0),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        border: pw.Border.all(
          color: PdfComponents.borderSide.color,
          width: PdfComponents.borderSide.width,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: labelWidth,
                child: pw.Text(
                  'Datum reiniging: ',
                  style: PdfComponents.titleBoldText,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  PdfFirmaBuilder.formatDate(
                    data.datumOnderhoud,
                    emptyFallback: '_____-_____-________',
                  ),
                  style: data.datumOnderhoud.trim().isNotEmpty
                      ? PdfComponents.inputBlue
                      : PdfComponents.titleText,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2.0),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: labelWidth,
                child: pw.Text(
                  'Arbeidsduur: ',
                  style: PdfComponents.titleBoldText,
                ),
              ),
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                          text: 'van ', style: PdfComponents.titleText),
                      pw.TextSpan(
                        text: data.arbeidsduurVan.isNotEmpty
                            ? data.arbeidsduurVan
                            : '_________',
                        style: data.arbeidsduurVan.isNotEmpty
                            ? PdfComponents.inputBlue
                            : PdfComponents.titleText,
                      ),
                      const pw.TextSpan(
                          text: ' tot ', style: PdfComponents.titleText),
                      pw.TextSpan(
                        text: data.arbeidsduurTot.isNotEmpty
                            ? data.arbeidsduurTot
                            : '__________',
                        style: data.arbeidsduurTot.isNotEmpty
                            ? PdfComponents.inputBlue
                            : PdfComponents.titleText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
