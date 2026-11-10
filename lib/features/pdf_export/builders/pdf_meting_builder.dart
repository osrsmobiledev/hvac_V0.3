import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';
import 'pdf_meting_header.dart';
import 'pdf_meting_rows_operating.dart';
import 'pdf_meting_rows_combustion.dart';
import 'pdf_meting_rows_safety.dart';

/// Master builder assembling the full-width measurement section (Goede staat van werking).
abstract final class PdfMetingBuilder {
  // Exact statutory height tuned from legacy template to house all 24 measurement and safety rows
  static const double boxHeight = 323.25;

  static pw.Widget buildMetingSection(PdfVisitData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        PdfComponents.fullWidthBox(
          titleHeight: 42.0,
          titlePadding: const pw.EdgeInsets.only(left: 3.6),
          titleContent: PdfMetingHeader.buildHeaderRow(data),
          contentHeight: boxHeight,
          mainContent: pw.Column(
            children: [
              ...PdfMetingRowsOperating.buildRows(data),
              ...PdfMetingRowsCombustion.buildRows(data),
              ...PdfMetingRowsSafety.buildRows(data),
            ],
          ),
        ),

        // Text footnote outside the box
        pw.Padding(
          padding: const pw.EdgeInsets.only(
            top: 1.0,
            bottom: 1.5,
            left: 2.0,
            right: 2.0,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '* Geeft het type toestel aan waarvoor de parameter moet worden berekend of gemeten',
                style: PdfComponents.subTitleText,
              ),
              pw.Text(
                '** Aanduiden welke meetreeksen van toepassing zijn',
                style: PdfComponents.subTitleText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
