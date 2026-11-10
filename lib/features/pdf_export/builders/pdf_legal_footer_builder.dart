import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_theme_tokens.dart';

/// Renders Table 5 of the official Flemish template: Statutory decree reference and privacy notice.
abstract final class PdfLegalFooterBuilder {
  static const double boxHeight = 22.0;

  static pw.Widget buildLegalFooter() {
    return pw.Container(
      width: PdfThemeTokens.fullWidth,
      padding: const pw.EdgeInsets.only(top: 2.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.2, color: PdfColors.black),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: const pw.TextSpan(
              style: pw.TextStyle(
                fontSize: 4.8,
                color: PdfColors.black,
              ),
              children: [
                pw.TextSpan(
                  text:
                      'Attest uitgereikt met toepassing van het besluit van de Vlaamse Regering van 8 december 2006 '
                      'betreffende het onderhoud en het nazicht van centrale stooktoestellen voor de verwarming '
                      'van gebouwen of voor de aanmaak van warm verbruikswater. De attesten van minstens de laatste '
                      'twee onderhoudsbeurten moeten ter beschikking gehouden worden van de toezichthouders. '
                      'Meer informatie op ',
                ),
                pw.TextSpan(
                  text: 'www.veiligverwarmen.be',
                  style: pw.TextStyle(
                    decoration: pw.TextDecoration.underline,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.TextSpan(text: '.'),
              ],
            ),
          ),
          pw.SizedBox(height: 1.5),
          pw.RichText(
            text: const pw.TextSpan(
              style: pw.TextStyle(
                fontSize: 4.8,
                color: PdfColors.black,
              ),
              children: [
                pw.TextSpan(
                  text:
                      'Het departement Omgeving hecht veel belang aan de bescherming van uw persoonlijke levenssfeer. '
                      'Voor meer informatie, lees de privacyverklaring op de website van het departement Omgeving (',
                ),
                pw.TextSpan(
                  text: 'www.omgevingvlaanderen.be/privacy',
                  style: pw.TextStyle(
                    decoration: pw.TextDecoration.underline,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.TextSpan(text: ').'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
