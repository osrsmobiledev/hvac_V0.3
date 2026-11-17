import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
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

  Future<void> pumpAsync(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
    }
  }

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    await pumpAsync(tester);
  }

  group('KlantTab Cancel & Duplicate Integrity Tests', () {
    testWidgets(
        'Empty draft: enter new customer, autosave, cancel leaves zero data behind',
        (tester) async {
      await pumpTab(tester);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'De Smet');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_street')), 'Kerkstraat');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_houseNumber')), '12');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 550));
      late List<Customer> savedBefore;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        savedBefore = await customerRepository.searchCustomers('De Smet');
      });
      await tester.pump();
      expect(savedBefore.length, 1);

      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      late List<Customer> savedAfter;
      late int? draftCustId;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        savedAfter = await customerRepository.searchCustomers('De Smet');
        final draft = await draftRepository.getOrCreateActiveDraft();
        draftCustId = draft.customerId;
      });
      await tester.pump();

      expect(savedAfter.isEmpty, isTrue);
      expect(draftCustId, isNull);
    });

    testWidgets(
        'Existing Customer A: tap Nieuw, enter Customer B, autosave, cancel restores Customer A and deletes Customer B',
        (tester) async {
      final now = DateTime.now();
      late Customer custA;
      await tester.runAsync(() async {
        custA = await customerRepository.saveCustomer(Customer(
          firstName: 'Karel',
          lastName: 'Aerts',
          street: 'Kouter',
          houseNumber: '5',
          postalCode: '9000',
          city: 'Gent',
          createdAt: now,
          updatedAt: now,
        ));
        final draft = await draftRepository.getOrCreateActiveDraft();
        await draftRepository.updateVisitCustomer(
          visitId: draft.id,
          customerId: custA.id,
        );
      });

      await pumpTab(tester);
      expect(find.text('Aerts'), findsOneWidget);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'Bogaert');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 550));
      late List<Customer> bBefore;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        bBefore = await customerRepository.searchCustomers('Bogaert');
      });
      await tester.pump();
      expect(bBefore.length, 1);

      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      late List<Customer> bAfter;
      late int? draftCustId;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        bAfter = await customerRepository.searchCustomers('Bogaert');
        final draft = await draftRepository.getOrCreateActiveDraft();
        draftCustId = draft.customerId;
      });
      await tester.pump();

      expect(find.text('Aerts'), findsOneWidget);
      expect(bAfter.isEmpty, isTrue);
      expect(draftCustId, custA.id);
    });

    testWidgets(
        'Enter customer name, autosave, apply lookup does not create duplicate customer records',
        (tester) async {
      await pumpTab(tester);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'Janssens');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 550));
      late List<Customer> c1;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        c1 = await customerRepository.searchCustomers('Janssens');
      });
      await tester.pump();
      expect(c1.length, 1);
      final custId = c1.first.id!;

      await tester.enterText(
          find.byKey(const ValueKey('customer_street')), 'Veldstraat');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_houseNumber')), '42');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 550));
      await pumpAsync(tester);
      late List<Customer> allCusts;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        allCusts = await customerRepository.searchCustomers('Janssens');
      });
      await tester.pump();

      expect(allCusts.length, 1);
      expect(allCusts.first.id, custId);
      expect(allCusts.first.street, 'Veldstraat');
      expect(allCusts.first.houseNumber, '42');
    });
  });
}
