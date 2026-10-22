import 'package:pdf/widgets.dart' as pw;
import 'package:hvac_field_service/core/models/toestel_profile.dart';
import 'package:hvac_field_service/services/pdf/widgets/pdf_components.dart';

class PdfToestelApparaatBuilder {
  static pw.Widget buildApparaatSection(ToestelProfile toestel) {
    // TUNE HERE [UI/UX]: Master height for both boxes to keep them perfectly aligned.
    const double boxHeight = 58.0; 
    
    // TUNE HERE [UI/UX]: Adjust how much horizontal space the static black labels take up.
    // The Toestel labels are relatively short.
    const double toestelLabelWidth = 95.0; 
    
    // The Brander labels contain a very long string ('debiet (kW of kg/h of l/h of m³/h (gas)):').
    // Allocating 135 points gives it enough room so it doesn't wrap awkwardly.
    const double branderLabelWidth = 135.0; 

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Toestel)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text('Toestel', style: PdfComponents.titleBoldText),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0, right: 3.6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine('merk: ', toestel.toestelMerk, toestelLabelWidth),
                PdfComponents.buildDynamicLine('type: ', toestel.toestelType, toestelLabelWidth),
                PdfComponents.buildDynamicLine('bouwjaar: ', toestel.toestelBouwjaar, toestelLabelWidth),
                PdfComponents.buildDynamicLine('fabricatienummer: ', toestel.toestelFabNummer, toestelLabelWidth),
                PdfComponents.buildDynamicLine('nominaal vermogen (kW): ', toestel.toestelVermogen, toestelLabelWidth),
              ],
            ),
          ),
        ),

        // THE PERFECT CALIBRATED GAP
        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Brander)
        PdfComponents.halfWidthBox(
          titleContent: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: 'Brander ', style: PdfComponents.titleBoldText),
                pw.TextSpan(text: '(enkel CV)', style: PdfComponents.subTitleText),
              ],
            ),
          ),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0, right: 3.6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine('merk: ', toestel.branderMerk, branderLabelWidth),
                PdfComponents.buildDynamicLine('type: ', toestel.branderType, branderLabelWidth),
                PdfComponents.buildDynamicLine('bouwjaar: ', toestel.branderBouwjaar, branderLabelWidth),
                PdfComponents.buildDynamicLine('fabricatienummer: ', toestel.branderFabNummer, branderLabelWidth),
                PdfComponents.buildDynamicLine('debiet (kW of kg/h of l/h of m³/h (gas)): ', toestel.branderDebiet, branderLabelWidth),
              ],
            ),
          ),
        ),
      ],
    );
  }
}