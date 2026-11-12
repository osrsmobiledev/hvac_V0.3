import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Renders a single rasterized PDF page with card styling and elevation shadow.
class PdfPageCard extends StatelessWidget {
  final PdfPreviewPageData page;

  const PdfPageCard({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: page.aspectRatio,
        child: Image(
          image: page.image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
