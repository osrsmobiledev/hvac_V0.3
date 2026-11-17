import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant_tab.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PausableCustomerRepo extends CustomerRepository {
  Completer<void>? pauseCompleter;
  bool shouldFail = false;

  @override
  Future<({Customer customer, ServiceLocation location})>
      saveCustomerWithLocation({
    required Customer customer,
    required ServiceLocation location,
    required int visitId,
    String? Function(int customerId, int locationId)? buildUndoJson,
  }) async {
    if (pauseCompleter != null && !pauseCompleter!.isCompleted) {
      await pauseCompleter!.future;
    }
    if (shouldFail) {
      throw Exception('Controlled SQLite disk error');
    }
    return super.saveCustomerWithLocation(
      customer: customer,
      location: location,
      visitId: visitId,
      buildUndoJson: buildUndoJson,
    );
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PausableCustomerRepo customerRepository;
  late DraftRepository draftRepository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    customerRepository = PausableCustomerRepo();
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
    for (int i = 0; i < 15; i++) {
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

  group('KlantTab Asynchronous Queue & Timing Integrity Tests', () {
    testWidgets('Overlapping writes: paused write deduplicates properly',
        (tester) async {
      await pumpTab(tester);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      customerRepository.pauseCompleter = Completer<void>();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'Vermeulen');
      await tester.pump(const Duration(milliseconds: 550));

      await tester.enterText(
          find.byKey(const ValueKey('customer_street')), 'Molenstraat');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_houseNumber')), '18');
      await tester.pump(const Duration(milliseconds: 550));

      customerRepository.pauseCompleter!.complete();
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      late List<Customer> results;
      await tester.runAsync(() async {
        results = await customerRepository.searchCustomers('Vermeulen');
      });
      expect(results.length, 1);
      expect(results.first.street, 'Molenstraat');
      expect(results.first.houseNumber, '18');
    });

    testWidgets('Cancel during in-flight write rolls back and leaves 0 records',
        (tester) async {
      await pumpTab(tester);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      customerRepository.pauseCompleter = Completer<void>();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'TempGhost');
      await tester.pump(const Duration(milliseconds: 550));

      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pump();

      customerRepository.pauseCompleter!.complete();
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      late List<Customer> results;
      late int? draftCustId;
      await tester.runAsync(() async {
        results = await customerRepository.searchCustomers('TempGhost');
        final draft = await draftRepository.getOrCreateActiveDraft();
        draftCustId = draft.customerId;
      });

      expect(results.isEmpty, isTrue);
      expect(draftCustId, isNull);
    });

    testWidgets('Cancel during in-flight write restores A and purges B',
        (tester) async {
      final now = DateTime.now();
      late Customer custA;
      await tester.runAsync(() async {
        custA = await customerRepository.saveCustomer(Customer(
          firstName: 'Jan',
          lastName: 'Original',
          street: 'Markt',
          houseNumber: '1',
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
      expect(find.text('Original'), findsOneWidget);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      customerRepository.pauseCompleter = Completer<void>();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'NewGhost');
      await tester.pump(const Duration(milliseconds: 550));

      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pump();

      customerRepository.pauseCompleter!.complete();
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      late List<Customer> bResults;
      late int? draftCustId;
      await tester.runAsync(() async {
        bResults = await customerRepository.searchCustomers('NewGhost');
        final draft = await draftRepository.getOrCreateActiveDraft();
        draftCustId = draft.customerId;
      });

      expect(bResults.isEmpty, isTrue);
      expect(draftCustId, custA.id);
      expect(find.text('Original'), findsOneWidget);
    });

    testWidgets('Failed write never displays saved confirmation',
        (tester) async {
      await pumpTab(tester);

      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'WillFail');
      await tester.pump(const Duration(milliseconds: 550));

      customerRepository.shouldFail = true;

      await tester.tap(find.text(AppDictionary.btnSave));
      await pumpAsync(tester);
      await tester.pumpAndSettle();

      expect(find.text(AppDictionary.toastCustomerSaved), findsNothing);
      expect(find.text(AppDictionary.btnSave), findsOneWidget);
    });
  });
}
