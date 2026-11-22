import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:hvac_app/features/visit_history/data/visit_history_repository.dart';
import 'package:hvac_app/features/visit_history/ui/visit_history_screen.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late File dummyPdf;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hist_int_test_');
    dummyPdf = File(p.join(tempDir.path, 'int_cert.pdf'))
      ..writeAsBytesSync([1, 2, 3]);

    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    await AppWarmupService.instance.warmup();

    EmailDeliveryCoordinator.instanceForTesting = EmailDeliveryCoordinator(
      database: () async => db,
      credentialStore: MemorySecureCredentialStore(),
    );

    const stamp = {
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
    };
    await db.insert('customers', {
      ...stamp,
      'first_name': 'Karel',
      'last_name': 'Vermeulen',
    });
    await db.insert('service_locations', {
      ...stamp,
      'customer_id': 1,
      'street': 'Kerkstraat',
      'house_number': '15',
      'postal_code': '9000',
      'municipality': 'Gent',
    });
    await db.insert('boilers', {
      ...stamp,
      'boiler_brand': 'Vaillant',
      'boiler_model': 'ecoTEC',
      'boiler_serial_number': 'SN123',
    });
    final visitId = await db.insert('maintenance_visits', {
      ...stamp,
      'id': 55,
      'visit_date': '2026-02-10',
      'next_inspection_date': '2027-02-10',
      'customer_id': 1,
      'service_location_id': 1,
      'boiler_id': 1,
      'is_draft': 1,
    });
    final repo = VisitHistoryRepository(database: () async => db);
    await repo.finalize(visitId);
    await db.update(
        'maintenance_visits',
        {
          'pdf_status': 'ready',
          'pdf_path': dummyPdf.path,
        },
        where: 'id = ?',
        whereArgs: [visitId]);

    // Insert outbox job
    final outbox = EmailOutboxRepository(database: () async => db);
    await outbox.createJobs([
      EmailJobSpec(
        visitId: 55,
        recipientType: RecipientType.customer,
        recipientName: 'Karel Vermeulen',
        recipientEmail: 'karel@example.com',
        subject: 'Verbrandingsattest 2026-001',
        bodyText: 'Attest in bijlage',
        pdfPath: dummyPdf.path,
      ),
    ]);
  });

  tearDown(() async {
    EmailDeliveryCoordinator.instanceForTesting = null;
    await AppDatabase.instance.close();
    try {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  testWidgets(
      'VisitHistoryScreen displays email action and opens EmailDeliveryCard dialog',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: VisitHistoryScreen(),
        ),
      ),
    );
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    // 1. Verify visit tile is shown with email action button
    final emailButton = find.byKey(const ValueKey('visit_email_55'));
    expect(emailButton, findsOneWidget);

    // 2. Tap email button to open dialog
    await tester.tap(emailButton);
    for (int i = 0; i < 8; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 30));
    }

    // 3. Verify EmailDeliveryCard rendered inside dialog with queued job
    expect(find.byType(EmailDeliveryCard), findsOneWidget);
    expect(
        find.text(EmailDeliveryDictionary.trackerDialogTitle), findsOneWidget);
    expect(find.textContaining('karel@example.com'), findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.badgeQueued), findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.actionSendNow), findsOneWidget);
  });
}
