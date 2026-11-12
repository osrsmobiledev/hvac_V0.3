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

    final bool hasSeparateAddress = _hasSeparateInstallationAddress(data);

    // When identical to customer address, leave fields blank per "(indien verschillend van adres klant)"
    final String displayLocStreet =
        hasSeparateAddress ? data.locatieStraat : '';
    final String displayLocNr = hasSeparateAddress ? data.locatieNr : '';
    final String displayLocBus = hasSeparateAddress ? data.locatieBus : '';
    final String displayLocCity = hasSeparateAddress
        ? '${data.locatiePostcode} ${data.locatieGemeente}'.trim()
        : '';

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
                  displayLocStreet,
                  displayLocNr,
                  displayLocBus,
                  installatieLabelWidth,
                ),
                pw.SizedBox(height: 6.0),
                PdfComponents.buildDynamicLine(
                  'postnummer en gemeente: ',
                  displayLocCity,
                  installatieLabelWidth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Returns `true` only if an installation address is actually entered
  /// and genuinely differs from the customer address across any of the
  /// 5 statutory address components: street, house number, box, postal code, or municipality.
  static bool _hasSeparateInstallationAddress(PdfVisitData data) {
    String norm(String? s) => (s ?? '').trim().toLowerCase();

    final locStreet = norm(data.locatieStraat);
    final locNr = norm(data.locatieNr);
    final locBus = norm(data.locatieBus);
    final locPostal = norm(data.locatiePostcode);
    final locCity = norm(data.locatieGemeente);

    // If no installation address was entered at all, it's not a separate address.
    final bool hasAnyLocData = locStreet.isNotEmpty ||
        locNr.isNotEmpty ||
        locPostal.isNotEmpty ||
        locCity.isNotEmpty;
    if (!hasAnyLocData) return false;

    final custStreet = norm(data.klantStraat);
    final custNr = norm(data.klantNr);
    final custBus = norm(data.klantBus);
    final custPostal = norm(data.klantPostcode);
    final custCity = norm(data.klantGemeente);

    final bool isIdentical = locStreet == custStreet &&
        locNr == custNr &&
        locBus == custBus &&
        locPostal == custPostal &&
        locCity == custCity;

    return !isIdentical;
  }
}
