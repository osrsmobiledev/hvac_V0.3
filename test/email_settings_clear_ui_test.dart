import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_notifier.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'email_settings_test_helpers.dart';

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

  group('EmailSettingsCard clear UI & confirmation widget tests', () {
    testWidgets('canceling clear dialog retains existing settings and switch',
        (tester) async {
      final fakeRepo = FakeClearRepository(db: db, secureStore: secureStore);
      final notifier = EmailSettingsNotifier(
        repository: fakeRepo,
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

      final autoSendFinder = find.widgetWithText(
        SwitchListTile,
        EmailDeliveryDictionary.autoSendLabel,
      );
      expect(tester.widget<SwitchListTile>(autoSendFinder).value, isTrue);

      expect(find.text(EmailDeliveryDictionary.clearSettingsButton),
          findsOneWidget);
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsButton));
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.clearSettingsDialogTitle),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.clearSettingsDialogMessage),
          findsOneWidget);

      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsCancel));
      await tester.pumpAndSettle();

      expect(fakeRepo.clearCalled, isFalse);
      expect(notifier.settings.username, 'clearme@gmail.com');
      expect(notifier.settings.autoSend, isTrue);
      expect(tester.widget<SwitchListTile>(autoSendFinder).value, isTrue);

      notifier.dispose();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'confirming clear dialog resets settings, turns switch off, shows feedback',
        (tester) async {
      final fakeRepo = FakeClearRepository(db: db, secureStore: secureStore);
      final notifier = EmailSettingsNotifier(
        repository: fakeRepo,
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

      final autoSendFinder = find.widgetWithText(
        SwitchListTile,
        EmailDeliveryDictionary.autoSendLabel,
      );
      expect(tester.widget<SwitchListTile>(autoSendFinder).value, isTrue);

      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsConfirm));
      await tester.pumpAndSettle();

      expect(fakeRepo.clearCalled, isTrue);
      expect(find.text(EmailDeliveryDictionary.clearSettingsSuccess),
          findsOneWidget);
      expect(notifier.settings.smtpState, 'unconfigured');
      expect(notifier.usernameController.text, '');
      expect(notifier.settings.autoSend, isFalse);
      expect(tester.widget<SwitchListTile>(autoSendFinder).value, isFalse);

      notifier.dispose();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'failed clear with failing credential store displays error, clears stale inputs and disables auto-send',
        (tester) async {
      final failStore = FailingDeleteStore(initialPassword: 'secret-pass');
      final repo = FailingClearRepository(db: db, failingStore: failStore);
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

      expect(find.text('stale.user@gmail.com'), findsOneWidget);
      final autoSendFinder = find.widgetWithText(
        SwitchListTile,
        EmailDeliveryDictionary.autoSendLabel,
      );
      expect(tester.widget<SwitchListTile>(autoSendFinder).value, isTrue);

      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsConfirm));
      await tester.pumpAndSettle();

      // 1. User sees failure
      expect(
          find.text(EmailDeliveryDictionary.clearSettingsError), findsWidgets);
      // 2. UI does not display stale configured settings
      expect(find.text('stale.user@gmail.com'), findsNothing);
      expect(notifier.usernameController.text, '');
      // 3. UI does not display an enabled auto-send control
      final autoSendAfter = tester.widget<SwitchListTile>(autoSendFinder);
      expect(autoSendAfter.value, isFalse);
      expect(autoSendAfter.onChanged, isNull);
      // 4. Safe retry button exists
      expect(find.text(EmailDeliveryDictionary.btnRetryInit), findsOneWidget);
      // 5. Preserved recovery state
      expect(notifier.settings.smtpState, 'clearing');

      notifier.dispose();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('delayed clear blocks other actions until complete',
        (tester) async {
      final repo = DelayedClearRepository(db: db, secureStore: secureStore);
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

      // Start clear (initial pending state)
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(EmailDeliveryDictionary.clearSettingsConfirm));
      await tester.pump(); // async clear started, not finished

      // Verify clear is in progress and retry banner is not shown
      expect(notifier.isClearing, isTrue);
      expect(find.text(EmailDeliveryDictionary.btnRetryInit), findsNothing);

      // Test and Save buttons should be disabled
      final testBtn = tester.widget<OutlinedButton>(find.widgetWithText(
          OutlinedButton, EmailDeliveryDictionary.testConnectionButton));
      expect(testBtn.onPressed, isNull);
      final saveBtn = tester.widget<FilledButton>(find.widgetWithText(
          FilledButton, EmailDeliveryDictionary.saveSettingsButton));
      expect(saveBtn.onPressed, isNull);

      // Complete the clear operation
      repo.completer.complete();
      await tester.pumpAndSettle();

      expect(notifier.isClearing, isFalse);
      expect(notifier.settings.smtpState, 'unconfigured');
      expect(notifier.settings.autoSend, isFalse);
      expect(find.text(EmailDeliveryDictionary.clearSettingsSuccess),
          findsOneWidget);
    });
  });
}
