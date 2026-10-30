import 'package:pdf/widgets.dart' as pw;
import 'package:hvac_field_service/services/pdf/widgets/pdf_components.dart';
import 'package:hvac_field_service/core/models/toestel_profile.dart';

class PdfToestelKenmerkenBuilder {
  static pw.Widget buildKenmerkenSection(ToestelProfile toestel) {
    // TUNE HERE [UI/UX]: 'lockedBoxHeight' forces the main bounding box to a strict height.
    // If the bottom row clips or touches the border, increase this (e.g., from 49.0 to 52.0).
    const double lockedBoxHeight = 49.0;

    return PdfComponents.fullWidthBox(
      titleContent: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
                text: 'Kenmerken van het stooktoestel ',
                style: PdfComponents.titleBoldText),
            pw.TextSpan(
                text: '(kruis aan wat van toepassing is)',
                style: PdfComponents.subTitleText),
          ],
        ),
      ),
      contentHeight: lockedBoxHeight,
      mainContent: pw.Padding(
        // TUNE HERE [UI/UX]: 'left' and 'right' padding controls how close the text gets to the outer walls.
        // The top and bottom are currently 0 so the rows can stretch fully.
        padding: const pw.EdgeInsets.only(
            left: 3.6, right: 3.6, top: 0, bottom: 1.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          // TUNE HERE [UI/UX]: 'spaceBetween' automatically spreads the 5 rows evenly across the lockedBoxHeight.
          // If you want them clumped at the top instead, change this to pw.MainAxisAlignment.start and add pw.SizedBox(height: 2) between the rows below.
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // ROW 1
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                  label: 'Centraal*:',
                  isChecked: toestel.isCentraal,
                  textStyle: PdfComponents.titleBoldText),
              PdfComponents.buildInlineInputCheckbox(
                prefix: 'aangesloten als type B ',
                emptyPlaceholder: '.........',
                suffix: ' (open)',
                isChecked: toestel.centraalType == 'B',
                inputText: toestel.typeBText,
                textStyle: PdfComponents.titleBoldText,
              ),
              pw.SizedBox(),
              PdfComponents.buildInlineInputCheckbox(
                prefix: 'aangesloten als type C ',
                emptyPlaceholder: '.........',
                suffix: ' (gesloten)',
                isChecked: toestel.centraalType == 'C',
                inputText: toestel.typeCText,
                textStyle: PdfComponents.titleBoldText,
              ),
              pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerRight,
                child: pw.Text('*indeling volgens NBN CR 1749',
                    style: PdfComponents.titleBoldText),
              ),
              merge2and3: true,
            ),

            // ROW 2
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                  label: 'Gasvormige brandstof:',
                  isChecked: toestel.brandstofCat == 'gas',
                  textStyle: PdfComponents.titleBoldText),
              PdfComponents.labeledCheckbox(
                  label: 'aardgas',
                  isChecked: toestel.brandstofCat == 'gas' &&
                      toestel.gasType == 'aardgas',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckbox(
                  label: 'LPG',
                  isChecked:
                      toestel.brandstofCat == 'gas' && toestel.gasType == 'LPG',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckboxWithInput(
                  label: 'andere, namelijk:',
                  isChecked: toestel.brandstofCat == 'gas' &&
                      toestel.gasType == 'Andere',
                  inputText: toestel.gasAndereText,
                  textStyle: PdfComponents.titleText),
              pw.SizedBox(),
            ),

            // ROW 3
            _buildGridRow(
              pw.SizedBox(),
              PdfComponents.labeledCheckbox(
                  label: 'niet-premix (GI)',
                  isChecked: toestel.brandstofCat == 'gas' &&
                      toestel.branderTech == 'niet-premix (GI)',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckbox(
                  label: 'premix (GI)',
                  isChecked: toestel.brandstofCat == 'gas' &&
                      toestel.branderTech == 'premix (GI)',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckbox(
                  label: 'gasketel met ventilatorbrander (GII)',
                  isChecked: toestel.brandstofCat == 'gas' &&
                      toestel.branderTech ==
                          'gasketel met ventilatorbrander (GII)',
                  textStyle: PdfComponents.titleText),
              pw.SizedBox(),
            ),

            // ROW 4
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                  label: 'Vloeibare brandstof',
                  isChecked: toestel.brandstofCat == 'vloeibaar',
                  textStyle: PdfComponents.titleBoldText),
              pw.SizedBox(),
              pw.SizedBox(),
              pw.SizedBox(),
              pw.SizedBox(),
            ),

            // ROW 5
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                  label: 'Vaste brandstof:',
                  isChecked: toestel.brandstofCat == 'vast',
                  textStyle: PdfComponents.titleBoldText),
              PdfComponents.labeledCheckbox(
                  label: 'houtpellets',
                  isChecked: toestel.brandstofCat == 'vast' &&
                      toestel.vastType == 'houtpellets',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckbox(
                  label: 'houtblokken',
                  isChecked: toestel.brandstofCat == 'vast' &&
                      toestel.vastType == 'houtblokken',
                  textStyle: PdfComponents.titleText),
              PdfComponents.labeledCheckboxWithInput(
                  label: 'andere, namelijk:',
                  isChecked: toestel.brandstofCat == 'vast' &&
                      toestel.vastType == 'Andere',
                  inputText: toestel.vastAndereText,
                  textStyle: PdfComponents.titleText),
              pw.SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildGridRow(
    pw.Widget c1,
    pw.Widget c2,
    pw.Widget c3,
    pw.Widget c4,
    pw.Widget c5, {
    bool merge2and3 = false,
  }) {
    // TUNE HERE [UI/UX]: These 4 widths define the start position of every column.
    // They must add up to roughly 405.0 to leave enough room for Column 5 on the far right.

    // Adjust 'w1' to change the width of Column 1 (e.g., 'Gasvormige brandstof:').
    // Increasing it pushes Column 2 further to the right.
    const double w1 = 105.0;

    // Adjust 'w2' to push Column 3 ('LPG' / 'premix') left or right.
    const double w2 = 70.0;

    // Adjust 'w3' to push Column 4 ('andere, namelijk:') left or right.
    const double w3 = 75.0;

    // Adjust 'w4' to give Column 4 more room before Column 5 (*indeling volgens NBN) starts.
    const double w4 = 155.0;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfComponents.debugWrap(pw.SizedBox(width: w1, child: c1)),
        if (merge2and3) ...[
          // When merge2and3 is true (Row 1), Column 2 spans across both w2 and w3 to fit the long "Type B" text.
          PdfComponents.debugWrap(pw.SizedBox(width: w2 + w3, child: c2)),
        ] else ...[
          PdfComponents.debugWrap(pw.SizedBox(width: w2, child: c2)),
          PdfComponents.debugWrap(pw.SizedBox(width: w3, child: c3)),
        ],
        PdfComponents.debugWrap(pw.SizedBox(width: w4, child: c4)),
        PdfComponents.debugWrap(pw.Expanded(child: c5)),
      ],
    );
  }
}
