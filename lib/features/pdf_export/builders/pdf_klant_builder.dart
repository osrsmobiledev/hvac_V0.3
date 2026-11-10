import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders the Klant (left) and Installatielocatie (right) section.
abstract final class PdfKlantBuilder {
  static pw.Widget buildKlantSection(PdfVisitData data) {
    const double klantLabelWidth = 95.0;
    const double installatieLabelWidth = 95.0;
    const double boxHeight = 58.0;

    final bool hasBedrijf = data.klantBedrijf.trim().isNotEmpty;
    final String fullName =
        '${data.klantVoornaam} ${data.klantAchternaam}'.trim();
    final bool hasName = fullName.isNotEmpty;

    String naamText;
    if (hasBedrijf && hasName) {
      naamText = '${data.klantBedrijf.trim()} ($fullName)';
    } else if (hasBedrijf) {
      naamText = data.klantBedrijf.trim();
    } else {
      naamText = fullName.isNotEmpty ? fullName : data.klantNaam;
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Klant)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text('Klant', style: PdfComponents.titleBoldText),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine(
                  'voornaam en achternaam: ',
                  naamText,
                  klantLabelWidth,
                ),
                PdfComponents.buildAddressLine(
                  'straat en nummer: ',
                  data.klantStraat,
                  data.klantNr,
                  data.klantBus,
                  klantLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'postnummer en gemeente: ',
                  '${data.klantPostcode} ${data.klantGemeente}'.trim(),
                  klantLabelWidth,
                ),
                PdfComponents.buildPrefixedLine(
                  'tel: ',
                  data.klantTel,
                  '+32',
                  klantLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'e-mail: ',
                  data.klantEmail,
                  klantLabelWidth,
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Installatieadres)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text(
            '(adres stooktoestel indien verschillend van adres klant)',
            style: PdfComponents.subTitleText,
          ),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(
              left: 3.6,
              top: 2.0,
              bottom: 2.0,
              right: 3.6,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                PdfComponents.buildAddressLine(
                  'straat en nummer: ',
                  data.locatieStraat,
                  data.locatieNr,
                  data.locatieBus,
                  installatieLabelWidth,
                ),
                pw.SizedBox(height: 6.0),
                PdfComponents.buildDynamicLine(
                  'postnummer en gemeente: ',
                  '${data.locatiePostcode} ${data.locatieGemeente}'.trim(),
                  installatieLabelWidth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
