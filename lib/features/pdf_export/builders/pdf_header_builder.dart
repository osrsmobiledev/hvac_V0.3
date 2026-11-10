import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders the official grey title banner and certificate metadata (Onderhoud / Keuring / Volgnummer).
abstract final class PdfHeaderBuilder {
  static pw.Widget buildHeader(PdfVisitData data) {
    final bool isOnderhoud =
        data.activiteitType.toLowerCase().contains('onderhoud');
    final bool isKeuring =
        data.activiteitType.toLowerCase().contains('keuring') ||
            data.activiteitType.toLowerCase().contains('ingebruikname');
    final String volgnummer = data.volgnummerAttest.isNotEmpty
        ? data.volgnummerAttest
        : '                    ';

    return pw.Container(
      width: 552.9,
      height: 9.8,
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
          pw.Text('VERBRANDINGSATTEST', style: PdfComponents.titleBoldText),
          pw.Spacer(flex: 2),
          PdfComponents.labeledCheckbox(
            label: 'onderhoud',
            isChecked: isOnderhoud,
            textStyle: PdfComponents.titleBoldText,
          ),
          pw.Spacer(flex: 2),
          PdfComponents.labeledCheckbox(
            label: 'keuring voor eerste ingebruikname',
            isChecked: isKeuring,
            textStyle: PdfComponents.titleBoldText,
          ),
          pw.Spacer(flex: 3),
          pw.Row(
            children: [
              pw.Text('volgnummer attest: ',
                  style: PdfComponents.titleBoldText),
              pw.Text(volgnummer, style: PdfComponents.inputBlue),
            ],
          ),
        ],
      ),
    );
  }
}
