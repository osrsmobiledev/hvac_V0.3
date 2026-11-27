import 'dart:typed_data';
import 'cleaning_pdf_generator.dart';
import 'combustion_pdf_generator.dart';
import 'data/pdf_visit_data.dart';

/// Single dispatcher routing certificate PDF generation and file naming by
/// `certificateType` (`'verbranding'` vs `'reiniging'`).
abstract final class CertificatePdfDispatcher {
  /// Returns the canonical Flemish document prefix for [certificateType].
  static String documentPrefix(String certificateType) =>
      certificateType.trim().toLowerCase() == 'reiniging'
          ? 'Reinigingsattest'
          : 'Verbrandingsattest';

  /// Generates the single-page A4 PDF bytes for [data].
  static Future<Uint8List> generateCertificate(
    PdfVisitData data, {
    String? certificateTypeOverride,
  }) {
    final effectiveType =
        (certificateTypeOverride ?? data.cleaning.certificateType)
            .trim()
            .toLowerCase();
    return effectiveType == 'reiniging'
        ? CleaningPdfGenerator.generateCertificate(data)
        : CombustionPdfGenerator.generateCertificate(data);
  }
}
