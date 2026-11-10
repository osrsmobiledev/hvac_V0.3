import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Result object returned after attempting to save a PDF file to device storage.
class PdfSaveResult {
  final bool isSuccess;
  final String filePath;
  final String? errorMessage;

  const PdfSaveResult({
    required this.isSuccess,
    required this.filePath,
    this.errorMessage,
  });
}

/// Service responsible for persisting generated PDF bytes directly to the device storage
/// (preferring public Downloads folder, with robust fallbacks for sandboxed storage).
abstract final class PdfFileSaver {
  static const _channel = MethodChannel('com.example.hvac_app/storage');

  /// Saves the given [pdfBytes] to the device storage under the given [attestNumber].
  static Future<PdfSaveResult> saveToDevice({
    required Uint8List pdfBytes,
    required String attestNumber,
    Directory? overrideDirectory,
  }) async {
    try {
      final sanitizedAttest = attestNumber.trim().isNotEmpty
          ? attestNumber.trim().replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_')
          : 'concept';

      final fileName = 'Verbrandingsattest_$sanitizedAttest.pdf';
      final pngName = 'Verbrandingsattest_$sanitizedAttest.png';

      // 1. Try overrideDirectory if supplied (useful for unit tests)
      if (overrideDirectory != null) {
        final targetFile = File('${overrideDirectory.path}/$fileName');
        await targetFile.writeAsBytes(pdfBytes, flush: true);
        return PdfSaveResult(isSuccess: true, filePath: targetFile.path);
      }

      // 2. On Android, save directly to public Downloads via MediaStore
      if (!kIsWeb && Platform.isAndroid) {
        final mediaStorePath = await _saveViaMediaStore(
          fileName: fileName,
          bytes: pdfBytes,
          mimeType: 'application/pdf',
        );
        if (mediaStorePath != null) {
          debugPrint(
              '[PdfFileSaver] Saved PDF via MediaStore to: $mediaStorePath');
          await _generateRasterPreview(
            pdfBytes: pdfBytes,
            pngName: pngName,
          );
          return PdfSaveResult(isSuccess: true, filePath: mediaStorePath);
        }
      }

      // 3. Fallback: Try direct public Downloads path
      if (!kIsWeb && Platform.isAndroid) {
        const publicDownloadPath = '/storage/emulated/0/Download';
        final publicDownloadDir = Directory(publicDownloadPath);
        if (await publicDownloadDir.exists()) {
          try {
            final targetFile = File('$publicDownloadPath/$fileName');
            await targetFile.writeAsBytes(pdfBytes, flush: true);
            await _generateRasterPreview(
              pdfBytes: pdfBytes,
              targetDirectory: publicDownloadDir,
              pngName: pngName,
            );
            return PdfSaveResult(isSuccess: true, filePath: targetFile.path);
          } catch (e) {
            debugPrint(
                '[PdfFileSaver] Public download direct write failed: $e');
          }
        }
      }

      // 4. Fallback: Try standard path_provider downloads directory
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final targetFile = File('${downloadsDir.path}/$fileName');
          await targetFile.writeAsBytes(pdfBytes, flush: true);
          await _generateRasterPreview(
            pdfBytes: pdfBytes,
            targetDirectory: downloadsDir,
            pngName: pngName,
          );
          return PdfSaveResult(isSuccess: true, filePath: targetFile.path);
        }
      } catch (e) {
        debugPrint('[PdfFileSaver] getDownloadsDirectory failed: $e');
      }

      // 5. Ultimate fallback: Application Documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${docsDir.path}/$fileName');
      await targetFile.writeAsBytes(pdfBytes, flush: true);
      await _generateRasterPreview(
        pdfBytes: pdfBytes,
        targetDirectory: docsDir,
        pngName: pngName,
      );
      return PdfSaveResult(isSuccess: true, filePath: targetFile.path);
    } catch (e, stack) {
      debugPrint('[PdfFileSaver] saveToDevice failed: $e\n$stack');
      return PdfSaveResult(
        isSuccess: false,
        filePath: '',
        errorMessage: e.toString(),
      );
    }
  }

  static Future<String?> _saveViaMediaStore({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      final path = await _channel.invokeMethod<String>(
        'saveToDownloads',
        {
          'fileName': fileName,
          'bytes': bytes,
          'mimeType': mimeType,
        },
      );
      return path;
    } catch (e) {
      debugPrint('[PdfFileSaver] _saveViaMediaStore failed: $e');
      return null;
    }
  }

  /// Silently rasters the first page of the PDF into a crisp 200 DPI PNG image
  /// for immediate crystal-clear inspection in GIMP or image viewer.
  static Future<void> _generateRasterPreview({
    required Uint8List pdfBytes,
    required String pngName,
    Directory? targetDirectory,
  }) async {
    try {
      final rasterPages = Printing.raster(pdfBytes, pages: [0], dpi: 200.0);
      await for (final page in rasterPages) {
        final pngBytes = await page.toPng();

        if (targetDirectory != null) {
          final pngFile = File('${targetDirectory.path}/$pngName');
          await pngFile.writeAsBytes(pngBytes, flush: true);
          debugPrint('[PdfFileSaver] Saved PNG to directory: ${pngFile.path}');
        } else if (!kIsWeb && Platform.isAndroid) {
          final mediaStorePngPath = await _saveViaMediaStore(
            fileName: pngName,
            bytes: pngBytes,
            mimeType: 'image/png',
          );
          debugPrint(
              '[PdfFileSaver] Saved PNG via MediaStore: $mediaStorePngPath');
        }
        break;
      }
    } catch (e) {
      debugPrint('[PdfFileSaver] PNG preview raster skipped (non-fatal): $e');
    }
  }
}
