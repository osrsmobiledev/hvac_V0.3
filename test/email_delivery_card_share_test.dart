import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late EmailOutboxRepository outbox;
  late File dummyPdf;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('card_share_test_');
    dummyPdf = File(p.join(tempDir.path, 'test_cert.pdf'))
      ..writeAsBytesSync([1, 2, 3, 4]);
    db = await databaseFactoryFfi.openDatabase(
      p.join(tempDir.path, 'test.db'),
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);
    await db.insert('maintenance_visits', {
      'id': 42,
      'visit_date': '2026-02-01',
      'is_draft': 0,
      'pdf_status': 'ready',
      'pdf_path': dummyPdf.path,
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01',
    });
  });

  tearDown(() async {
    await db.close();
    try {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<void> insertJob(
    WidgetTester tester, {
    required int id,
    String? pdfPathOverride,
  }) =>
      tester.runAsync(() => db.insert('email_delivery_jobs', {
            'id': id,
            'visit_id': 42,
            'recipient_type': 'customer',
            'recipient_name': 'Jan',
            'recipient_email': 'jan@example.com',
            'original_recipient_email': 'jan@example.com',
            'subject': 'Attest',
            'body_text': 'Body',
            'pdf_path': pdfPathOverride ?? dummyPdf.path,
            'status': 'sent',
            'attempt_count': 1,
            'created_at': '2026-02-01',
            'updated_at': '2026-02-01',
          }));

  Future<void> pumpCard(WidgetTester tester) async {
    for (int i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('Native share delegates asynchronously to sharePdfOverride',
      (tester) async {
    await insertJob(tester, id: 4);
    List<int>? sharedBytes;
    String? sharedFilename;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
          visitId: 42,
          outboxRepository: outbox,
          sharePdfOverride: (bytes, filename) async {
            sharedBytes = bytes;
            sharedFilename = filename;
          },
        ),
      ),
    ));
    await pumpCard(tester);

    await tester.tap(find.byIcon(Icons.share_outlined));
    await pumpCard(tester);

    expect(sharedBytes, [1, 2, 3, 4]);
    expect(sharedFilename, 'test_cert.pdf');
  });

  testWidgets(
      'Native share shows localized error feedback when PDF file is missing',
      (tester) async {
    await insertJob(tester, id: 5, pdfPathOverride: '/non/existent/path.pdf');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(visitId: 42, outboxRepository: outbox),
      ),
    ));
    await pumpCard(tester);

    await tester.tap(find.byIcon(Icons.share_outlined));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.sharePdfError), findsOneWidget);
  });
}
