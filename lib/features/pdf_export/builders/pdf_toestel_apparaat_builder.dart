import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders the Toestel (left) and Brander (right) physical specifications.
abstract final class PdfToestelApparaatBuilder {
  static pw.Widget buildApparaatSection(PdfVisitData data) {
    const double boxHeight = 58.0;
    const double toestelLabelWidth = 95.0;
    const double branderLabelWidth = 135.0;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Toestel)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text('Toestel', style: PdfComponents.titleBoldText),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(
              left: 3.6,
              top: 2.0,
              bottom: 2.0,
              right: 3.6,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine(
                  'merk: ',
                  data.toestelMerk,
                  toestelLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'type: ',
                  data.toestelType,
                  toestelLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'bouwjaar: ',
                  data.toestelBouwjaar,
                  toestelLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'fabricatienummer: ',
                  data.toestelFabNummer,
                  toestelLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'nominaal vermogen (kW): ',
                  data.toestelVermogen,
                  toestelLabelWidth,
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Brander)
        PdfComponents.halfWidthBox(
          titleContent: pw.RichText(
            text: const pw.TextSpan(
              children: [
                pw.TextSpan(
                    text: 'Brander ', style: PdfComponents.titleBoldText),
                pw.TextSpan(
                    text: '(enkel CV)', style: PdfComponents.subTitleText),
              ],
            ),
          ),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(
              left: 3.6,
              top: 2.0,
              bottom: 2.0,
              right: 3.6,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine(
                  'merk: ',
                  data.branderMerk,
                  branderLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'type: ',
                  data.branderType,
                  branderLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'bouwjaar: ',
                  data.branderBouwjaar,
                  branderLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'fabricatienummer: ',
                  data.branderFabNummer,
                  branderLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'debiet (kW of kg/h of l/h of m³/h (gas)): ',
                  data.branderDebiet,
                  branderLabelWidth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
