import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_line_components.dart';
import 'pdf_theme_tokens.dart';

/// Reusable Lego blocks and container widgets for the A4 PDF certificate.
abstract final class PdfComponents {
  static const pw.BorderSide borderSide = PdfThemeTokens.borderSide;
  static const pw.TextStyle titleBoldText = PdfThemeTokens.titleBoldText;
  static const pw.TextStyle titleText = PdfThemeTokens.titleText;
  static const pw.TextStyle subTitleBoldText = PdfThemeTokens.subTitleBoldText;
  static const pw.TextStyle subTitleText = PdfThemeTokens.subTitleText;
  static const pw.TextStyle inputBlue = PdfThemeTokens.inputBlue;

  static pw.Widget debugWrap(pw.Widget child) =>
      PdfThemeTokens.debugWrap(child);

  /// Standalone 3.5x3.5pt vector checkbox with clean blue cross mark when checked (matching legacy geometry).
  static pw.Widget standaloneCheckbox({
    required bool isChecked,
    PdfColor checkColor = PdfColors.blue800,
  }) {
    return pw.Container(
      width: 3.5,
      height: 3.5,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: borderSide.width, color: borderSide.color),
      ),
      child: isChecked
          ? pw.CustomPaint(
              size: const PdfPoint(3.5, 3.5),
              painter: (PdfGraphics canvas, PdfPoint size) {
                const double padding = 0.7;
                const double max = 3.5 - padding;
                canvas.moveTo(padding, padding);
                canvas.lineTo(max, max);
                canvas.moveTo(padding, max);
                canvas.lineTo(max, padding);
                canvas.setStrokeColor(checkColor);
                canvas.setLineWidth(0.3);
                canvas.strokePath();
              },
            )
          : null,
    );
  }

  /// Labeled Checkbox (Box + 2.6pt space + text).
  static pw.Widget labeledCheckbox({
    required String label,
    required bool isChecked,
    required pw.TextStyle textStyle,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Transform.translate(
          offset: const PdfPoint(0, 1.7),
          child: standaloneCheckbox(isChecked: isChecked),
        ),
        pw.SizedBox(width: 2.6),
        pw.Text(label, style: textStyle),
      ],
    );
  }

  /// Full-width bounding box (locked to 552.9pt) with shaded grey title bar.
  static pw.Widget fullWidthBox({
    required pw.Widget titleContent,
    required pw.Widget mainContent,
    double titleHeight = 9.8,
    double? contentHeight,
    pw.EdgeInsets? titlePadding,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: titleHeight,
          width: PdfThemeTokens.fullWidth,
          padding:
              titlePadding ?? const pw.EdgeInsets.symmetric(horizontal: 3.6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            border:
                pw.Border.all(color: borderSide.color, width: borderSide.width),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [titleContent],
          ),
        ),
        pw.Container(
          height: contentHeight,
          width: PdfThemeTokens.fullWidth,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                left: borderSide, right: borderSide, bottom: borderSide),
          ),
          child: mainContent,
        ),
      ],
    );
  }

  /// Half-width bounding box (locked to 275.75pt) with shaded grey title bar.
  static pw.Widget halfWidthBox({
    required pw.Widget titleContent,
    required pw.Widget mainContent,
    double titleHeight = 9.8,
    double? contentHeight,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: titleHeight,
          width: PdfThemeTokens.halfWidth,
          padding: const pw.EdgeInsets.symmetric(horizontal: 3.6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            border:
                pw.Border.all(color: borderSide.color, width: borderSide.width),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [titleContent],
          ),
        ),
        pw.Container(
          height: contentHeight,
          width: PdfThemeTokens.halfWidth,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                left: borderSide, right: borderSide, bottom: borderSide),
          ),
          child: mainContent,
        ),
      ],
    );
  }

  /// Dynamic single-line data field with strict label width alignment.
  static pw.Widget buildDynamicLine(
          String label, String value, double labelWidth) =>
      PdfLineComponents.buildDynamicLine(label, value, labelWidth);

  /// Address line with optional bus number rendering in black label / blue text.
  static pw.Widget buildAddressLine(
    String label,
    String straat,
    String nr,
    String bus,
    double labelWidth,
  ) =>
      PdfLineComponents.buildAddressLine(label, straat, nr, bus, labelWidth);

  /// Prefixed text line (e.g., auto +32 or BE).
  static pw.Widget buildPrefixedLine(
    String label,
    String value,
    String prefix,
    double labelWidth,
  ) =>
      PdfLineComponents.buildPrefixedLine(label, value, prefix, labelWidth);

  /// Labeled checkbox with adjacent dynamic input text.
  static pw.Widget labeledCheckboxWithInput({
    required String label,
    required bool isChecked,
    required String inputText,
    required pw.TextStyle textStyle,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Transform.translate(
          offset: const PdfPoint(0, 1.7),
          child: standaloneCheckbox(isChecked: isChecked),
        ),
        pw.SizedBox(width: 2.6),
        pw.Text(label, style: textStyle),
        pw.SizedBox(width: 2.0),
        pw.Expanded(child: pw.Text(inputText, style: inputBlue)),
      ],
    );
  }

  /// Inline checkbox with prefix, placeholder, and suffix.
  static pw.Widget buildInlineInputCheckbox({
    required String prefix,
    required String emptyPlaceholder,
    required String suffix,
    required bool isChecked,
    required String inputText,
    required pw.TextStyle textStyle,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Transform.translate(
          offset: const PdfPoint(0, 1.7),
          child: standaloneCheckbox(isChecked: isChecked),
        ),
        pw.SizedBox(width: 2.6),
        pw.RichText(
          text: pw.TextSpan(
            style: textStyle,
            children: [
              pw.TextSpan(text: prefix),
              if (inputText.isNotEmpty && isChecked)
                pw.TextSpan(text: inputText, style: inputBlue)
              else
                pw.TextSpan(text: emptyPlaceholder),
              pw.TextSpan(text: suffix),
            ],
          ),
        ),
      ],
    );
  }
}
