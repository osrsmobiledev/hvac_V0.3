import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late EmailOutboxRepository outbox;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);

    // Seed a minimal visit so the foreign key constraint is satisfied if checked
    await db.insert('maintenance_visits', {
      'id': 1,
      'visit_date': '2026-01-01',
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
      'is_draft': 0,
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('EmailOutboxRepository Unit Tests', () {
    test('creates queued jobs for both customer and technician', () async {
      final jobs = [
        const EmailJobSpec(
          visitId: 1,
          recipientType: RecipientType.customer,
          recipientName: 'Jan Peeters',
          recipientEmail: 'jan@example.com',
          subject: 'Verbrandingsattest 2026/001',
          bodyText: 'Beste klant, hierbij uw attest.',
          pdfPath: '/path/to/cert.pdf',
        ),
        const EmailJobSpec(
          visitId: 1,
          recipientType: RecipientType.technician,
          recipientName: 'Technicus',
          recipientEmail: 'tech@example.com',
          subject: 'Verbrandingsattest 2026/001 (kopie)',
          bodyText: 'Kopie technicus.',
          pdfPath: '/path/to/cert.pdf',
        ),
      ];

      final inserted = await outbox.createJobs(jobs);
      expect(inserted, equals(2));

      final rows = await outbox.getJobsForVisit(1);
      expect(rows.length, equals(2));

      final customerJob =
          rows.firstWhere((r) => r['recipient_type'] == 'customer');
      expect(customerJob['status'], equals('queued'));
      expect(customerJob['attempt_count'], equals(0));
      expect(customerJob['recipient_email'], equals('jan@example.com'));
      expect(
          customerJob['original_recipient_email'], equals('jan@example.com'));
      expect(customerJob['pdf_path'], equals('/path/to/cert.pdf'));

      final techJob =
          rows.firstWhere((r) => r['recipient_type'] == 'technician');
      expect(techJob['status'], equals('queued'));
      expect(techJob['recipient_email'], equals('tech@example.com'));
    });

    test('prevents duplicate jobs for same visit and recipient type', () async {
      const job = EmailJobSpec(
        visitId: 1,
        recipientType: RecipientType.customer,
        recipientName: 'Jan Peeters',
        recipientEmail: 'jan@example.com',
        subject: 'Verbrandingsattest 2026/001',
        bodyText: 'Beste klant, hierbij uw attest.',
        pdfPath: '/path/to/cert.pdf',
      );

      final firstInsert = await outbox.createJobs([job]);
      expect(firstInsert, equals(1));

      // Attempting to re-insert the identical visit + recipient pair
      final secondInsert = await outbox.createJobs([job]);
      expect(secondInsert, equals(0));

      final rows = await outbox.getJobsForVisit(1);
      expect(rows.length, equals(1));
    });

    test('returns 0 when jobs list is empty', () async {
      final inserted = await outbox.createJobs([]);
      expect(inserted, equals(0));
    });

    test(
        'refuses to store jobs with empty or whitespace-only pdfPath (all-or-nothing)',
        () async {
      const emptyJob = EmailJobSpec(
        visitId: 1,
        recipientType: RecipientType.customer,
        recipientName: 'Jan',
        recipientEmail: 'jan@example.com',
        subject: 'Attest',
        bodyText: 'Body',
        pdfPath: '',
      );
      expect(
        () => outbox.createJobs([emptyJob]),
        throwsA(isA<ArgumentError>()),
      );
      expect(await outbox.getJobsForVisit(1), isEmpty);

      const whitespaceJob = EmailJobSpec(
        visitId: 1,
        recipientType: RecipientType.customer,
        recipientName: 'Jan',
        recipientEmail: 'jan@example.com',
        subject: 'Attest',
        bodyText: 'Body',
        pdfPath: '   ',
      );
      expect(
        () => outbox.createJobs([whitespaceJob]),
        throwsA(isA<ArgumentError>()),
      );
      expect(await outbox.getJobsForVisit(1), isEmpty);

      const validJob = EmailJobSpec(
        visitId: 1,
        recipientType: RecipientType.customer,
        recipientName: 'Jan',
        recipientEmail: 'jan@example.com',
        subject: 'Attest',
        bodyText: 'Body',
        pdfPath: '/path/to/valid.pdf',
      );
      const invalidSecondJob = EmailJobSpec(
        visitId: 1,
        recipientType: RecipientType.technician,
        recipientName: 'Tech',
        recipientEmail: 'tech@example.com',
        subject: 'Attest (kopie)',
        bodyText: 'Body',
        pdfPath: '',
      );
      expect(
        () => outbox.createJobs([validJob, invalidSecondJob]),
        throwsA(isA<ArgumentError>()),
      );
      expect(await outbox.getJobsForVisit(1), isEmpty);
    });
  });
}
