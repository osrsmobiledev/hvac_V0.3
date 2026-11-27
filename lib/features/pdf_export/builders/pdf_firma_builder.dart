import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders the Firma (left) and Technicus + Work duration (right) section.
abstract final class PdfFirmaBuilder {
  static pw.Widget buildFirmaSection(PdfVisitData data) {
    const double technicusLabelWidth = 95.0;
    const double technicusSublabelWidth = 91.5;

    final String gvFormatted = formatErkenningsnummer(data.technicusGv, 'GV');
    final String tvFormatted = formatErkenningsnummer(data.technicusTv, 'TV');

    String erkenningsnummerText;
    if (gvFormatted.isNotEmpty && tvFormatted.isNotEmpty) {
      erkenningsnummerText = '$gvFormatted / $tvFormatted';
    } else if (gvFormatted.isNotEmpty) {
      erkenningsnummerText = gvFormatted;
    } else if (tvFormatted.isNotEmpty) {
      erkenningsnummerText = tvFormatted;
    } else {
      erkenningsnummerText = 'GV____________________ / TV____________________';
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Firma)
        buildFirmaColumn(data, boxHeight: 69.2),

        pw.SizedBox(width: 1.4),

        // RIGHT COLUMN (Technicus)
        PdfComponents.halfWidthBox(
          titleContent:
              pw.Text('Technicus', style: PdfComponents.titleBoldText),
          contentHeight: 69.2,
          mainContent: pw.Padding(
            padding: const pw.EdgeInsets.only(
              left: 3.6,
              top: 2.0,
              bottom: 2.0,
              right: 3.6,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                PdfComponents.buildDynamicLine(
                  'voornaam: ',
                  data.technicusVoornaam,
                  technicusLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'achternaam: ',
                  data.technicusAchternaam,
                  technicusLabelWidth,
                ),
                PdfComponents.buildDynamicLine(
                  'erkenningsnummer: ',
                  erkenningsnummerText,
                  technicusLabelWidth,
                ),

                // Grey Date/Time Box
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 3.6,
                    vertical: 2.0,
                  ),
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
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: technicusSublabelWidth,
                            child: pw.Text(
                              'Datum onderhoud: ',
                              style: PdfComponents.titleBoldText,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              formatDate(data.datumOnderhoud),
                              style: PdfComponents.inputBlue,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2.0),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: technicusSublabelWidth,
                            child: pw.Text(
                              'Arbeidsduur: ',
                              style: PdfComponents.titleBoldText,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  const pw.TextSpan(
                                    text: 'van ',
                                    style: PdfComponents.titleText,
                                  ),
                                  pw.TextSpan(
                                    text: data.arbeidsduurVan.isNotEmpty
                                        ? data.arbeidsduurVan
                                        : '____________',
                                    style: PdfComponents.inputBlue,
                                  ),
                                  const pw.TextSpan(
                                    text: ' tot ',
                                    style: PdfComponents.titleText,
                                  ),
                                  pw.TextSpan(
                                    text: data.arbeidsduurTot.isNotEmpty
                                        ? data.arbeidsduurTot
                                        : '______________',
                                    style: PdfComponents.inputBlue,
                                  ),
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

  /// Builds the shared left-hand Firma column for both Verbrandingsattest
  /// and Reinigingsattest PDFs.
  static pw.Widget buildFirmaColumn(
    PdfVisitData data, {
    double boxHeight = 69.2,
  }) {
    const double firmaLabelWidth = 95.0;
    return PdfComponents.halfWidthBox(
      titleContent: pw.RichText(
        text: const pw.TextSpan(
          children: [
            pw.TextSpan(text: 'Firma ', style: PdfComponents.titleBoldText),
            pw.TextSpan(
              text: '(ook invullen indien zelfstandige)',
              style: PdfComponents.subTitleText,
            ),
          ],
        ),
      ),
      contentHeight: boxHeight,
      mainContent: pw.Padding(
        padding: const pw.EdgeInsets.only(left: 3.6, top: 2.0, bottom: 2.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            PdfComponents.buildDynamicLine(
                'naam: ', data.firmaNaam, firmaLabelWidth),
            PdfComponents.buildAddressLine(
              'straat en nummer: ',
              data.firmaStraat,
              data.firmaNr,
              data.firmaBus,
              firmaLabelWidth,
            ),
            PdfComponents.buildDynamicLine(
              'postnummer en gemeente: ',
              '${data.firmaPostcode} ${data.firmaGemeente}'.trim(),
              firmaLabelWidth,
            ),
            PdfComponents.buildPrefixedLine(
                'tel: ', data.firmaTel, '+32', firmaLabelWidth),
            PdfComponents.buildDynamicLine(
                'e-mail: ', data.firmaEmail, firmaLabelWidth),
            PdfComponents.buildPrefixedLine(
                'ondernemingsnummer: ', data.firmaKbo, 'BE', firmaLabelWidth),
          ],
        ),
      ),
    );
  }

  static String formatDate(
    String raw, {
    String emptyFallback = '_______-________-___________',
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return emptyFallback;
    if (RegExp(r'^\d{2}[/-]\d{2}[/-]\d{4}').hasMatch(trimmed)) {
      return trimmed.replaceAll('-', '/');
    }
    try {
      final dt = DateTime.parse(trimmed);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}';
    } catch (_) {
      return trimmed;
    }
  }

  static String formatErkenningsnummer(String raw, String prefix) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) return '$prefix $digits';
    final stripped =
        trimmed.replaceFirst(RegExp('^$prefix\\s*', caseSensitive: false), '');
    return '$prefix $stripped';
  }
}
