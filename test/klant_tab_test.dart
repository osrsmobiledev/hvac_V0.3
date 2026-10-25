import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant_tab.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
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

  group('Slice 2.4 — Tab 4 (Klant & Installatieadres) UI & Persistence', () {
    testWidgets(
        'Renders Klant and Locatie Toestel sections with locked inputs in view mode',
        (tester) async {
      await pumpTab(tester);

      // Verify Main Section Titles
      expect(find.text(AppDictionary.headerCustomerDetails), findsOneWidget);
      expect(find.text(AppDictionary.headerApplianceLocation), findsOneWidget);

      // Verify Top Action buttons
      expect(find.text(AppDictionary.btnSearch), findsOneWidget);
      expect(find.text(AppDictionary.btnNew), findsOneWidget);

      // Verify Field Labels
      expect(find.text(AppDictionary.lblCompanyOrCustomerOptional),
          findsOneWidget);
      expect(find.text(AppDictionary.lblFirstName), findsOneWidget);
      expect(find.text(AppDictionary.lblLastName), findsOneWidget);
      expect(find.text(AppDictionary.lblStreet), findsOneWidget);
      expect(find.text(AppDictionary.lblHouseNumber), findsOneWidget);
      expect(find.text(AppDictionary.lblBox), findsOneWidget);
      expect(find.text(AppDictionary.lblPostalCode), findsOneWidget);
      expect(find.text(AppDictionary.lblCity), findsOneWidget);
      expect(find.text(AppDictionary.lblPhone), findsOneWidget);
      expect(find.text(AppDictionary.lblEmail), findsOneWidget);

      // Verify Same Address Switch starts disabled (greyed out) with inputs locked
      expect(find.text(AppDictionary.lblSameAsCustomerAddress), findsOneWidget);
      final initialSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(initialSwitch.onChanged, isNull);
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('customer_lastName')),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.readOnly, isTrue);
    });

    testWidgets(
        'Tapping Nieuw unlocks fields and persists entered data to SQLite',
        (tester) async {
      await pumpTab(tester);

      // Tap 'Nieuw' and confirm to unlock edit mode
      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      // Enter customer details
      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'Vermeulen');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_firstName')), 'Luc');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_street')), 'Stationsstraat');
      await tester.pump();
      await tester.enterText(
          find.byKey(const ValueKey('customer_houseNumber')), '108');
      await tester.pump();

      // Trigger debounce and SQLite save
      await tester.pump(const Duration(milliseconds: 550));
      late List<Customer> customers;
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        customers = await customerRepository.searchCustomers('Vermeulen');
        draft = await draftRepository.getOrCreateActiveDraft();
      });
      await tester.pump();

      // Verify stored in SQLite customers table
      expect(customers.length, 1);
      expect(customers.first.lastName, 'Vermeulen');
      expect(customers.first.firstName, 'Luc');
      expect(customers.first.street, 'Stationsstraat');
      expect(customers.first.houseNumber, '108');
      expect(draft.customerId, customers.first.id);
      expect(draft.serviceLocationId, isNotNull);
    });

    testWidgets(
        'Toggling separate installation address expands distinct fields and persists',
        (tester) async {
      await pumpTab(tester);

      // Tap 'Nieuw' and confirm
      await tester.tap(find.text(AppDictionary.btnNew));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.dlgYes));
      await tester.pumpAndSettle();

      // Enter customer name
      await tester.enterText(
          find.byKey(const ValueKey('customer_lastName')), 'Claes');
      await tester.pump();

      // Toggle separate address Switch to false
      final toggleSwitch = find.byType(Switch);
      expect(toggleSwitch, findsOneWidget);
      await tester.tap(toggleSwitch);
      await tester.pumpAndSettle();

      // Verify separate installation fields appear
      expect(find.text(AppDictionary.lblStreetInstallation), findsOneWidget);

      // Enter separate installation address
      await tester.enterText(
          find.byKey(const ValueKey('loc_street')), 'Fabriekslaan');
      await tester.pump();

      // Trigger debounce and run async SQLite operations
      await tester.pump(const Duration(milliseconds: 550));
      late Customer customer;
      ServiceLocation? location;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        customer = (await customerRepository.searchCustomers('Claes')).first;
        location = await customerRepository
            .getPrimaryLocationForCustomer(customer.id!);
      });
      await tester.pump();

      // Verify location saved with street 'Fabriekslaan'
      expect(location, isNotNull);
      expect(location!.street, 'Fabriekslaan');
    });

    testWidgets('Customer search modal filters customers and selects into form',
        (tester) async {
      // Seed SQLite with test customers via runAsync
      final now = DateTime.now();
      await tester.runAsync(() async {
        await customerRepository.saveCustomer(Customer(
          lastName: 'Aitest BV',
          companyName: 'Aitest BV',
          street: 'Industrieweg',
          houseNumber: '5',
          postalCode: '9000',
          city: 'Gent',
          phone: '+32 9 123 45 67',
          createdAt: now,
          updatedAt: now,
        ));
        await customerRepository.saveCustomer(Customer(
          lastName: 'Bakker',
          firstName: 'Tom',
          street: 'Dorpstraat',
          houseNumber: '1',
          postalCode: '8000',
          city: 'Brugge',
          createdAt: now,
          updatedAt: now,
        ));
      });

      await pumpTab(tester);

      // Tap 'Zoeken' button
      final chooseBtn = find.text(AppDictionary.btnSearch);
      expect(chooseBtn, findsOneWidget);
      await tester.tap(chooseBtn);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Modal bottom sheet should be open
      expect(find.text('Kies bestaande klant'), findsWidgets);

      // Both customers should be visible
      expect(find.text('Aitest BV'), findsOneWidget);
      expect(find.text('Tom Bakker'), findsOneWidget);

      // Tap on 'Aitest BV'
      await tester.tap(find.text('Aitest BV'));
      await tester.pumpAndSettle();
      for (int i = 0; i < 5; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();
      }

      // Modal dismissed and form populated
      expect(find.text('Aitest BV'), findsWidgets);
      expect(find.text('Industrieweg'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      final cityField = tester
          .widget<TextFormField>(find.byKey(const ValueKey('customer_city')));
      expect(cityField.controller?.text, equals('Gent'));
      expect(find.text('9 123 45 67'), findsOneWidget);

      // Verify draft visit linked to this customer
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await draftRepository.getOrCreateActiveDraft();
      });
      expect(draft.customerId, isNotNull);
    });
  });
}
