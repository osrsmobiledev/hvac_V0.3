// File: lib/services/pdf/widgets/pdf_components.dart
// Responsibility: Single source of truth for PDF styling, borders, and reusable Lego blocks.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfComponents {
  // 1. MASTER SWITCH: Set to true to draw red measuring boxes around elements while coding
  static const bool debugMode = false;

  // 2. STANDARD TYPOGRAPHY
  // Tier 1: Main Labels & Titles (Equiv: Calibri 8)
  static final pw.TextStyle titleBoldText = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.0);
  static final pw.TextStyle titleText = pw.TextStyle(fontSize: 7.0);
  
  // Tier 2: Sub-labels & Dense Grid Text (Equiv: Calibri 6)
  static final pw.TextStyle subTitleBoldText = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5.0);
  static final pw.TextStyle subTitleText = pw.TextStyle(fontSize: 5.0);
  
  // Tier 3: Technician Input (Dynamic Data)
  static final pw.TextStyle inputBlue = pw.TextStyle(fontSize: 7.0, color: PdfColors.blue800);

  // Tier 4: Specific UI Elements
  static final pw.TextStyle checkBoxText = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 3.5);

  // 3. STANDARD BORDERS
  static const pw.BorderSide borderSide = pw.BorderSide(width: 0.2, color: PdfColors.black);

  // 4. LEGO BLOCK: Debug Wrapper
  static pw.Widget debugWrap(pw.Widget child) {
    if (!debugMode) return child;
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.red, width: 0.5)),
      child: child,
    );
  }

  // 5. LEGO BLOCK: Standalone Checkbox (Just the box)
  static pw.Widget standaloneCheckbox({required bool isChecked}) {
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
                // The trim: How far the lines stay away from the box edges (in points)
                const double padding = 0.7;
                final double max = 3.5 - padding;

                // Draw Top-Left to Bottom-Right
                canvas.moveTo(padding, padding);
                canvas.lineTo(max, max);
                
                // Draw Bottom-Left to Top-Right
                canvas.moveTo(padding, max);
                canvas.lineTo(max, padding);
                
                // Style the pen
                canvas.setStrokeColor(PdfColors.black);
                canvas.setLineWidth(0.3); // Crisp, exact line weight
                canvas.strokePath();
              },
            )
          : null,
    );
  }

  // 6. LEGO BLOCK: Labeled Checkbox (Box + 2.6pt Space + Text)
  static pw.Widget labeledCheckbox({
    required String label,
    required bool isChecked,
    required pw.TextStyle textStyle, 
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      // ALIGNMENT CHANGE: Push elements to the bottom instead of the center
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        // MICRO-TUNING: Adjust the Y value to align perfectly with the text baseline
        pw.Transform.translate(
          offset: const PdfPoint(0, 1.7), // Nudge this Y value (e.g., 0.5 or -0.5) if the box is slightly off the baseline
          child: standaloneCheckbox(isChecked: isChecked),
        ),
        pw.SizedBox(width: 2.6),
        pw.Text(label, style: textStyle), 
      ],
    );
  }

  // =========================================================
  // 1. FULL WIDTH BOX (Strictly locked to 552.6pt inner width)
  // =========================================================
  static pw.Widget fullWidthBox({
    required pw.Widget titleContent, 
    required pw.Widget mainContent,  
    double titleHeight = 9.8,
    double? contentHeight,           
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title Row
        pw.Container(
          height: titleHeight,
          width: 552.9, // 552.2 + 0.7pt missing width
          padding: const pw.EdgeInsets.symmetric(horizontal: 3.6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            border: pw.Border.all(color: borderSide.color, width: borderSide.width),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [titleContent],
          ),
        ),
        // Content Row
        pw.Container(
          height: contentHeight,
          width: 552.9, // 552.2 + 0.7pt missing width
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: borderSide, right: borderSide, bottom: borderSide,
            ),
          ),
          child: mainContent,
        ),
      ],
    );
  }

  // =========================================================
  // 2. HALF WIDTH BOX (Strictly locked to 275.4pt inner width)
  // =========================================================
  static pw.Widget halfWidthBox({
    required pw.Widget titleContent, 
    required pw.Widget mainContent,  
    double titleHeight = 9.8,
    double? contentHeight,           
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title Row
        pw.Container(
          height: titleHeight,
          width: 275.75, // 275.4 + 0.35pt missing width
          padding: const pw.EdgeInsets.symmetric(horizontal: 3.6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            border: pw.Border.all(color: borderSide.color, width: borderSide.width),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [titleContent],
          ),
        ),
        // Content Row
        pw.Container(
          height: contentHeight,
          width: 275.75, // 275.4 + 0.35pt missing width
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: borderSide, right: borderSide, bottom: borderSide,
            ),
          ),
          child: mainContent,
        ),
      ],
    );
  }

  // 7. LEGO BLOCK: Dynamic Data Line (Strict Vertical Grid Alignment)
  static pw.Widget buildDynamicLine(String label, String value, double labelWidth) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start, 
      children: [
        pw.SizedBox(
          width: labelWidth,
          child: pw.Text(label, style: titleText),
        ),
        pw.Expanded( 
          child: pw.Text(value, style: inputBlue),
        ),
      ],
    );
  }

  // 8. LEGO BLOCK: Smart Address Line (Handles optional 'bus' formatting seamlessly)
  static pw.Widget buildAddressLine(String label, String straat, String nr, String bus, double labelWidth) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: labelWidth,
          child: pw.Text(label, style: titleText),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$straat $nr'.trim(), 
                  style: inputBlue,
                ),
                // Conditionally render the black bus label and blue bus data
                if (bus.trim().isNotEmpty) ...[
                  pw.TextSpan(text: '  bus: ', style: titleText),
                  pw.TextSpan(text: bus.trim(), style: inputBlue),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 9. LEGO BLOCK: Smart Prefixed Line (Auto-injects +32, BE, etc. safely)
  static pw.Widget buildPrefixedLine(String label, String value, String prefix, double labelWidth) {
    String displayValue = value.trim();
    
    // Safely check and apply the prefix if it's missing
    if (displayValue.isNotEmpty && !displayValue.toUpperCase().startsWith(prefix.toUpperCase().trim())) {
      displayValue = '$prefix $displayValue';
    }
    
    // Re-use our existing dynamic line builder to render it!
    return buildDynamicLine(label, displayValue, labelWidth);
  }

  // 10. LEGO BLOCK: Labeled Checkbox + Dynamic Blue Text on the same line
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
        pw.SizedBox(width: 2.0), // Tiny gap before the input
        pw.Expanded(
          child: pw.Text(inputText, style: inputBlue),
        ),
      ],
    );
  }

// 11. LEGO BLOCK: Inline Input Checkbox
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