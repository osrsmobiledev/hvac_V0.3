import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';
import 'pdf_meting_row_builders.dart';

/// Renders rows 14 through 20 of the measurement table (Combustion efficiency & observations).
abstract final class PdfMetingRowsCombustion {
  static List<pw.Widget> buildRows(PdfVisitData data) {
    return [
      // ROW 14: temperatuur verbrandingslucht (ta)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'temperatuur verbrandingslucht (',
              style: PdfComponents.titleText,
            ),
            pw.Text(
              't',
              style: const pw.TextStyle(
                fontSize: 7.0,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Text('a', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '°C',
        brandstof: '1, 2',
        proef1: data.proef1Ta,
        proef2Laag: data.proef2LaagTa,
        proef2Hoog: data.proef2HoogTa,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 15: nettotemperatuur (tg - ta)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('nettotemperatuur (', style: PdfComponents.titleText),
            pw.Text(
              't',
              style: const pw.TextStyle(
                fontSize: 7.0,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Text('g', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(' - ', style: PdfComponents.titleText),
            pw.Text(
              't',
              style: const pw.TextStyle(
                fontSize: 7.0,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Text('a', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '°C',
        brandstof: '1, 2',
        proef1: data.proef1NettoTemp,
        proef2Laag: data.proef2LaagNettoTemp,
        proef2Hoog: data.proef2HoogNettoTemp,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 16: verbrandingsrendement (Hi)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('verbrandingsrendement (H', style: PdfComponents.titleText),
            pw.Text('i', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '%',
        brandstof: '1, 2',
        proef1: data.proef1RendementHi,
        proef2Laag: data.proef2LaagRendementHi,
        proef2Hoog: data.proef2HoogRendementHi,
        customCol6: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.proef1RendementHiOk == 'OK',
          ),
        ),
        customCol7: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.proef1RendementHiOk == 'Niet OK',
          ),
        ),
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey300,
        col7Color: PdfColors.grey300,
      ),

      // ROW 17: verbrandingsrendement (Hs)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('verbrandingsrendement (H', style: PdfComponents.titleText),
            pw.Text('s', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '%',
        brandstof: '1, 2',
        proef1: data.proef1RendementHs,
        proef2Laag: data.proef2LaagRendementHs,
        proef2Hoog: data.proef2HoogRendementHs,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 18: geen oliespoor
      PdfMetingRowBuilders.buildDataRow(
        label: 'geen zichtbaar oliespoor bij rookindexbepaling',
        unit: '',
        brandstof: '1',
        isMerged: true,
        rowHeight: 9.8,
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.geenOliespoorOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.geenOliespoorOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),

      // ROW 19: geen condensvorming
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.RichText(
          text: const pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'geen ongewenste condensvorming in rookgasafvoerkanaal ',
                style: PdfComponents.titleText,
              ),
              pw.TextSpan(
                text: '(aangesloten als type B)',
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
              isChecked: data.geenCondensatieOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.geenCondensatieOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),

      // ROW 20: zelden hinderlijke rook
      PdfMetingRowBuilders.buildDataRow(
        label: 'zelden hinderlijke en milieuverontreinigende rook',
        unit: '',
        brandstof: '3',
        isMerged: true,
        rowHeight: 9.8,
        col4Color: PdfColors.grey200,
        customProef1: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'OK',
              isChecked: data.zeldenHinderlijkeRookOk == 'OK',
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'Niet OK',
              isChecked: data.zeldenHinderlijkeRookOk == 'Niet OK',
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),
    ];
  }
}
