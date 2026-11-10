import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';
import 'pdf_meting_row_builders.dart';

/// Renders the 42pt header banner for the measurement table with column definitions.
abstract final class PdfMetingHeader {
  static pw.Widget buildHeaderRow(PdfVisitData data) {
    const pw.BoxDecoration colDeco = pw.BoxDecoration(
      border: pw.Border(right: PdfComponents.borderSide),
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Col 1: Goede staat van werking + serial number
        pw.Container(
          width: PdfMetingRowBuilders.w1,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(right: 4.0, left: 2.0, bottom: 2.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4.0),
                child: pw.Text(
                  'Goede staat van werking',
                  style: PdfComponents.titleBoldText,
                ),
              ),
              if (data.meetToestelSerienummer.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1.0),
                  child: pw.Text(
                    'Meettoestel SN: ${data.meetToestelSerienummer}',
                    style: PdfComponents.subTitleText,
                  ),
                ),
              pw.Text(
                'De afdruk(ken) van het elektronische meettoestel moeten aan dit attest worden bevestigd.',
                style: PdfComponents.subTitleText,
              ),
            ],
          ),
        ),

        // Col 2: Eenheid
        pw.Container(
          width: PdfMetingRowBuilders.w2,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(left: 2.0),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('eenheid', style: PdfComponents.titleBoldText),
        ),

        // Col 3: Brandstof 1, 2, 3
        pw.Container(
          width: PdfMetingRowBuilders.w3,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(left: 2.0, top: 1.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Brandstof', style: PdfComponents.titleBoldText),
              ),
              pw.SizedBox(height: 1.0),
              pw.Text('1: vloeibaar', style: PdfComponents.subTitleText),
              pw.Text('2: gasvormig', style: PdfComponents.subTitleText),
              pw.Text('3: vast *', style: PdfComponents.subTitleText),
            ],
          ),
        ),

        // Col 4: Proef I (Initiële meting)
        pw.Container(
          width: PdfMetingRowBuilders.w4,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(left: 2.0, right: 2.0, top: 1.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Proef I:', style: PdfComponents.titleBoldText),
              pw.Text('Initiële meting', style: PdfComponents.titleBoldText),
            ],
          ),
        ),

        // Col 5: Proef II (Eindmeting met Laaglast / Hooglast)
        pw.Container(
          width: PdfMetingRowBuilders.w5,
          decoration: colDeco,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.only(left: 2.0, right: 2.0, top: 1.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Proef II:', style: PdfComponents.titleBoldText),
                    pw.Text('Eindmeting **',
                        style: PdfComponents.titleBoldText),
                  ],
                ),
              ),
              pw.Container(
                height: 10.0,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: PdfComponents.borderSide),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: PdfMetingRowBuilders.w5Laag,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(right: PdfComponents.borderSide),
                      ),
                      alignment: pw.Alignment.center,
                      child: PdfComponents.labeledCheckbox(
                        label: 'Laaglast',
                        isChecked: data.isLaaglastActive,
                        textStyle: PdfComponents.subTitleText,
                      ),
                    ),
                    pw.Container(
                      width: PdfMetingRowBuilders.w5Hoog,
                      alignment: pw.Alignment.center,
                      child: PdfComponents.labeledCheckbox(
                        label: 'Hooglast',
                        isChecked: data.isHooglastActive,
                        textStyle: PdfComponents.subTitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Col 6: OK
        pw.Container(
          width: PdfMetingRowBuilders.w6,
          decoration: colDeco,
          child: pw.Center(
            child: pw.Text('OK', style: PdfComponents.titleBoldText),
          ),
        ),

        // Col 7: Niet OK
        pw.Container(
          width: PdfMetingRowBuilders.w7,
          child: pw.Center(
            child: pw.Text(
              'Niet\nOK',
              style: PdfComponents.titleBoldText,
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
