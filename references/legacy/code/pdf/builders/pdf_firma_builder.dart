import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:hvac_field_service/core/models/start_profile.dart';
import 'package:hvac_field_service/core/models/firm_profile.dart';
import 'package:hvac_field_service/services/pdf/widgets/pdf_components.dart';

class PdfFirmaBuilder {
  static pw.Widget buildFirmaSection(StartProfile start, FirmProfile firma) {
    // THE MAGIC NUMBER: This perfectly contains "postnummer en gemeente: " 
    // and forces all blue text to start at this exact X-coordinate.
    const double firmaLabelWidth = 95.0;
    const double technicusLabelWidth = 95.0; 
    const double technicusSublabelWidth = 91.5;

    // ACTION TRIGGER [LOGIC]: Smart Erkenningsnummer Formatting
    final bool hasGv = firma.gv.trim().isNotEmpty;
    final bool hasTv = firma.tv.trim().isNotEmpty;

    String erkenningsnummerText;
    if (hasGv && hasTv) {
      erkenningsnummerText = 'GV ${firma.gv} / TV ${firma.tv}';
    } else if (hasGv) {
      erkenningsnummerText = 'GV ${firma.gv}';
    } else if (hasTv) {
      erkenningsnummerText = 'TV ${firma.tv}';
    } else {
      // The default placeholder if nothing is filled
      erkenningsnummerText = 'GV____________________ / TV____________________';
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Firma)
        PdfComponents.halfWidthBox(
          titleContent: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: 'Firma ', style: PdfComponents.titleBoldText),
                pw.TextSpan(text: '(ook invullen indien zelfstandige)', style: PdfComponents.subTitleText), // Using your brilliant subTitleText idea!
              ],
            ),
          ),
          contentHeight: 69.2,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine('naam: ', firma.naam, firmaLabelWidth),
                PdfComponents.buildAddressLine('straat en nummer: ', firma.straat, firma.nr, firma.bus, firmaLabelWidth),
                PdfComponents.buildDynamicLine('postnummer en gemeente: ', '${firma.postcode} ${firma.gemeente}'.trim(), firmaLabelWidth),
                PdfComponents.buildPrefixedLine('tel: ', firma.tel, '+32', firmaLabelWidth),
                PdfComponents.buildDynamicLine('e-mail: ', firma.email, firmaLabelWidth),
                PdfComponents.buildPrefixedLine('ondernemingsnummer: ', firma.kbo, 'BE', firmaLabelWidth),
              ],
            ),
          ),
        ),

        // THE PERFECT CALIBRATED GAP
        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Technicus)
        PdfComponents.halfWidthBox(
          titleContent: pw.Text('Technicus', style: PdfComponents.titleBoldText),
          contentHeight: 69.2,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0, right: 3.6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // ACTION TRIGGER [UI/UX]: Split into two distinct lines for better symmetry
                PdfComponents.buildDynamicLine('voornaam: ', firma.voornaam, technicusLabelWidth),
                PdfComponents.buildDynamicLine('achternaam: ', firma.achternaam, technicusLabelWidth),
                // ACTION TRIGGER [LOGIC]: Inject the smart formatted string
                PdfComponents.buildDynamicLine('erkenningsnummer: ', erkenningsnummerText, technicusLabelWidth),

                // The Highlighted Date/Time Box
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 3.6, vertical: 2.0),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    border: pw.Border.all(
                      color: PdfComponents.borderSide.color,
                      width: PdfComponents.borderSide.width,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // ACTION TRIGGER [UI/UX]: Local grid alignment for the grey box
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: technicusSublabelWidth,
                            child: pw.Text('Datum onderhoud: ', style: PdfComponents.titleBoldText),
                          ),
                          pw.Expanded(
                            child: pw.Text(firma.datum.isNotEmpty ? firma.datum : '_______-________-___________', style: PdfComponents.inputBlue),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2.0),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: technicusSublabelWidth,
                            child: pw.Text('Arbeidsduur: ', style: PdfComponents.titleBoldText),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(text: 'van ', style: PdfComponents.titleText),
                                  pw.TextSpan(text: firma.tijdVan.isNotEmpty ? firma.tijdVan : '____________', style: PdfComponents.inputBlue),
                                  pw.TextSpan(text: ' tot ', style: PdfComponents.titleText),
                                  pw.TextSpan(text: firma.tijdTot.isNotEmpty ? firma.tijdTot : '______________', style: PdfComponents.inputBlue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}