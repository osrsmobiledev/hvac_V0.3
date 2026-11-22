import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/certificate_draft/ui/visit_finalization.dart';
import 'package:hvac_app/features/email_delivery/data/archive_outcome.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _JobCallRecord {
  final int visitId;
  final String pdfPath;
  final bool sendCustomer;
  final String customerEmail;
  final bool sendTech;
  final String techEmail;
  final String attest;

  const _JobCallRecord(this.visitId, this.pdfPath, this.sendCustomer,
      this.customerEmail, this.sendTech, this.techEmail, this.attest);
}

class _FakeCoordinator extends PdfArchivingCoordinator {
  final ArchiveOutcome outcome;
  final jobCalls = <_JobCallRecord>[];
  bool throwOnFirstCall;

  _FakeCoordinator({
    required this.outcome,
    this.throwOnFirstCall = false,
  });

  @override
  Future<ArchiveOutcome> archiveAndUpdateStatus(int visitId) async => outcome;

  @override
  Future<EmailQueueResult> createEmailJobs({
    required int visitId,
    required String pdfPath,
    required bool sendToCustomer,
    required String customerName,
    required String customerEmail,
    required bool sendToTechnician,
    required String technicianEmail,
    required String attestNumber,
  }) async {
    jobCalls.add(_JobCallRecord(visitId, pdfPath, sendToCustomer, customerEmail,
        sendToTechnician, technicianEmail, attestNumber));
    if (throwOnFirstCall && jobCalls.length == 1) {
      throw Exception('Simulated SQLite outbox lock');
    }
    return EmailQueueResult.queued;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final successSnapshot = {
    'format_version': 1,
    'visit': {'attest_number': 'ATTEST-2026-01', 'activity_type': 'onderhoud'},
    'profile': {'company_name': 'Test BV', 'email': 'tech@example.com'},
    'customer': {
      'first_name': 'Karel',
      'last_name': 'Willems',
      'email': 'karel@example.com',
    },
    'location': {'street': 'Dorpstraat', 'house_number': '12'},
    'boiler': {'fuel_type': 'gas'},
    'initial': <String, Object?>{},
    'low': <String, Object?>{},
    'high': <String, Object?>{},
    'technician_signature': null,
    'customer_signature': null,
  };

  group('Database & File Integrity on Queue Failure', () {
    late Directory tempDir;
    late Database db;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('coord_fail_test_');
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => DatabaseSchema.createAllTables(db),
        ),
      );
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('failure or skip leaves finalized visit and archived PDF intact',
        () async {
      final pdfFile = File(p.join(tempDir.path, 'visit_42.pdf'));
      await pdfFile.writeAsBytes([1, 2, 3, 4]);

      await db.insert('maintenance_visits', {
        'id': 42,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'ready',
        'pdf_path': pdfFile.path,
        'snapshot_json': jsonEncode(successSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final throwingOutbox = EmailOutboxRepository(
        database: () async => throw Exception('Simulated locked outbox'),
      );
      final coordinator = PdfArchivingCoordinator(
        database: () async => db,
        outboxRepository: throwingOutbox,
        documentsDirectoryOverride: tempDir,
      );

      expect(
        () => coordinator.createEmailJobs(
          visitId: 42,
          pdfPath: pdfFile.path,
          sendToCustomer: true,
          customerName: 'Karel',
          customerEmail: 'karel@example.com',
          sendToTechnician: false,
          technicianEmail: '',
          attestNumber: 'ATTEST-42',
        ),
        throwsException,
      );

      final row =
          (await db.query('maintenance_visits', where: 'id = 42')).single;
      expect(row['is_draft'], equals(0));
      expect(row['pdf_status'], equals('ready'));
      expect(row['pdf_path'], equals(pdfFile.path));
      expect(row['snapshot_json'], isNotEmpty);
      expect(pdfFile.existsSync(), isTrue);

      final jobs = await db.query('email_delivery_jobs');
      expect(jobs, isEmpty);
    });
  });

  group('VisitFinalization Outbox Retry Flow & Assertions', () {
    final readyOutcome = ArchiveOutcome(
      archiveSuccess: true,
      archivePath: '/certificates/test.pdf',
      copyTechnicianDefault: false,
      technicianEmail: '',
      snapshot: successSnapshot,
    );

    Widget buildTestApp(PdfArchivingCoordinator coordinator) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => VisitFinalization.archiveAndPromptRecipients(
                    ctx, 42,
                    coordinatorOverride: coordinator),
                child: const Text('Voltooien'),
              ),
            ),
          ),
        );

    testWidgets('retry reuses identical visit ID, PDF path and recipients',
        (tester) async {
      final fake =
          _FakeCoordinator(outcome: readyOutcome, throwOnFirstCall: true);

      await tester.pumpWidget(buildTestApp(fake));
      await tester.tap(find.text('Voltooien'));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(EmailDeliveryDictionary.finalizeAndEmailAction));
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.outboxRetryDialogTitle),
          findsOneWidget);
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      await tester.tap(find.text(EmailDeliveryDictionary.outboxRetryAction));
      await tester.pumpAndSettle();

      expect(fake.jobCalls.length, equals(2));
      final c0 = fake.jobCalls[0];
      final c1 = fake.jobCalls[1];
      expect(c1.visitId, equals(c0.visitId));
      expect(c1.pdfPath, equals(c0.pdfPath));
      expect(c1.sendCustomer, equals(c0.sendCustomer));
      expect(c1.customerEmail, equals(c0.customerEmail));
      expect(c1.sendTech, equals(c0.sendTech));
      expect(c1.techEmail, equals(c0.techEmail));
      expect(c1.attest, equals(c0.attest));

      expect(find.text(EmailDeliveryDictionary.recipientJobsQueued),
          findsOneWidget);
    });

    testWidgets('explicit skip after queue failure shows neutral info feedback',
        (tester) async {
      final fake =
          _FakeCoordinator(outcome: readyOutcome, throwOnFirstCall: true);

      await tester.pumpWidget(buildTestApp(fake));
      await tester.tap(find.text('Voltooien'));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(EmailDeliveryDictionary.finalizeAndEmailAction));
      await tester.pumpAndSettle();

      await tester.tap(find.text(EmailDeliveryDictionary.outboxRetryCancel));
      await tester.pumpAndSettle();

      expect(
        find.text(EmailDeliveryDictionary.outboxQueueSkippedAfterFailure),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });
  });
}
