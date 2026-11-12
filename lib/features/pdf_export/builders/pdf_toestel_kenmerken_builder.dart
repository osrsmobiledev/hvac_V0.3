import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders the Kenmerken van het stooktoestel (Type B/C, gas/oil/solid, premix) section.
abstract final class PdfToestelKenmerkenBuilder {
  static pw.Widget buildKenmerkenSection(PdfVisitData data) {
    const double lockedBoxHeight = 49.0;

    return PdfComponents.fullWidthBox(
      titleContent: pw.RichText(
        text: const pw.TextSpan(
          children: [
            pw.TextSpan(
              text: 'Kenmerken van het stooktoestel ',
              style: PdfComponents.titleBoldText,
            ),
            pw.TextSpan(
              text: '(kruis aan wat van toepassing is)',
              style: PdfComponents.subTitleText,
            ),
          ],
        ),
      ),
      contentHeight: lockedBoxHeight,
      mainContent: pw.Padding(
        padding: const pw.EdgeInsets.only(
          left: 3.6,
          right: 3.6,
          top: 0,
          bottom: 1.0,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // ROW 1
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                label: 'Centraal*:',
                isChecked: data.isCentraal,
                textStyle: PdfComponents.titleBoldText,
              ),
              _buildTypeBCheckbox(data),
              pw.SizedBox(),
              _buildTypeCCheckbox(data),
              pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '*indeling volgens NBN CR 1749',
                  style: PdfComponents.titleBoldText,
                ),
              ),
              merge2and3: true,
            ),

            // ROW 2: Gasvormig
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                label: 'Gasvormige brandstof:',
                isChecked: data.brandstofCat == 'gas',
                textStyle: PdfComponents.titleBoldText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'aardgas',
                isChecked: data.brandstofCat == 'gas' &&
                    data.gasType.toLowerCase().contains('aardgas'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'LPG',
                isChecked: data.brandstofCat == 'gas' &&
                    data.gasType.toLowerCase().contains('lpg'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckboxWithInput(
                label: 'andere, namelijk:',
                isChecked: data.brandstofCat == 'gas' &&
                    (data.gasType.toLowerCase().contains('andere') ||
                        data.gasAndereText.isNotEmpty),
                inputText: data.gasAndereText,
                textStyle: PdfComponents.titleText,
              ),
              pw.SizedBox(),
            ),

            // ROW 3: Gas Burner Tech
            _buildGridRow(
              pw.SizedBox(),
              PdfComponents.labeledCheckbox(
                label: 'niet-premix (GI)',
                isChecked: data.brandstofCat == 'gas' &&
                    data.branderTech.toLowerCase().contains('niet'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'premix (GI)',
                isChecked: data.brandstofCat == 'gas' &&
                    data.branderTech.toLowerCase().contains('premix') &&
                    !data.branderTech.toLowerCase().contains('niet'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'gasketel met ventilatorbrander (GII)',
                isChecked: data.brandstofCat == 'gas' &&
                    data.branderTech.toLowerCase().contains('ventilator'),
                textStyle: PdfComponents.titleText,
              ),
              pw.SizedBox(),
            ),

            // ROW 4: Vloeibaar
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                label: 'Vloeibare brandstof',
                isChecked: data.brandstofCat == 'vloeibaar',
                textStyle: PdfComponents.titleBoldText,
              ),
              pw.SizedBox(),
              pw.SizedBox(),
              pw.SizedBox(),
              pw.SizedBox(),
            ),

            // ROW 5: Vast
            _buildGridRow(
              PdfComponents.labeledCheckbox(
                label: 'Vaste brandstof:',
                isChecked: data.brandstofCat == 'vast',
                textStyle: PdfComponents.titleBoldText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'houtpellets',
                isChecked: data.brandstofCat == 'vast' &&
                    data.vastType.toLowerCase().contains('pellet'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'houtblokken',
                isChecked: data.brandstofCat == 'vast' &&
                    data.vastType.toLowerCase().contains('blok'),
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckboxWithInput(
                label: 'andere, namelijk:',
                isChecked: data.brandstofCat == 'vast' &&
                    (data.vastType.toLowerCase().contains('andere') ||
                        data.vastAndereText.isNotEmpty),
                inputText: data.vastAndereText,
                textStyle: PdfComponents.titleText,
              ),
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
    const double w1 = 105.0;
    const double w2 = 70.0;
    const double w3 = 75.0;
    const double w4 = 155.0;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfComponents.debugWrap(pw.SizedBox(width: w1, child: c1)),
        if (merge2and3) ...[
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

  static pw.Widget _buildTypeBCheckbox(PdfVisitData data) {
    final bRaw = data.typeBText.trim();
    final bSub =
        bRaw.toUpperCase().startsWith('B') ? bRaw.substring(1).trim() : bRaw;
    final hasBSub = bSub.isNotEmpty && data.centraalType == 'B';
    return PdfComponents.buildInlineInputCheckbox(
      prefix:
          hasBSub ? 'aangesloten als type B' : 'aangesloten als type B ',
      emptyPlaceholder: '.........',
      suffix: ' (open)',
      isChecked: data.centraalType == 'B',
      inputText: bSub,
      textStyle: PdfComponents.titleBoldText,
    );
  }

  static pw.Widget _buildTypeCCheckbox(PdfVisitData data) {
    final cRaw = data.typeCText.trim();
    final cSub =
        cRaw.toUpperCase().startsWith('C') ? cRaw.substring(1).trim() : cRaw;
    final hasCSub = cSub.isNotEmpty && data.centraalType == 'C';
    return PdfComponents.buildInlineInputCheckbox(
      prefix:
          hasCSub ? 'aangesloten als type C' : 'aangesloten als type C ',
      emptyPlaceholder: '.........',
      suffix: ' (gesloten)',
      isChecked: data.centraalType == 'C',
      inputText: cSub,
      textStyle: PdfComponents.titleBoldText,
    );
  }
}
