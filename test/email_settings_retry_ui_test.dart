import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_notifier.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'email_settings_test_helpers.dart';

/// Widget tests for the retry-in-progress guard.
///
/// Uses [FailThenDelayRepository]: one repo that fails its first clear call,
/// then holds its second call behind a [Completer]. This lets us verify that
/// Test and Save cannot start while a retry is running, without adding any
/// production-only API to the notifier or repository.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late MemorySecureCredentialStore secureStore;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    secureStore = MemorySecureCredentialStore();
  });

  tearDown(() async => db.close());

  group('EmailSettingsCard retry-in-progress guard', () {
    testWidgets('retry-in-progress blocks test and save until retry completes',
        (tester) async {
      final repo = FailThenDelayRepository(db: db, secureStore: secureStore);
      final notifier = EmailSettingsNotifier(
        repository: repo,
        senderService: EmailSenderService(checker: (_, {timeout}) async {}),
      );
      await notifier.init();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmailSettingsCard(notifier: notifier),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // ── Step 1: trigger the first clear, which fails ──────────────────────
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsConfirm));
      await tester.pumpAndSettle();

      // Error banner and Retry button must be visible after the first failure.
      expect(
          find.text(EmailDeliveryDictionary.clearSettingsError), findsWidgets);
      expect(find.text(EmailDeliveryDictionary.btnRetryInit), findsOneWidget);
      expect(notifier.settings.smtpState, 'clearing');

      // ── Step 2: tap Retry; second clear is held by the completer ──────────
      await tester.tap(find.text(EmailDeliveryDictionary.btnRetryInit));
      await tester.pump(); // start the async work but do NOT pumpAndSettle

      // The notifier must report isClearing while the completer is pending.
      expect(notifier.isClearing, isTrue);

      // Retry, Test, and Save buttons must be disabled during the retry.
      final retryBtn = tester.widget<TextButton>(find.widgetWithText(
          TextButton, EmailDeliveryDictionary.btnRetryInit));
      expect(retryBtn.onPressed, isNull,
          reason: 'Retry must be disabled while retry is running');
      final testBtn = tester.widget<OutlinedButton>(find.widgetWithText(
          OutlinedButton, EmailDeliveryDictionary.testConnectionButton));
      expect(testBtn.onPressed, isNull,
          reason: 'Test must be disabled while retry is running');
      final saveBtn = tester.widget<FilledButton>(find.widgetWithText(
          FilledButton, EmailDeliveryDictionary.saveSettingsButton));
      expect(saveBtn.onPressed, isNull,
          reason: 'Save must be disabled while retry is running');

      // ── Step 3: resolve the completer and verify success ──────────────────
      repo.completer.complete();
      await tester.pumpAndSettle();

      expect(notifier.isClearing, isFalse);
      expect(notifier.settings.smtpState, 'unconfigured');
      expect(notifier.settings.autoSend, isFalse);
      expect(find.text(EmailDeliveryDictionary.clearSettingsSuccess),
          findsOneWidget);

      notifier.dispose();
      await tester.pumpWidget(const SizedBox());
    });
  });
}
