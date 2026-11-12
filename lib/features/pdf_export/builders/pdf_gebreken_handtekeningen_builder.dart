import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';
import '../data/pdf_visit_data.dart';

/// Renders Table 4 of the official Flemish template: "Gebreken en maatregelen" and digital signatures.
abstract final class PdfGebrekenHandtekeningenBuilder {
  static const double boxHeight = 88.0;

  static pw.Widget buildGebrekenSection(PdfVisitData data) {
    final displayDefects = _formatInlineItems(data.gebrekenOpmerkingen);
    final displayRemarks = _formatInlineItems(data.andereOpmerkingen);

    return PdfComponents.fullWidthBox(
      titleHeight: 9.8,
      titleContent: pw.Text(
        'Gebreken en maatregelen',
        style: PdfComponents.titleBoldText,
      ),
      contentHeight: boxHeight,
      mainContent: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(4.0, 1.5, 4.0, 1.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Zone 1: Text Section with strictly bounded height
            pw.SizedBox(
              height: 46.5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Gebreken die niet door de onderhoudsbeurt kunnen worden weggewerkt:',
                    style: const pw.TextStyle(
                      fontSize: 5.8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 0.5, bottom: 1.5),
                    child: pw.Text(
                      displayDefects.isNotEmpty
                          ? displayDefects
                          : 'Geen tekortkomingen vastgesteld.',
                      style: displayDefects.isNotEmpty
                          ? const pw.TextStyle(
                              fontSize: 5.2,
                              color: PdfColors.blue800,
                            )
                          : const pw.TextStyle(
                              fontSize: 5.2,
                              color: PdfColors.grey700,
                              fontStyle: pw.FontStyle.italic,
                            ),
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    'Andere opmerkingen:',
                    style: const pw.TextStyle(
                      fontSize: 5.8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 0.5),
                    child: pw.Text(
                      displayRemarks.isNotEmpty ? displayRemarks : 'Geen.',
                      style: displayRemarks.isNotEmpty
                          ? const pw.TextStyle(
                              fontSize: 5.2,
                              color: PdfColors.blue800,
                            )
                          : const pw.TextStyle(
                              fontSize: 5.2,
                              color: PdfColors.grey700,
                              fontStyle: pw.FontStyle.italic,
                            ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Zone 2: Signatures Section at guaranteed fixed position
            pw.Container(
              height: 0.2,
              color: PdfColors.black,
            ),
            pw.SizedBox(height: 0.8),

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
                          fontSize: 5.2,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Container(
                        height: 30.0,
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
                  height: 36.0,
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
                          fontSize: 5.2,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.Container(
                        height: 30.0,
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
        child: pw.Text('Klant weigert te ondertekenen',
            style: const pw.TextStyle(
                fontSize: 6.0,
                color: PdfColors.red800,
                fontWeight: pw.FontWeight.bold)),
      );
    }
    if (exc == 'afwezig' || exc == 'absent') {
      return pw.Center(
        child: pw.Text('Klant afwezig bij oplevering',
            style: const pw.TextStyle(
                fontSize: 6.0,
                color: PdfColors.orange800,
                fontWeight: pw.FontWeight.bold)),
      );
    }
    return pw.Center(
      child: pw.Text('(Nog niet ondertekend)', style: PdfComponents.subTitleText),
    );
  }

  static pw.Widget _buildSafeSignatureImage(Uint8List bytes) {
    try {
      return pw.Center(
        child: pw.ConstrainedBox(
          constraints:
              const pw.BoxConstraints(maxHeight: 28.0, maxWidth: 140.0),
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

  /// Formats multiple lines of defects or remarks into a clean horizontal line
  /// with bullet points separated by spaces (e.g. "• Issue 1      • Issue 2").
  static String _formatInlineItems(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final lines = trimmed
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '';

    final formattedItems = lines.map((item) {
      if (item.startsWith('•') || item.startsWith('-')) {
        return '• ${item.substring(1).trim()}';
      }
      return '• $item';
    });

    return formattedItems.join('      ');
  }
}
