// File: lib/services/pdf/builders/pdf_header_builder.dart
// Responsibility: Renders the official grey title banner and certificate metadata.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../../../core/models/start_profile.dart';

class PdfHeaderBuilder {
  static pw.Widget buildHeader(StartProfile start) {
    final bool isOnderhoud =
        start.activiteitType.toLowerCase().contains('onderhoud');
    final bool isKeuring =
        start.activiteitType.toLowerCase().contains('keuring');
    final String volgnummer = start.externeReferte.isNotEmpty
        ? start.externeReferte
        : '                    ';

    return pw.Container(
      width: 552.9, // 552.2 + 0.7pt missing width
      height: 9.8,
      // Symmetrical 3.6pt padding keeps the outer text from touching the black borders
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
          // 1. Main Title
          pw.Text('VERBRANDINGSATTEST', style: PdfComponents.titleBoldText),

          // Flex 2: ~28pt proportional space
          pw.Spacer(flex: 2),

          // 2. Onderhoud Checkbox
          PdfComponents.labeledCheckbox(
            label: 'onderhoud',
            isChecked: isOnderhoud,
            textStyle: PdfComponents.titleBoldText,
          ),

          // Flex 2: ~28pt proportional space
          pw.Spacer(flex: 2),

          // 3. Keuring Checkbox
          PdfComponents.labeledCheckbox(
            label: 'keuring voor eerste ingebruikname',
            isChecked: isKeuring,
            textStyle: PdfComponents.titleBoldText,
          ),

          // Flex 3: ~47pt proportional space (larger gap before volgnummer)
          pw.Spacer(flex: 3),

          // 4. Volgnummer
          pw.Row(children: [
            pw.Text('volgnummer attest: ', style: PdfComponents.titleBoldText),
            pw.Text(volgnummer, style: PdfComponents.inputBlue),
          ])
        ],
      ),
    );
  }
}
