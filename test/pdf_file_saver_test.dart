import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/pdf_export/services/pdf_file_saver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdf_saver_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PdfFileSaver Unit Tests', () {
    test('saveToDevice writes bytes to overrideDirectory and returns success',
        () async {
      final dummyBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]);

      final result = await PdfFileSaver.saveToDevice(
        pdfBytes: dummyBytes,
        attestNumber: '2026/001:TEST',
        overrideDirectory: tempDir,
      );

      expect(result.isSuccess, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.filePath, contains('Verbrandingsattest_2026_001_TEST.pdf'));

      final writtenFile = File(result.filePath);
      expect(await writtenFile.exists(), isTrue);
      final readBytes = await writtenFile.readAsBytes();
      expect(readBytes, equals(dummyBytes));
    });

    test(
        'saveToDevice falls back to concept filename when attestNumber is empty',
        () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);

      final result = await PdfFileSaver.saveToDevice(
        pdfBytes: dummyBytes,
        attestNumber: '   ',
        overrideDirectory: tempDir,
      );

      expect(result.isSuccess, isTrue);
      expect(result.filePath, contains('Verbrandingsattest_concept.pdf'));
      expect(File(result.filePath).existsSync(), isTrue);
    });
  });
}
