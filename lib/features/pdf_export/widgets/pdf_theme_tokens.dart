import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Theme tokens and typography tiers for the Flemish combustion certificate A4 PDF.
///
/// Calibrated for exact 0.2pt borders, Libron typography hierarchy, and
/// print-safe grayscale and accent colors.
abstract final class PdfThemeTokens {
  /// Master switch to draw debug bounding boxes around PDF elements.
  static const bool debugMode = false;

  // --- Typography Tiers ---

  /// Tier 1: Main Labels & Titles (Equiv: Calibri 8pt bold / 7pt in Libron).
  static const pw.TextStyle titleBoldText = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 7.0,
  );

  /// Tier 1 Normal: Main Labels (7pt normal).
  static const pw.TextStyle titleText = pw.TextStyle(fontSize: 7.0);

  /// Tier 2 Bold: Sub-labels & Dense Grid Text (5pt bold).
  static const pw.TextStyle subTitleBoldText = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 5.0,
  );

  /// Tier 2 Normal: Sub-labels & Dense Grid Text (5pt normal).
  static const pw.TextStyle subTitleText = pw.TextStyle(fontSize: 5.0);

  /// Tier 3: Technician Dynamic Input Data (Dark Blue 800 for high-contrast clarity).
  static const pw.TextStyle inputBlue = pw.TextStyle(
    fontSize: 7.0,
    color: PdfColors.blue800,
  );

  /// Tier 4: Checkbox Small Subscripts (3.5pt bold).
  static const pw.TextStyle checkBoxText = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 3.5,
  );

  /// Standard Hairline Border Side (0.2pt solid black).
  static const pw.BorderSide borderSide = pw.BorderSide(
    width: 0.2,
    color: PdfColors.black,
  );

  /// Calibrated Page Column Widths (A4: 595.28pt - 24.9pt left - 17.3pt right = 553.08pt).
  static const double fullWidth = 552.9;
  static const double halfWidth = 275.75;

  /// Optional debug wrapper drawing a red bounding box when [debugMode] is enabled.
  static pw.Widget debugWrap(pw.Widget child) {
    if (!debugMode) return child;
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border.fromBorderSide(
          pw.BorderSide(color: PdfColors.red, width: 0.5),
        ),
      ),
      child: child,
    );
  }
}
