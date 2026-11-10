import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../widgets/pdf_theme_tokens.dart';
import '../data/pdf_visit_data.dart';

/// Renders the statutory "Eindbeoordeling" section matching Row 36 of the official Flemish template.
abstract final class PdfEindbeoordelingBuilder {
  static const double boxHeight = 34.0;

  static pw.Widget buildEindbeoordelingSection(PdfVisitData data) {
    final bool isGoed = data.toestelWerkingGoed.toLowerCase() == 'goed';
    final bool isNietGoed =
        data.toestelWerkingGoed.toLowerCase().contains('niet');
    final bool isVeilig = data.toestelWerkingVeilig.toLowerCase() == 'veilig';
    final bool isNietVeilig =
        data.toestelWerkingVeilig.toLowerCase().contains('niet');

    return pw.Container(
      height: boxHeight,
      width: PdfThemeTokens.fullWidth,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfComponents.borderSide.color,
          width: PdfComponents.borderSide.width,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Col 1: Title & Subtitle (w = 106.5 pt)
          pw.Container(
            width: 106.5,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                right: pw.BorderSide(width: 0.2, color: PdfColors.black),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Eindbeoordeling', style: PdfComponents.titleBoldText),
                pw.Text('(kruis aan wat van toepassing is)',
                    style: PdfComponents.subTitleText),
              ],
            ),
          ),

          // Col 2: Het stooktoestel werkt (w = 160.0 pt)
          pw.Container(
            width: 160.0,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(width: 0.2, color: PdfColors.black),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Het stooktoestel werkt',
                    style: PdfComponents.titleBoldText),
                pw.SizedBox(height: 1.5),
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 68.0,
                      child: PdfComponents.labeledCheckbox(
                        label: 'goed',
                        isChecked: isGoed,
                        textStyle: PdfComponents.titleText,
                      ),
                    ),
                    PdfComponents.labeledCheckbox(
                      label: 'veilig',
                      isChecked: isVeilig,
                      textStyle: PdfComponents.titleText,
                    ),
                  ],
                ),
                pw.SizedBox(height: 1.5),
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 68.0,
                      child: PdfComponents.labeledCheckbox(
                        label: 'niet goed',
                        isChecked: isNietGoed,
                        textStyle: PdfComponents.titleText,
                      ),
                    ),
                    PdfComponents.labeledCheckbox(
                      label: 'niet veilig',
                      isChecked: isNietVeilig,
                      textStyle: PdfComponents.titleText,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Col 3: Eerstvolgende verbrandingscontrole vóór (remaining width = 286.4 pt)
          pw.Expanded(
            child: pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Eerstvolgende verbrandingscontrole vóór:',
                    style: PdfComponents.titleBoldText,
                  ),
                  pw.SizedBox(height: 2.0),
                  pw.Text(
                    data.volgendeControleDatum.isNotEmpty
                        ? data.volgendeControleDatum
                        : '__________-__________-_______________',
                    style: PdfComponents.inputBlue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
