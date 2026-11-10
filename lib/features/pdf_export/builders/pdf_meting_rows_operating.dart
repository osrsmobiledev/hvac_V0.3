import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';
import 'pdf_meting_row_builders.dart';

/// Renders rows 1 through 13 of the measurement table (Operating pressures, Bacharach, O2, CO2, CO).
abstract final class PdfMetingRowsOperating {
  static List<pw.Widget> buildRows(PdfVisitData data) {
    return [
      // ROW 1: keteltemperatuur
      PdfMetingRowBuilders.buildDataRow(
        label: 'keteltemperatuur',
        unit: '°C',
        brandstof: '1,2',
        proef1: data.ketelTemp,
        proef2Laag: data.ketelTemp,
        proef2Hoog: data.isHooglastActive ? data.ketelTemp : '',
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 2: sproeier: merk en type
      PdfMetingRowBuilders.buildDataRow(
        label: 'sproeier: merk en type',
        unit: '',
        brandstof: '1',
        proef1: data.sproeierMerkType,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 3: sproeier: debiet
      PdfMetingRowBuilders.buildDataRow(
        label: 'sproeier: debiet',
        unit: '',
        brandstof: '1',
        proef1: data.sproeierDebiet,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 4: sproeier: hoek
      PdfMetingRowBuilders.buildDataRow(
        label: 'sproeier: hoek',
        unit: 'graden',
        brandstof: '1',
        proef1: data.sproeierHoek,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 5: pompdruk
      PdfMetingRowBuilders.buildDataRow(
        label: 'pompdruk',
        unit: 'bar',
        brandstof: '1',
        proef1: data.pompdrukBar,
        proef2Laag: data.pompdrukBar,
        proef2Hoog: data.isHooglastActive ? data.pompdrukBar : '',
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 6: gasdruk teller
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          children: [
            pw.SizedBox(
              width: 50.0,
              child: pw.Text('gasdruk', style: PdfComponents.titleText),
            ),
            pw.Text('teller', style: PdfComponents.titleText),
          ],
        ),
        unit: 'mbar',
        brandstof: '2',
        proef1: data.gasdrukTellerMbar,
        proef2Laag: data.gasdrukTellerMbar,
        proef2Hoog: data.isHooglastActive ? data.gasdrukTellerMbar : '',
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 7: gasblok
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 50.0),
          child: pw.Text('gasblok', style: PdfComponents.titleText),
        ),
        unit: 'mbar',
        brandstof: '2',
        proef1: data.gasdrukGasblokMbar,
        proef2Laag: data.gasdrukGasblokMbar,
        proef2Hoog: data.isHooglastActive ? data.gasdrukGasblokMbar : '',
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 8: branderbed
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 50.0),
          child: pw.Text('branderbed', style: PdfComponents.titleText),
        ),
        unit: 'mbar',
        brandstof: '2',
        proef1: data.gasdrukBranderbedMbar,
        proef2Laag: data.gasdrukBranderbedMbar,
        proef2Hoog: data.isHooglastActive ? data.gasdrukBranderbedMbar : '',
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 9: rookindex (Bacharach) with Checkboxes
      PdfMetingRowBuilders.buildDataRow(
        label: 'rookindex',
        unit: 'Bacharach',
        brandstof: '1',
        proef1: data.rookindexBacharach,
        customCol6: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.rookindexBeoordelingOk == 'OK',
          ),
        ),
        customCol7: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.rookindexBeoordelingOk == 'Niet OK',
          ),
        ),
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey300,
        col7Color: PdfColors.grey300,
      ),

      // ROW 10: zuurstof (O2)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('zuurstof (O', style: PdfComponents.titleText),
            pw.Text('2', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '%',
        brandstof: '1, 2',
        proef1: data.proef1O2,
        proef2Laag: data.proef2LaagO2,
        proef2Hoog: data.proef2HoogO2,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 11: koolstofdioxide (CO2)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('koolstofdioxide (CO', style: PdfComponents.titleText),
            pw.Text('2', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '%',
        brandstof: '1, 2',
        proef1: data.proef1Co2,
        proef2Laag: data.proef2LaagCo2,
        proef2Hoog: data.proef2HoogCo2,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),

      // ROW 12: koolstofmonoxide (CO)
      PdfMetingRowBuilders.buildDataRow(
        label: 'koolstofmonoxide (CO)',
        unit: 'mg/kWh',
        brandstof: '1, 2',
        proef1: data.proef1Co,
        proef2Laag: data.proef2LaagCo,
        proef2Hoog: data.proef2HoogCo,
        customCol6: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.proef1CoOk == 'OK',
          ),
        ),
        customCol7: pw.Center(
          child: PdfComponents.standaloneCheckbox(
            isChecked: data.proef1CoOk == 'Niet OK',
          ),
        ),
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey300,
        col7Color: PdfColors.grey300,
      ),

      // ROW 13: rookgastemperatuur (tg)
      PdfMetingRowBuilders.buildDataRow(
        customLabel: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('rookgastemperatuur (', style: PdfComponents.titleText),
            pw.Text(
              't',
              style: const pw.TextStyle(
                fontSize: 7.0,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Text('g', style: const pw.TextStyle(fontSize: 4.5)),
            pw.Text(')', style: PdfComponents.titleText),
          ],
        ),
        unit: '°C',
        brandstof: '1, 2',
        proef1: data.proef1Tg,
        proef2Laag: data.proef2LaagTg,
        proef2Hoog: data.proef2HoogTg,
        col4Color: PdfColors.grey200,
        col5Color: PdfColors.grey300,
        col6Color: PdfColors.grey400,
        col7Color: PdfColors.grey400,
      ),
    ];
  }
}
