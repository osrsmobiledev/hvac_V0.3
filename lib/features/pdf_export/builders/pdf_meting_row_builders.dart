import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/pdf_components.dart';

/// Reusable 7-column data row and subheader widgets for the PDF measurement table.
abstract final class PdfMetingRowBuilders {
  static const double w1 = 272.3;
  static const double w2 = 47.05;
  static const double w3 = 47.05;
  static const double w4 = 70.1;
  static const double w5 = 70.1;
  static const double w5Laag = 35.05;
  static const double w5Hoog = 35.05;
  static const double w6 = 21.5;
  static const double w7 = 21.1;

  static pw.Widget buildSubHeaderRow(String title) {
    return pw.Container(
      height: 9.8,
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
        border: pw.Border(
          top: pw.BorderSide(width: 0.2, color: PdfColors.black),
          bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
        ),
      ),
      padding: const pw.EdgeInsets.only(left: 5.6),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(title, style: PdfComponents.titleBoldText),
    );
  }

  static pw.Widget buildDataRow({
    String label = '',
    pw.Widget? customLabel,
    required String unit,
    pw.Widget? customUnit,
    required String brandstof,
    String proef1 = '',
    pw.Widget? customProef1,
    String proef2Laag = '',
    String proef2Hoog = '',
    pw.Widget? customProef2,
    pw.Widget? customCol6,
    pw.Widget? customCol7,
    PdfColor? col2Color,
    PdfColor? col4Color,
    PdfColor? col5Color,
    PdfColor? col6Color,
    PdfColor? col7Color,
    bool isMerged = false,
    double rowHeight = 14.4,
  }) {
    pw.Widget gridCell({
      required double width,
      required pw.Widget child,
      bool rightBorder = true,
    }) {
      return pw.Container(
        width: width,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: rightBorder ? PdfComponents.borderSide : pw.BorderSide.none,
          ),
        ),
        child: child,
      );
    }

    return pw.Container(
      height: rowHeight,
      foregroundDecoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.2, color: PdfColors.black),
          bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
        ),
      ),
      child: pw.Stack(
        children: [
          // Layer 1: Background tint fills
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.SizedBox(width: w1),
                pw.Container(width: w2, color: col2Color),
                pw.SizedBox(width: w3),
                if (isMerged)
                  pw.Container(width: w4 + w5 + w6 + w7 + 0.5, color: col4Color)
                else ...[
                  pw.Container(width: w4, color: col4Color),
                  pw.Container(width: w5Laag, color: col5Color),
                  pw.Container(width: w5Hoog, color: col5Color),
                  pw.Container(width: w6, color: col6Color),
                  pw.Container(width: w7 + 0.5, color: col7Color),
                ],
              ],
            ),
          ),

          // Layer 2: Cell contents and vertical hairline dividers
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 3.6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                gridCell(
                  width: w1,
                  child: pw.Container(
                    padding: pw.EdgeInsets.only(
                      left: isMerged ? 1.5 : 2.0,
                      right: isMerged ? 1.0 : 0.0,
                    ),
                    alignment: pw.Alignment.centerLeft,
                    child: isMerged
                        ? pw.FittedBox(
                            fit: pw.BoxFit.scaleDown,
                            alignment: pw.Alignment.centerLeft,
                            child: customLabel ??
                                pw.Text(label, style: PdfComponents.titleText),
                          )
                        : (customLabel ??
                            pw.Text(label, style: PdfComponents.titleText)),
                  ),
                ),
                gridCell(
                  width: w2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(left: 2.0),
                    alignment: pw.Alignment.centerLeft,
                    child: customUnit ??
                        pw.Text(unit, style: PdfComponents.titleText),
                  ),
                ),
                gridCell(
                  width: w3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(left: 2.0),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(brandstof, style: PdfComponents.titleText),
                  ),
                ),
                if (isMerged)
                  gridCell(
                    width: w4 + w5 + w6 + w7,
                    rightBorder: false,
                    child: customProef1 ?? pw.SizedBox(),
                  )
                else ...[
                  gridCell(
                    width: w4,
                    child: customProef1 ??
                        pw.Container(
                          alignment: pw.Alignment.center,
                          child:
                              pw.Text(proef1, style: PdfComponents.inputBlue),
                        ),
                  ),
                  gridCell(
                    width: w5Laag,
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      child:
                          pw.Text(proef2Laag, style: PdfComponents.inputBlue),
                    ),
                  ),
                  gridCell(
                    width: w5Hoog,
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      child:
                          pw.Text(proef2Hoog, style: PdfComponents.inputBlue),
                    ),
                  ),
                  gridCell(width: w6, child: customCol6 ?? pw.SizedBox()),
                  gridCell(
                    width: w7,
                    rightBorder: false,
                    child: customCol7 ?? pw.SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
