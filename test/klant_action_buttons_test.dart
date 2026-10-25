import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_action_buttons.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant_tab.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late CustomerRepository customerRepository;
  late DraftRepository draftRepository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    customerRepository = CustomerRepository();
    draftRepository = DraftRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: KlantTab(
          customerRepository: customerRepository,
          draftRepository: draftRepository,
        ),
      ),
    );
  }

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    for (int i = 0; i < 20; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
  }

  group('KlantActionButtons & Warping State Machine', () {
    testWidgets('Renders 4 action buttons in default view state',
        (tester) async {
      await pumpTab(tester);

      expect(find.byType(KlantActionButtons), findsOneWidget);
      expect(find.text(AppDictionary.btnSearch), findsOneWidget);
      expect(find.text(AppDictionary.btnNew), findsOneWidget);
      expect(find.text(AppDictionary.btnEdit), findsOneWidget);
      expect(find.text(AppDictionary.btnDelete), findsOneWidget);
    });

    testWidgets(
        'Tapping Nieuw triggers confirmation and warps buttons to Opslaan/Annuleren',
        (tester) async {
      await pumpTab(tester);

      // Tap 'Nieuw'
      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppDictionary.dlgNewCustomerTitle),
        ),
        findsOneWidget,
      );
      expect(find.text(AppDictionary.dlgNewCustomerContent), findsOneWidget);

      // Confirm 'Ja'
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      // Verify buttons warped
      expect(find.text(AppDictionary.btnSave), findsOneWidget);
      expect(find.text(AppDictionary.btnCancel), findsOneWidget);
      expect(find.text(AppDictionary.btnEdit), findsNothing);
      expect(find.text(AppDictionary.btnDelete), findsNothing);
    });

    testWidgets(
        'Tapping Annuleren prompts Herstellen and warps back to Bewerken/Wissen',
        (tester) async {
      await pumpTab(tester);

      // Enter new mode
      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      // Now tap 'Annuleren'
      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();

      // Verify Herstellen dialog
      expect(find.text(AppDictionary.dlgCancelEditTitle), findsOneWidget);
      expect(find.text(AppDictionary.dlgCancelEditContent), findsOneWidget);

      // Confirm 'Ja'
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      // Verify buttons warped back
      expect(find.text(AppDictionary.btnEdit), findsOneWidget);
      expect(find.text(AppDictionary.btnDelete), findsOneWidget);
      expect(find.text(AppDictionary.btnSave), findsNothing);
      expect(find.text(AppDictionary.btnCancel), findsNothing);
    });

    testWidgets(
        'With existing customer, Bewerken and Wissen prompt respective dialogs',
        (tester) async {
      await tester.runAsync(() async {
        final now = DateTime.now();
        final cust = await customerRepository.saveCustomer(
          Customer(
            firstName: 'Jan',
            lastName: 'Peeters',
            street: 'Dorpstraat',
            houseNumber: '1',
            postalCode: '9000',
            city: 'Gent',
            createdAt: now,
            updatedAt: now,
          ),
        );
        final draft = await draftRepository.getOrCreateActiveDraft();
        await draftRepository.updateVisitCustomer(
          visitId: draft.id,
          customerId: cust.id,
        );
      });

      await pumpTab(tester);

      // Tap 'Bewerken'
      await tester.tap(find.text(AppDictionary.btnEdit));
      await tester.pumpAndSettle();

      // Verify Bewerken dialog
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppDictionary.dlgEditCustomerTitle),
        ),
        findsOneWidget,
      );
      expect(find.text(AppDictionary.dlgEditCustomerContent), findsOneWidget);
      await tester.tap(find.text(AppDictionary.dlgNo));
      await tester.pumpAndSettle();

      // Tap 'Wissen'
      await tester.tap(find.text(AppDictionary.btnDelete));
      await tester.pumpAndSettle();

      // Verify Klant Wissen dialog
      expect(find.text(AppDictionary.dlgDeleteCustomerTitle), findsOneWidget);
      expect(find.text(AppDictionary.dlgDeleteCustomerContent), findsOneWidget);
      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
    });
  });
}
