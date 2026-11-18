import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/ui/visit_finalization.dart';
import 'package:hvac_app/features/email_delivery/data/archive_outcome.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archive_service.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:path/path.dart' as p;

class _FakeRegCoordinator extends PdfArchivingCoordinator {
  ArchiveOutcome initialOutcome;
  int registerCalls = 0, deleteCalls = 0;
  int? registeredVisitId;
  String? registeredArchivePath, deletedPath;
  bool fileExists, deleteSuccess;

  _FakeRegCoordinator({
    required this.initialOutcome,
    this.fileExists = true,
    this.deleteSuccess = true,
    super.documentsDirectoryOverride,
  });

  @override
  Future<ArchiveOutcome> archiveAndUpdateStatus(int visitId) async =>
      initialOutcome;

  @override
  Future<bool> archiveFileExists(String path) async => fileExists;

  @override
  Future<bool> deleteUnregisteredArchiveFile(String path) async {
    deleteCalls++;
    deletedPath = path;
    if (!deleteSuccess) return false;
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
    return true;
  }

  @override
  Future<bool> registerArchivedPdf(
      {required int visitId, required String archivePath}) async {
    registerCalls++;
    registeredVisitId = visitId;
    registeredArchivePath = archivePath;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testSnapshot = {
    'format_version': 1,
    'visit': {'attest_number': 'AT-10'},
    'customer': {'first_name': 'Jan', 'email': 'j@e.com'},
  };

  ArchiveOutcome failureOutcome(String path, [Map<String, Object?>? snap]) =>
      ArchiveOutcome(
        archiveSuccess: false,
        archivePath: path,
        isDatabaseRegistrationFailure: true,
        copyTechnicianDefault: false,
        technicianEmail: '',
        snapshot: snap ?? const {},
      );

  group('PdfArchiveService File Deletion & Security Unit Tests', () {
    late Directory tempDir, certDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('reg_sec_test_');
      certDir = Directory(p.join(tempDir.path, 'certificates'))..createSync();
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('deleteUnregisteredArchiveFile removes file in certificates/',
        () async {
      final file = File(p.join(certDir.path, 'unreg.pdf'))
        ..writeAsBytesSync([1]);
      expect(file.existsSync(), isTrue);
      final ok = await PdfArchiveService.deleteUnregisteredArchiveFile(
        file.path,
        documentsDirectoryOverride: tempDir,
      );
      expect(ok, isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('refuses to delete files outside certificates directory', () async {
      final out = File(p.join(tempDir.path, 'out.pdf'))..writeAsBytesSync([2]);
      expect(out.existsSync(), isTrue);
      final ok = await PdfArchiveService.deleteUnregisteredArchiveFile(
        out.path,
        documentsDirectoryOverride: tempDir,
      );
      expect(ok, isFalse);
      expect(out.existsSync(), isTrue);
    });
  });

  group('VisitFinalization Registration Failure & Recovery UI Tests', () {
    late Directory tempDir, certDir;
    late File unregisteredFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('reg_ui_test_');
      certDir = Directory(p.join(tempDir.path, 'certificates'))..createSync();
      unregisteredFile = File(p.join(certDir.path, 'test_unreg.pdf'))
        ..writeAsBytesSync([7, 8, 9]);
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    Widget buildTestApp(PdfArchivingCoordinator coordinator) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => VisitFinalization.archiveAndPromptRecipients(
                    ctx, 10,
                    coordinatorOverride: coordinator),
                child: const Text('Voltooien'),
              ),
            ),
          ),
        );

    Future<void> tapText(WidgetTester t, String text) async {
      await t.tap(find.text(text));
      await t.pumpAndSettle();
    }

    testWidgets('retry records exact visit ID and path on success',
        (tester) async {
      final fake = _FakeRegCoordinator(
        documentsDirectoryOverride: tempDir,
        initialOutcome: failureOutcome(unregisteredFile.path, testSnapshot),
      );

      await tester.pumpWidget(buildTestApp(fake));
      await tapText(tester, 'Voltooien');

      expect(find.text(EmailDeliveryDictionary.pdfRegistrationRetryTitle),
          findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);

      await tapText(tester, EmailDeliveryDictionary.pdfRegistrationRetryAction);

      expect(fake.registerCalls, equals(1));
      expect(fake.registeredVisitId, equals(10));
      expect(fake.registeredArchivePath, equals(unregisteredFile.path));
      expect(find.text(EmailDeliveryDictionary.recipientDialogTitle),
          findsOneWidget);
    });

    testWidgets('missing file on retry shows error and keeps retry dialog open',
        (tester) async {
      final fake = _FakeRegCoordinator(
        documentsDirectoryOverride: tempDir,
        fileExists: false,
        initialOutcome: failureOutcome(unregisteredFile.path, testSnapshot),
      );

      await tester.pumpWidget(buildTestApp(fake));
      await tapText(tester, 'Voltooien');
      await tapText(tester, EmailDeliveryDictionary.pdfRegistrationRetryAction);

      expect(fake.registerCalls, equals(0));
      expect(find.text(EmailDeliveryDictionary.pdfFileNotFoundError),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.pdfRegistrationRetryTitle),
          findsOneWidget);
    });

    testWidgets('skip requires two-step confirmation before deleting file',
        (tester) async {
      final fake = _FakeRegCoordinator(
        documentsDirectoryOverride: tempDir,
        initialOutcome: failureOutcome(unregisteredFile.path),
      );

      await tester.pumpWidget(buildTestApp(fake));
      await tapText(tester, 'Voltooien');
      await tapText(tester, EmailDeliveryDictionary.pdfRegistrationRetryCancel);

      expect(
          find.text(EmailDeliveryDictionary.pdfRegistrationDeleteConfirmTitle),
          findsOneWidget);

      await tapText(
          tester, EmailDeliveryDictionary.pdfRegistrationDeleteConfirmCancel);

      expect(fake.deleteCalls, equals(0));
      expect(unregisteredFile.existsSync(), isTrue);
      expect(find.text(EmailDeliveryDictionary.pdfRegistrationRetryTitle),
          findsOneWidget);

      await tapText(tester, EmailDeliveryDictionary.pdfRegistrationRetryCancel);
      await tapText(
          tester, EmailDeliveryDictionary.pdfRegistrationDeleteConfirmAction);

      expect(fake.deleteCalls, equals(1));
      expect(fake.deletedPath, equals(unregisteredFile.path));
      expect(unregisteredFile.existsSync(), isFalse);
      expect(find.text(EmailDeliveryDictionary.pdfRegistrationFailed),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.pdfDeleteFailedError),
          findsNothing);
    });

    testWidgets('failed file deletion on skip shows delete error feedback',
        (tester) async {
      final fake = _FakeRegCoordinator(
        documentsDirectoryOverride: tempDir,
        deleteSuccess: false,
        initialOutcome: failureOutcome(unregisteredFile.path),
      );

      await tester.pumpWidget(buildTestApp(fake));
      await tapText(tester, 'Voltooien');
      await tapText(tester, EmailDeliveryDictionary.pdfRegistrationRetryCancel);
      await tapText(
          tester, EmailDeliveryDictionary.pdfRegistrationDeleteConfirmAction);

      expect(fake.deleteCalls, equals(1));
      expect(unregisteredFile.existsSync(), isTrue);
      expect(find.text(EmailDeliveryDictionary.pdfDeleteFailedError),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.pdfRegistrationFailed),
          findsNothing);
    });
  });
}
