import 'package:pdf/widgets.dart' as pw;
import '../../certificate_draft/domain/reiniging_controls_draft.dart';
import '../data/pdf_visit_data.dart';
import '../widgets/pdf_components.dart';

/// Renders the two statutory cleaning & inspection checklist sections of the
/// official Reinigingsattest Vlaanderen A4 PDF.
abstract final class CleaningControlsBuilder {
  /// Renders "Reiniging en controle van het rookgasafvoerkanaal".
  static pw.Widget buildFlueSection(PdfVisitData data) {
    final c = data.cleaning.controls;
    return PdfComponents.fullWidthBox(
      titleContent: pw.RichText(
        text: const pw.TextSpan(
          children: [
            pw.TextSpan(
              text: 'Reiniging en controle van het rookgasafvoerkanaal ',
              style: PdfComponents.titleBoldText,
            ),
            pw.TextSpan(
              text: '(erkend technicus of schoorsteenveger)',
              style: PdfComponents.subTitleText,
            ),
          ],
        ),
      ),
      contentHeight: 48.0,
      mainContent: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 3.6, vertical: 4.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            PdfComponents.labeledCheckbox(
              label: 'vegen van het rookgasafvoerkanaal en verbindingsstukken',
              isChecked: c.flueSweeping,
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label: 'nazicht van de goede werking',
              isChecked: c.flueGoodOperationCheck,
              textStyle: PdfComponents.titleText,
            ),
            PdfComponents.labeledCheckbox(
              label:
                  'controle van de terugslag door middel van een terugslagmelder',
              isChecked: c.flueBackdraftCheck,
              textStyle: PdfComponents.titleText,
            ),
          ],
        ),
      ),
    );
  }

  /// Renders "Reiniging van het stooktoestel" with all 4 fuel subgroups.
  static pw.Widget buildBoilerSection(PdfVisitData data) {
    final c = data.cleaning.controls;
    return PdfComponents.fullWidthBox(
      titleContent: pw.Text(
        'Reiniging van het stooktoestel',
        style: PdfComponents.titleBoldText,
      ),
      mainContent: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildGroupRow(
            groupTitle: 'Alle toestellen:',
            items: [
              _otherCheckbox(c),
              PdfComponents.labeledCheckbox(
                label: 'controle van de verluchting van het stooklokaal',
                isChecked: c.allVentilationCheck,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'controle van de rookgaszijdige dichtheid',
                isChecked: c.allFlueTightnessCheck,
                textStyle: PdfComponents.titleText,
              ),
            ],
            showBottomBorder: true,
          ),
          _buildGroupRow(
            groupTitle: 'Gasvormige brandstof:',
            groupSubtitle: '(erkend technicus)',
            items: [
              PdfComponents.labeledCheckbox(
                label: 'ontstoffing',
                isChecked: c.gasDustRemoval,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label:
                    'reiniging van de branderbedden en de warmtewisselaar (GI) of reinigen van de ketel (GII)',
                isChecked: c.gasBurnerBedExchanger,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'reiniging van de ventilator en de brander',
                isChecked: c.gasFanBurner,
                textStyle: PdfComponents.titleText,
              ),
            ],
            showBottomBorder: true,
          ),
          _buildGroupRow(
            groupTitle: 'Vloeibare brandstof:',
            groupSubtitle: '(erkend technicus)',
            items: [
              PdfComponents.labeledCheckbox(
                label: 'reiniging van de filters',
                isChecked: c.liquidFilters,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'reiniging van de ketel',
                isChecked: c.liquidBoiler,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'reiniging van de brander',
                isChecked: c.liquidBurner,
                textStyle: PdfComponents.titleText,
              ),
            ],
            showBottomBorder: true,
          ),
          _buildGroupRow(
            groupTitle: 'Vaste brandstof:',
            groupSubtitle: '(geschoold vakman)',
            items: [
              PdfComponents.labeledCheckbox(
                label: 'nazicht algemene staat',
                isChecked: c.solidGeneralCondition,
                textStyle: PdfComponents.titleText,
              ),
              PdfComponents.labeledCheckbox(
                label: 'reiniging inwendige delen warmtebron',
                isChecked: c.solidInternalCleaning,
                textStyle: PdfComponents.titleText,
              ),
            ],
            showBottomBorder: false,
          ),
        ],
      ),
    );
  }

  static pw.Widget _otherCheckbox(ReinigingControlsDraft c) {
    final otherText = c.allOtherChecked ? (c.allOtherText ?? '').trim() : '';
    return PdfComponents.labeledCheckboxWithInput(
      label: 'andere, namelijk:',
      isChecked: c.allOtherChecked,
      inputText: otherText,
      textStyle: PdfComponents.titleText,
    );
  }

  static pw.Widget _buildGroupRow({
    required String groupTitle,
    String? groupSubtitle,
    required List<pw.Widget> items,
    required bool showBottomBorder,
  }) {
    final rowHeight = items.length == 2 ? 30.0 : 42.0;
    return pw.Container(
      height: rowHeight,
      decoration: showBottomBorder
          ? const pw.BoxDecoration(
              border: pw.Border(bottom: PdfComponents.borderSide),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            width: 122.0,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 3.6,
              vertical: 3.5,
            ),
            alignment: pw.Alignment.topLeft,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(groupTitle, style: PdfComponents.titleBoldText),
                if (groupSubtitle != null) ...[
                  pw.SizedBox(height: 1.5),
                  pw.Text(groupSubtitle, style: PdfComponents.titleText),
                ],
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 3.6,
                vertical: 3.5,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
