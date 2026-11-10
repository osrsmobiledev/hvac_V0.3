import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders Table 4 of the official Flemish template: "Gebreken en maatregelen" and digital signatures.
abstract final class PdfGebrekenHandtekeningenBuilder {
  static const double boxHeight = 86.0;

  static pw.Widget buildGebrekenSection(PdfVisitData data) {
    return PdfComponents.fullWidthBox(
      titleHeight: 9.8,
      titleContent: pw.Text(
        'Gebreken en maatregelen',
        style: PdfComponents.titleBoldText,
      ),
      contentHeight: boxHeight,
      mainContent: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Section A: Gebreken die niet door de onderhoudsbeurt kunnen worden weggewerkt
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Gebreken die niet door de onderhoudsbeurt kunnen worden weggewerkt:',
                  style: PdfComponents.titleBoldText,
                ),
                pw.Container(
                  height: 12.0,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 1.0),
                  child: pw.Text(
                    data.gebrekenOpmerkingen.trim().isNotEmpty
                        ? data.gebrekenOpmerkingen
                        : 'Geen tekortkomingen vastgesteld.',
                    style: data.gebrekenOpmerkingen.trim().isNotEmpty
                        ? PdfComponents.inputBlue
                        : const pw.TextStyle(
                            fontSize: 6.0,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic,
                          ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            // Section B: Andere opmerkingen
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Andere opmerkingen:',
                  style: PdfComponents.titleBoldText,
                ),
                pw.Container(
                  height: 10.0,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 1.0),
                  child: pw.Text(
                    data.andereOpmerkingen.trim().isNotEmpty
                        ? data.andereOpmerkingen
                        : 'Geen.',
                    style: data.andereOpmerkingen.trim().isNotEmpty
                        ? PdfComponents.inputBlue
                        : const pw.TextStyle(
                            fontSize: 6.0,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic,
                          ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            // Divider before Signatures
            pw.Container(
              height: 0.2,
              color: PdfColors.black,
            ),

            // Signatures Row (Technicus: 311.9 pt | Klant: 233.0 pt)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Technicus
                pw.SizedBox(
                  width: 311.9,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '(handtekening erkende technicus (gas of stookolie) of geschoold vakman (vaste brandstof))',
                        style: const pw.TextStyle(
                          fontSize: 5.5,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Container(
                        height: 32.0,
                        alignment: pw.Alignment.center,
                        child: (data.technicusHandtekeningBytes != null &&
                                data.technicusHandtekeningBytes!.isNotEmpty)
                            ? _buildSafeSignatureImage(
                                data.technicusHandtekeningBytes!)
                            : pw.Center(
                                child: pw.Text(
                                  '(Nog niet ondertekend)',
                                  style: PdfComponents.subTitleText,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                pw.Container(
                  width: 0.2,
                  height: 38.0,
                  color: PdfColors.black,
                ),
                pw.SizedBox(width: 4.0),

                // Right: Klant
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'voor kennisname (handtekening klant)',
                        style: const pw.TextStyle(
                          fontSize: 5.5,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Container(
                        height: 32.0,
                        alignment: pw.Alignment.center,
                        child: _buildCustomerSignatureArea(data),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildCustomerSignatureArea(PdfVisitData data) {
    if (data.klantHandtekeningBytes != null &&
        data.klantHandtekeningBytes!.isNotEmpty) {
      return _buildSafeSignatureImage(data.klantHandtekeningBytes!);
    }

    final exc = data.klantHandtekeningUitzondering.toLowerCase().trim();
    if (exc == 'weigert' || exc == 'refused') {
      return pw.Center(
        child: pw.Text(
          'Klant weigert te ondertekenen',
          style: const pw.TextStyle(
            fontSize: 6.0,
            color: PdfColors.red800,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    if (exc == 'afwezig' || exc == 'absent') {
      return pw.Center(
        child: pw.Text(
          'Klant afwezig bij oplevering',
          style: const pw.TextStyle(
            fontSize: 6.0,
            color: PdfColors.orange800,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    return pw.Center(
      child: pw.Text(
        '(Nog niet ondertekend)',
        style: PdfComponents.subTitleText,
      ),
    );
  }

  static pw.Widget _buildSafeSignatureImage(Uint8List bytes) {
    try {
      return pw.Center(
        child: pw.ConstrainedBox(
          constraints:
              const pw.BoxConstraints(maxHeight: 24.0, maxWidth: 140.0),
          child: pw.Image(
            pw.MemoryImage(bytes),
            fit: pw.BoxFit.contain,
            alignment: pw.Alignment.center,
          ),
        ),
      );
    } catch (_) {
      return pw.Center(
        child: pw.Text(
          '(Digitale handtekening geregistreerd)',
          style: PdfComponents.subTitleText,
        ),
      );
    }
  }
}
