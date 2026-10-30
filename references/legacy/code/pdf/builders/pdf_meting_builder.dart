import 'package:pdf/widgets.dart' as pw;
import 'package:hvac_field_service/core/models/meting_profile.dart';
import 'package:hvac_field_service/services/pdf/widgets/pdf_components.dart';
import 'package:pdf/pdf.dart';

class PdfMetingBuilder {
  static pw.Widget buildMetingSection(MetingProfile meting) {
    const double boxHeight =
        323.25; // TUNE HERE: Adjust this if your bottom border is slightly off

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // --- 1. THE MAIN BORDERED BOX ---
        PdfComponents.fullWidthBox(
          titleHeight: 42.0,
          titleContent: _buildHeaderRow(meting),
          contentHeight: boxHeight,
          mainContent: pw.Column(
            children: [
              // ROW 1: keteltemperatuur
              _buildDataRow(
                label: 'keteltemperatuur',
                unit: '°C',
                brandstof: '1,2',
                proef1: meting.ketelTemp,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 2: sproeier: merk en type
              _buildDataRow(
                label: 'sproeier: merk en type',
                unit: '',
                brandstof: '1',
                proef1: meting.sproeierMerkType,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 3: sproeier: debiet
              _buildDataRow(
                label: 'sproeier: debiet',
                unit: '',
                brandstof: '1',
                proef1: meting.sproeierDebiet,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 4: sproeier: hoek
              _buildDataRow(
                label: 'sproeier: hoek',
                unit: 'graden',
                brandstof: '1',
                proef1: meting.sproeierHoek,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 5: pompdruk
              _buildDataRow(
                label: 'pompdruk',
                unit: 'bar',
                brandstof: '1',
                proef1: meting.pompdrukBar,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 6: gasdruk teller
              _buildDataRow(
                customLabel: pw.Row(
                  children: [
                    pw.SizedBox(
                        width: 50.0,
                        child:
                            pw.Text('gasdruk', style: PdfComponents.titleText)),
                    pw.Text('teller', style: PdfComponents.titleText),
                  ],
                ),
                unit: 'mbar',
                brandstof: '2',
                proef1: meting.gasdrukTellerMbar,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 7: gasblok
              _buildDataRow(
                customLabel: pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 50.0), // Indent to align under 'teller'
                  child: pw.Text('gasblok', style: PdfComponents.titleText),
                ),
                unit: 'mbar',
                brandstof: '2',
                proef1: meting.gasdrukGasblokMbar,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 8: branderbed
              _buildDataRow(
                customLabel: pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 50.0), // Indent to align under 'teller'
                  child: pw.Text('branderbed', style: PdfComponents.titleText),
                ),
                unit: 'mbar',
                brandstof: '2',
                proef1: meting.gasdrukBranderbedMbar,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 9: rookindex (Bacharach) with Checkboxes
              _buildDataRow(
                label: 'rookindex',
                unit: 'Bacharach',
                brandstof: '1',
                proef1: meting.rookindexBacharach,
                customCol6: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked: meting.rookindexBeoordelingOk == 'OK'),
                ),
                customCol7: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked: meting.rookindexBeoordelingOk == 'Niet OK'),
                ),
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey300,
                col7Color: PdfColors.grey300,
              ),

              // ROW 10: zuurstof (O2)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('zuurstof (O', style: PdfComponents.titleText),
                    pw.Text('2',
                        style: pw.TextStyle(
                            fontSize:
                                4.5)), // Smaller font naturally aligns to baseline
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '%',
                brandstof: '1, 2',
                proef1: meting.proef1.zuurstofO2,
                proef2Laag: meting.proef2Laaglast.zuurstofO2,
                proef2Hoog: meting.proef2Hooglast.zuurstofO2,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 11: koolstofdioxide (CO2)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('koolstofdioxide (CO',
                        style: PdfComponents.titleText),
                    pw.Text('2', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '%',
                brandstof: '1, 2',
                proef1: meting.proef1.koolstofdioxideCO2,
                proef2Laag: meting.proef2Laaglast.koolstofdioxideCO2,
                proef2Hoog: meting.proef2Hooglast.koolstofdioxideCO2,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 12: koolstofmonoxide (CO)
              _buildDataRow(
                label: 'koolstofmonoxide (CO)',
                unit: 'mg/kWh',
                brandstof: '1, 2',
                proef1: meting.proef1.koolstofmonoxideCO,
                proef2Laag: meting.proef2Laaglast.koolstofmonoxideCO,
                proef2Hoog: meting.proef2Hooglast.koolstofmonoxideCO,
                customCol6: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked: meting.proef1.coBeoordelingOk == 'OK'),
                ),
                customCol7: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked: meting.proef1.coBeoordelingOk == 'Niet OK'),
                ),
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey300,
                col7Color: PdfColors.grey300,
              ),

              // ROW 13: rookgastemperatuur (tg)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('rookgastemperatuur (',
                        style: PdfComponents.titleText),
                    pw.Text('t',
                        style: pw.TextStyle(
                            fontSize: 7.0, fontStyle: pw.FontStyle.italic)),
                    pw.Text('g', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '°C',
                brandstof: '1, 2',
                proef1: meting.proef1.rookgasTempTg,
                proef2Laag: meting.proef2Laaglast.rookgasTempTg,
                proef2Hoog: meting.proef2Hooglast.rookgasTempTg,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 14: temperatuur verbrandingslucht (ta)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('temperatuur verbrandingslucht (',
                        style: PdfComponents.titleText),
                    pw.Text('t',
                        style: pw.TextStyle(
                            fontSize: 7.0, fontStyle: pw.FontStyle.italic)),
                    pw.Text('a', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '°C',
                brandstof: '1, 2',
                proef1: meting.proef1.verbrandingsluchtTempTa,
                proef2Laag: meting.proef2Laaglast.verbrandingsluchtTempTa,
                proef2Hoog: meting.proef2Hooglast.verbrandingsluchtTempTa,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 15: nettotemperatuur (tg - ta)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('nettotemperatuur (',
                        style: PdfComponents.titleText),
                    pw.Text('t',
                        style: pw.TextStyle(
                            fontSize: 7.0, fontStyle: pw.FontStyle.italic)),
                    pw.Text('g', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(' - ', style: PdfComponents.titleText),
                    pw.Text('t',
                        style: pw.TextStyle(
                            fontSize: 7.0, fontStyle: pw.FontStyle.italic)),
                    pw.Text('a', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '°C',
                brandstof: '1, 2',
                proef1: meting.proef1.nettoTemp,
                proef2Laag: meting.proef2Laaglast.nettoTemp,
                proef2Hoog: meting.proef2Hooglast.nettoTemp,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 16: verbrandingsrendement (Hi)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('verbrandingsrendement (H',
                        style: PdfComponents.titleText),
                    pw.Text('i', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '%',
                brandstof: '1, 2',
                proef1: meting.proef1.verbrandingsrendementHi,
                proef2Laag: meting.proef2Laaglast.verbrandingsrendementHi,
                proef2Hoog: meting.proef2Hooglast.verbrandingsrendementHi,
                customCol6: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked:
                          meting.proef1.rendementHiBeoordelingOk == 'OK'),
                ),
                customCol7: pw.Center(
                  child: PdfComponents.standaloneCheckbox(
                      isChecked:
                          meting.proef1.rendementHiBeoordelingOk == 'Niet OK'),
                ),
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey300,
                col7Color: PdfColors.grey300,
              ),

              // ROW 17: verbrandingsrendement (Hs)
              _buildDataRow(
                customLabel: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('verbrandingsrendement (H',
                        style: PdfComponents.titleText),
                    pw.Text('s', style: pw.TextStyle(fontSize: 4.5)),
                    pw.Text(')', style: PdfComponents.titleText),
                  ],
                ),
                unit: '%',
                brandstof: '1, 2',
                proef1: meting.proef1.verbrandingsrendementHs,
                proef2Laag: meting.proef2Laaglast.verbrandingsrendementHs,
                proef2Hoog: meting.proef2Hooglast.verbrandingsrendementHs,
                col4Color: PdfColors.grey200,
                col5Color: PdfColors.grey300,
                col6Color: PdfColors.grey400,
                col7Color: PdfColors.grey400,
              ),

