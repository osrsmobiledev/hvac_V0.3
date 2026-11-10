import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';
import 'pdf_meting_row_builders.dart';

/// Renders rows 21 through 24 and the "Veilige staat van werking" subheader.
abstract final class PdfMetingRowsSafety {
  static List<pw.Widget> buildRows(PdfVisitData data) {
    return [
      // SUB-HEADER: Veilige staat van werking
      PdfMetingRowBuilders.buildSubHeaderRow('Veilige staat van werking'),

      // ROW 21: druk rookgasafvoerkanaal (Pa)
      PdfMetingRowBuilders.buildDataRow(
        label: 'druk rookgasafvoerkanaal',
        unit: '',
        brandstof: '1, 2, 3',
        isMerged: true,
        rowHeight: 9.8,
        col2Color: PdfColors.grey200,
        customUnit: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.only(right: 2.0),
                child: pw.Text(
                  data.schouwtrekPa.isNotEmpty ? data.schouwtrekPa : '____',
                  style: PdfComponents.inputBlue,
                ),
              ),
            ),
            pw.Text('Pa', style: PdfComponents.titleText),
            pw.SizedBox(width: 2.0),
          ],
        ),
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.drukRookgasOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.drukRookgasOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),

      // ROW 22: verluchting en ventilatie
      PdfMetingRowBuilders.buildDataRow(
        label: 'verluchting en ventilatie stooklokaal',
        unit: '',
        brandstof: '1, 2, 3',
        isMerged: true,
        rowHeight: 9.8,
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.verluchtingStooklokaalOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.verluchtingStooklokaalOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),

      // ROW 23: dichtheid rookgasafvoerkanaal (Type C)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.RichText(
          text: const pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'dichtheid rookgasafvoerkanaal ',
                style: PdfComponents.titleText,
              ),
              pw.TextSpan(
                text: '(aangesloten als type C)',
                style: PdfComponents.subTitleText,
              ),
            ],
          ),
        ),
        unit: '',
        brandstof: '1, 2',
        isMerged: true,
        rowHeight: 9.8,
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.dichtheidRookgasafvoerOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.dichtheidRookgasafvoerOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),

      // ROW 24: dichtheid brandstoftoevoerleiding
      PdfMetingRowBuilders.buildDataRow(
        label: 'dichtheid brandstoftoevoerleiding (gasmeter tot stooktoestel)',
        unit: '',
        brandstof: '2',
        isMerged: true,
        rowHeight: 9.8,
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.dichtheidBrandstoftoevoerOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.dichtheidBrandstoftoevoerOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),
    ];
  }
}
