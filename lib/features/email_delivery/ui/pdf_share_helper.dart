import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';

import '../../../app/localization/email_delivery_dictionary.dart';

typedef SharePdfFunction = Future<void> Function(
    List<int> bytes, String filename);

/// Helper providing asynchronous, UI-safe PDF sharing via standard platform share sheets.
abstract final class PdfShareHelper {
  static Future<void> sharePdf(
    BuildContext context,
    String pdfPath, {
    SharePdfFunction? sharePdfOverride,
  }) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(EmailDeliveryDictionary.sharePdfError)),
          );
        }
        return;
      }
      final bytes = await file.readAsBytes();
      final filename = p.basename(pdfPath);
      if (sharePdfOverride != null) {
        await sharePdfOverride(bytes, filename);
      } else {
        await Printing.sharePdf(bytes: bytes, filename: filename);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(EmailDeliveryDictionary.sharePdfError)),
        );
      }
    }
  }
}
