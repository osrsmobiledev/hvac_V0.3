import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/pdf_visit_data.dart';
import '../widgets/pdf_components.dart';
import '../widgets/pdf_theme_tokens.dart';

/// Renders the official grey REINIGINGSATTEST title banner.
abstract final class CleaningHeaderBuilder {
  static pw.Widget buildHeader(PdfVisitData data) {
    final String volgnummer = data.volgnummerAttest.isNotEmpty
        ? data.volgnummerAttest
        : '                    ';

    return pw.Container(
      width: PdfThemeTokens.fullWidth,
      height: 11.0,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3.6),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey400,
        border: pw.Border.all(
          color: PdfComponents.borderSide.color,
          width: PdfComponents.borderSide.width,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text('REINIGINGSATTEST', style: PdfComponents.titleBoldText),
          pw.Spacer(flex: 2), // gate-1d-ok: horizontal header row spacer
          PdfComponents.labeledCheckbox(
            label: 'onderhoud centraal stooktoestel',
            isChecked: true,
            textStyle: PdfComponents.titleBoldText,
          ),
          pw.Spacer(flex: 4), // gate-1d-ok: horizontal header row spacer
          pw.Row(
            children: [
              pw.Text(
                'volgnummer attest: ',
                style: PdfComponents.titleBoldText,
              ),
              pw.Text(volgnummer, style: PdfComponents.inputBlue),
            ],
          ),
        ],
      ),
    );
  }
}
