import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme_tokens.dart';

/// Line text helpers for data labels and values in PDF export.
abstract final class PdfLineComponents {
  static const pw.TextStyle titleText = PdfThemeTokens.titleText;
  static const pw.TextStyle inputBlue = PdfThemeTokens.inputBlue;

  /// Dynamic single-line data field with strict label width alignment.
  static pw.Widget buildDynamicLine(
    String label,
    String value,
    double labelWidth,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: labelWidth, child: pw.Text(label, style: titleText)),
        pw.Expanded(child: pw.Text(value, style: inputBlue)),
      ],
    );
  }

  /// Address line with optional bus number rendering in black label / blue text.
  static pw.Widget buildAddressLine(
    String label,
    String straat,
    String nr,
    String bus,
    double labelWidth,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: labelWidth, child: pw.Text(label, style: titleText)),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$straat $nr'.trim(), style: inputBlue),
                if (bus.trim().isNotEmpty) ...[
                  const pw.TextSpan(text: '  bus: ', style: titleText),
                  pw.TextSpan(text: bus.trim(), style: inputBlue),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Prefixed text line (e.g., auto +32 or BE).
  static pw.Widget buildPrefixedLine(
    String label,
    String value,
    String prefix,
    double labelWidth,
  ) {
    String displayValue = value.trim();
    if (displayValue.isNotEmpty &&
        !displayValue.toUpperCase().startsWith(prefix.toUpperCase().trim())) {
      displayValue = '$prefix $displayValue';
    }
    return buildDynamicLine(label, displayValue, labelWidth);
  }
}