              // ROW 18
              _buildDataRow(
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
                        isChecked: meting.geenOliespoorOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.geenOliespoorOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // ROW 19
              _buildDataRow(
                customLabel: pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text:
                            'geen ongewenste condensvorming in rookgasafvoerkanaal ',
                        style: PdfComponents.titleText),
                    pw.TextSpan(
                        text: '(aangesloten als type B)',
                        style: PdfComponents.subTitleText),
                  ]),
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
                        isChecked: meting.geenCondensatieOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.geenCondensatieOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // ROW 20
              _buildDataRow(
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
                        isChecked: meting.zeldenHinderlijkeRookOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.zeldenHinderlijkeRookOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // SUB-HEADER
              _buildSubHeaderRow('Veilige staat van werking'),

              // ROW 21: druk rookgasafvoerkanaal
              _buildDataRow(
                label: 'druk rookgasafvoerkanaal',
                unit: '',
                brandstof: '1, 2, 3',
                isMerged: true,
                rowHeight: 9.8,
                col2Color:
                    PdfColors.grey200, // The grey background in unit column
                customUnit: pw.Row(children: [
                  pw.Expanded(
                      child: pw.Container(
                    margin: const pw.EdgeInsets.only(
                        left: 2.0, right: 2.0, top: 6.0),
                    height: 0.5,
                    color: PdfColors.black, // The input line
                  )),
                  pw.Text('Pa', style: PdfComponents.titleText),
                  pw.SizedBox(width: 2.0),
                ]),
                col4Color: PdfColors.grey200,
                customProef1: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    PdfComponents.labeledCheckbox(
                        label: 'OK',
                        isChecked: meting.drukRookgasOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.drukRookgasOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // ROW 22: verluchting en ventilatie
              _buildDataRow(
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
                        isChecked: meting.verluchtingStooklokaalOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.verluchtingStooklokaalOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // ROW 23: dichtheid rookgasafvoerkanaal
              _buildDataRow(
                customLabel: pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: 'dichtheid rookgasafvoerkanaal ',
                      style: PdfComponents.titleText),
                  pw.TextSpan(
                      text: '(aangesloten als type C)',
                      style: PdfComponents.subTitleText),
                ])),
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
                        isChecked: meting.dichtheidRookgasafvoerOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked: meting.dichtheidRookgasafvoerOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),

              // ROW 24: dichtheid brandstoftoevoerleiding
              _buildDataRow(
                label:
                    'dichtheid brandstoftoevoerleiding (gasmeter tot stooktoestel)',
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
                        isChecked: meting.dichtheidBrandstoftoevoerOk == 'OK',
                        textStyle: PdfComponents.titleText),
                    PdfComponents.labeledCheckbox(
                        label: 'Niet OK',
                        isChecked:
                            meting.dichtheidBrandstoftoevoerOk == 'Niet OK',
                        textStyle: PdfComponents.titleText),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- 2. THE TEXT OUTSIDE THE BOX ---
        pw.Padding(
          padding: const pw.EdgeInsets.only(
              top: 2.0, bottom: 4.0, left: 2.0, right: 2.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  '* Geeft het type toestel aan waarvoor de parameter moet worden berekend of gemeten',
                  style: PdfComponents.subTitleText),
              pw.Text('** Aanduiden welke meetreeksen van toepassing zijn',
                  style: PdfComponents.subTitleText),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderRow(MetingProfile meting) {
    const double w1 = 272.3;
    const double w2 = 47.05;
    const double w3 = 47.05;
    const double w4 = 70.1;
    const double w5 = 70.1;
    const double w6 = 21.5;
    const double w7 = 21.1;

    final pw.BoxDecoration colDeco = pw.BoxDecoration(
      border: pw.Border(right: PdfComponents.borderSide),
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          width: w1,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(right: 4.0, left: 2.0, bottom: 2.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment
                .spaceBetween, // Distribute space instead of using Spacer
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4.0),
                child: pw.Text('Goede staat van werking',
                    style: PdfComponents.titleBoldText),
              ),
              // ACTION TRIGGER [UI/UX]: Displays the serial number if it exists
              if (meting.meetToestelSerienummer.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1.0),
                  child: pw.Text(
                      'Meettoestel SN: ${meting.meetToestelSerienummer}',
                      style: PdfComponents.subTitleText),
                ),
              pw.Text(
                'De afdruk(ken) van het elektronische meettoestel moeten aan dit attest worden bevestigd.',
                style: PdfComponents.subTitleText,
              ),
            ],
          ),
        ),
        pw.Container(
          width: w2,
          decoration: colDeco,
          padding: const pw.EdgeInsets.only(left: 2.0),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('eenheid', style: PdfComponents.titleBoldText),
        ),
        pw.Container(
          width: w3,
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
        pw.Container(
          width: w4,
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
        pw.Container(
          width: w5,
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
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: PdfComponents.borderSide),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border(right: PdfComponents.borderSide)),
                        alignment: pw.Alignment.center,
                        child: PdfComponents.labeledCheckbox(
                            label: 'Laaglast',
                            isChecked: false,
                            textStyle: PdfComponents.subTitleText),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        child: PdfComponents.labeledCheckbox(
                            label: 'Hooglast',
                            isChecked: false,
                            textStyle: PdfComponents.subTitleText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          width: w6,
          decoration: colDeco,
          child: pw.Center(
            child: pw.Text('OK', style: PdfComponents.titleBoldText),
          ),
        ),
        pw.Container(
          width: w7,
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

  static pw.Widget _buildSubHeaderRow(String title) {
    return pw.Container(
      height: 9.8,
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey300, // Matches the header grey
        border: pw.Border(
          bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
        ),
      ),
      padding: const pw.EdgeInsets.only(
          left: 5.6), // Aligns perfectly with w1 text (3.6 + 2.0)
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(title, style: PdfComponents.titleBoldText),
    );
  }

  // ACTION TRIGGER [ARCHITECTURE]: Reusable 7-column data row mapper
  static pw.Widget _buildDataRow({
    String label = '',
    pw.Widget? customLabel,
    required String unit,
    pw.Widget? customUnit,
    required String brandstof,
    String proef1 = '',
    pw.Widget? customProef1,
    String proef2Laag = '',
    String proef2Hoog = '',
    pw.Widget? customProef2,
    pw.Widget? customCol6,
    pw.Widget? customCol7,
    PdfColor? col2Color,
    PdfColor? col4Color,
    PdfColor? col5Color,
    PdfColor? col6Color,
    PdfColor? col7Color,
    bool isMerged = false,
    double rowHeight = 14.4,
  }) {
    const double w1 = 272.3;
    const double w2 = 47.05;
    const double w3 = 47.05;
    const double w4 = 70.1;
    const double w5 = 70.1;
    const double w6 = 21.5;
    const double w7 = 21.1;

    pw.Widget gridCell(
        {required double width,
        required pw.Widget child,
        bool rightBorder = true}) {
      return pw.Container(
        width: width,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: rightBorder ? PdfComponents.borderSide : pw.BorderSide.none,
          ),
        ),
        child: child,
      );
    }

    return pw.Container(
      height: rowHeight,
      // ACTION TRIGGER: Draw a top border on merged rows to paint OVER the upward background bleed!
      foregroundDecoration: pw.BoxDecoration(
        border: pw.Border(
          top: isMerged
              ? const pw.BorderSide(width: 0.2, color: PdfColors.black)
              : pw.BorderSide.none,
          bottom: const pw.BorderSide(width: 0.2, color: PdfColors.black),
        ),
      ),
      child: pw.Stack(
        children: [
          // LAYER 1: BACKGROUND COLORS (Natural stretch)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.SizedBox(width: w1),
                pw.Container(
                    width: w2,
                    color: col2Color), // Now supports the grey unit background
                pw.SizedBox(width: w3),
                if (isMerged)
                  // ACTION TRIGGER: Overdraw width by 0.5pt to tuck it safely under the master right border
                  pw.Container(width: w4 + w5 + w6 + w7 + 0.5, color: col4Color)
                else ...[
                  pw.Container(width: w4, color: col4Color),
                  pw.Container(width: w5, color: col5Color),
                  pw.Container(width: w6, color: col6Color),
                  // ACTION TRIGGER: Overdraw final column width by 0.5pt
                  pw.Container(width: w7 + 0.5, color: col7Color),
                ]
              ],
            ),
          ),

          // LAYER 2: VERTICAL BORDERS & TEXT
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                gridCell(
                    width: w1,
                    child: pw.Container(
                      padding: pw.EdgeInsets.only(
                          left: isMerged ? 1.5 : 2.0,
                          right: isMerged ? 1.0 : 0.0),
                      alignment: pw.Alignment.centerLeft,
                      child: isMerged
                          ? pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              alignment: pw.Alignment.centerLeft,
                              child: customLabel ??
                                  pw.Text(label,
                                      style: PdfComponents.titleText))
                          : (customLabel ??
                              pw.Text(label, style: PdfComponents.titleText)),
                    )),
                gridCell(
                    width: w2,
                    child: pw.Container(
                        padding: const pw.EdgeInsets.only(left: 2.0),
                        alignment: pw.Alignment.centerLeft,
                        child: customUnit ??
                            pw.Text(unit, style: PdfComponents.titleText))),
                gridCell(
                    width: w3,
                    child: pw.Container(
                        padding: const pw.EdgeInsets.only(left: 2.0),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(brandstof,
                            style: PdfComponents.titleText))),
                if (isMerged)
                  gridCell(
                      width: w4 + w5 + w6 + w7,
                      rightBorder: false,
                      child: customProef1 ?? pw.SizedBox())
                else ...[
                  gridCell(
                      width: w4,
                      child: customProef1 ??
                          pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Text(proef1,
                                  style: PdfComponents.inputBlue))),
                  gridCell(
                      width: w5,
                      child: customProef2 ??
                          pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                pw.Expanded(
                                    child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border(
                                                right:
                                                    PdfComponents.borderSide)),
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(proef2Laag,
                                            style: PdfComponents.inputBlue))),
                                pw.Expanded(
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(proef2Hoog,
                                            style: PdfComponents.inputBlue))),
                              ])),
                  gridCell(width: w6, child: customCol6 ?? pw.SizedBox()),
                  gridCell(
                      width: w7,
                      rightBorder: false,
                      child: customCol7 ?? pw.SizedBox()),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
