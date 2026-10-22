import 'package:pdf/widgets.dart' as pw;
import 'package:hvac_field_service/core/models/klant_profile.dart';
import 'package:hvac_field_service/services/pdf/widgets/pdf_components.dart';

class PdfKlantBuilder {
  static pw.Widget buildKlantSection(KlantProfile klant) {
    const double klantLabelWidth = 95.0;
    const double installatieLabelWidth = 95.0; 
    const double boxHeight = 58.0; 

    // ACTION TRIGGER [LOGIC]: Smart Formatting for Bedrijf and/or Name
    final bool hasBedrijf = klant.bedrijf.trim().isNotEmpty;
    final String fullName = '${klant.voornaam} ${klant.achternaam}'.trim();
    final bool hasName = fullName.isNotEmpty;

    String naamText;
    if (hasBedrijf && hasName) {
      naamText = '${klant.bedrijf.trim()} ($fullName)';
    } else if (hasBedrijf) {
      naamText = klant.bedrijf.trim();
    } else {
      naamText = fullName;
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
                // ACTION TRIGGER [UI]: Using the smart naamText, and updating the label for clarity
                PdfComponents.buildDynamicLine('voornaam en achternaam: ', naamText, klantLabelWidth),
                PdfComponents.buildAddressLine('straat en nummer: ', klant.straat, klant.nr, klant.bus, klantLabelWidth),
                PdfComponents.buildDynamicLine('postnummer en gemeente: ', '${klant.postcode} ${klant.gemeente}'.trim(), klantLabelWidth),
                PdfComponents.buildPrefixedLine('tel: ', klant.tel, '+32', klantLabelWidth),
                PdfComponents.buildDynamicLine('e-mail: ', klant.email, klantLabelWidth),
              ],
            ),
          ),
        ),

        // THE PERFECT CALIBRATED GAP
        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Installatieadres)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text(
            '(adres stooktoestel indien verschillend van adres klant)', 
            style: PdfComponents.subTitleText,
          ),
          contentHeight: boxHeight,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0, right: 3.6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start, 
              children: [
                PdfComponents.buildAddressLine('straat en nummer: ', klant.locatieStraat, klant.locatieNr, klant.locatieBus, installatieLabelWidth),
                pw.SizedBox(height: 6.0),
                PdfComponents.buildDynamicLine('postnummer en gemeente: ', '${klant.locatiePostcode} ${klant.locatieGemeente}'.trim(), installatieLabelWidth),
              ],
            ),
          ),
        ),
      ],
    );
  }
}