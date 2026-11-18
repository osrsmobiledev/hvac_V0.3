import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  final sampleSnapshot = jsonEncode({
    'format_version': 1,
    'visit': {'attest_number': '2026/001'},
    'profile': {'company_name': 'HVAC Test BV', 'email': 'tech@example.com'},
    'customer': {
      'first_name': 'Jan',
      'last_name': 'Peeters',
      'email': 'jan@example.com'
    },
    'location': {'street': 'Kerkstraat', 'house_number': '1'},
    'boiler': {'fuel_type': 'gas'},
    'initial': <String, Object?>{},
    'low': <String, Object?>{},
    'high': <String, Object?>{},
    'technician_signature': null,
    'customer_signature': null,
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdf_archive_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PdfArchiveService Unit Tests', () {
    test('archives PDF through .tmp staging and rename into certificates/',
        () async {
      final result = await PdfArchiveService.archiveCertificate(
        visitId: 42,
        snapshotJson: sampleSnapshot,
        documentsDirectoryOverride: tempDir,
      );

      expect(result.isSuccess, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.archivePath, isNotEmpty);
      expect(result.archivePath, contains('certificates'));
      expect(result.archivePath, contains('visit_42_2026_001_v'));
      expect(result.archivePath.endsWith('.pdf'), isTrue);

      // Verify file exists on disk and is a valid PDF
      final file = File(result.archivePath);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(100));
      expect(String.fromCharCodes(bytes.take(5)), equals('%PDF-'));

      // Verify staging directory has no lingering files
      final stagingDir = Directory('${tempDir.path}/certificates/staging');
      if (await stagingDir.exists()) {
        final stagingFiles = await stagingDir.list().toList();
        expect(stagingFiles, isEmpty);
      }
    });

    test(
        'serializes concurrent archive requests producing unique versioned files',
        () async {
      final futures = [
        PdfArchiveService.archiveCertificate(
          visitId: 101,
          snapshotJson: sampleSnapshot,
          documentsDirectoryOverride: tempDir,
        ),
        PdfArchiveService.archiveCertificate(
          visitId: 101,
          snapshotJson: sampleSnapshot,
          documentsDirectoryOverride: tempDir,
        ),
      ];

      final results = await Future.wait(futures);
      expect(results[0].isSuccess, isTrue);
      expect(results[1].isSuccess, isTrue);
      expect(results[0].archivePath, isNot(equals(results[1].archivePath)));
      expect(File(results[0].archivePath).existsSync(), isTrue);
      expect(File(results[1].archivePath).existsSync(), isTrue);
      expect(results[0].archivePath, contains('visit_101_'));
      expect(results[1].archivePath, contains('visit_101_'));
    });

    test('cleanupStagingFiles deletes orphaned .tmp files only', () async {
      final stagingDir = Directory('${tempDir.path}/certificates/staging');
      await stagingDir.create(recursive: true);
      final certDir = Directory('${tempDir.path}/certificates');
      await certDir.create(recursive: true);

      final orphanTmp = File('${stagingDir.path}/orphan_1.tmp');
      await orphanTmp.writeAsString('corrupted or incomplete data');

      final nonTmp = File('${stagingDir.path}/readme.txt');
      await nonTmp.writeAsString('do not delete');

      final legitimateCert =
          File('${certDir.path}/visit_1_2026_001_v12345_1.pdf');
      await legitimateCert.writeAsString('kept certificate');

      await PdfArchiveService.cleanupStagingFiles(
        documentsDirectoryOverride: tempDir,
      );

      expect(await orphanTmp.exists(), isFalse);
      expect(await nonTmp.exists(), isTrue);
      expect(await legitimateCert.exists(), isTrue);
    });

    test('returns failure outcome when snapshot JSON is invalid', () async {
      final result = await PdfArchiveService.archiveCertificate(
        visitId: 99,
        snapshotJson: 'invalid { json',
        documentsDirectoryOverride: tempDir,
      );

      expect(result.isSuccess, isFalse);
      expect(result.archivePath, isEmpty);
      expect(result.errorMessage, isNotNull);
    });
  });
}
