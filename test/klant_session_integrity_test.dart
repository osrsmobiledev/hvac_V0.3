import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/services/basisregisters_service.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/address_lookup_dialog.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/address_search_icon.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant_tab.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _lookup = AddressMatch(
  adresId: '101',
  volledigAdres: 'Kerkstraat 10, 2000 Antwerpen',
  straatNaam: 'Kerkstraat',
  huisNummer: '10',
  postcode: '2000',
  gemeenteNaam: 'Antwerpen',
  gebouwId: '501',
  gebouweenheidId: '401',
  isEnriched: true,
);
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final appDb = AppDatabase.instance;
  final warmup = AppWarmupService.instance;
  final customers = CustomerRepository();
  final drafts = DraftRepository();
  late Directory directory;
  late String databasePath;
  late Customer originalCustomer;
  late ServiceLocation originalLocation;
  Future<void> openDatabase() async {
    appDb.setDatabaseForTesting(
      await appDb.initDatabase(customPath: databasePath),
    );
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hvac_klant_session_');
    databasePath = '${directory.path}/draft.sqlite';
    await openDatabase();
    final draft = await drafts.getOrCreateActiveDraft();
    final now = DateTime.now();
    final original = await customers.saveCustomerWithLocation(
      visitId: draft.id,
      customer: Customer(
        lastName: 'Aerts',
        street: 'Kouter',
        houseNumber: '5',
        postalCode: '9000',
        city: 'Gent',
        createdAt: now,
        updatedAt: now,
      ),
      location: ServiceLocation(
        customerId: 0,
        street: 'Kouter',
        houseNumber: '5',
        postalCode: '9000',
        municipality: 'Gent',
        adresId: '901',
        gebouwId: '902',
        gebouweenheidId: '903',
        verificationStatus: 'verified',
        createdAt: now,
        updatedAt: now,
      ),
    );
    originalCustomer = original.customer;
    originalLocation = original.location;
    BasisregistersService.mockZoekAdres = (
            {required straat,
            required huisNummer,
            gemeente,
            postcode,
            bus}) async =>
        const BasisregistersResult.success([_lookup]);
  });
  tearDown(() async {
    BasisregistersService.mockZoekAdres = null;
    warmup.resetForTesting();
    await appDb.deleteDatabaseFile(customPath: databasePath);
    await directory.delete();
  });

  /// SQLite FFI needs real async time even when the widget clock is simulated.
  Future<void> waitFor(
    WidgetTester tester,
    Future<bool> Function() condition,
  ) async {
    for (var attempt = 0; attempt < 50; attempt++) {
      if (await condition()) return;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 40));
    }
    fail('Timed out waiting for the Klant tab or its SQLite write.');
  }

  Future<void> pumpTab(WidgetTester tester, {bool useWarmup = false}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: useWarmup
            ? const KlantTab()
            : KlantTab(customerRepository: customers, draftRepository: drafts),
      ),
    ));
    final lastName = find.byKey(const ValueKey('customer_lastName'));
    await waitFor(tester, () async => lastName.evaluate().isNotEmpty);
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> startNewCustomer(WidgetTester tester) async {
    await tester.runAsync(() async {
      final loader = FontLoader(AppTheme.fontFamily)
        ..addFont(rootBundle.load('assets/fonts/libron-regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/libron-bold.ttf'));
      await loader.load();
    });
    tester.view.physicalSize = const Size(412, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpTab(tester);
    await tap(tester, AppDictionary.btnNew);
    await tap(tester, AppDictionary.dlgYes);
    final beforeTyping = await tester.runAsync(drafts.getOrCreateActiveDraft);
    expect(beforeTyping?.customerId, originalCustomer.id);
    expect(beforeTyping?.serviceLocationId, originalLocation.id);
    await tester.enterText(
      find.byKey(const ValueKey('customer_lastName')),
      'Bogaert',
    );
    await tester.enterText(
        find.byKey(const ValueKey('customer_firstName')), 'Jan');
    final searchIcon = find.byType(AddressSearchIcon).first;
    await tester.ensureVisible(searchIcon);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AddressLookupDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Kerkstraat');
    await tester.enterText(fields.at(1), '10');
    await tester.enterText(fields.at(2), '2000');
    await tap(tester, BasisregistersDictionary.lookupBtnSearch);
    await tap(tester, BasisregistersDictionary.lookupBtnConfirm);
    await tester.pump(const Duration(milliseconds: 550));
    await waitFor(tester, () async {
      return (await tester.runAsync(() async {
        final draft = await drafts.getOrCreateActiveDraft();
        if (draft.customerId == null || draft.klantUndoJson == null) {
          return false;
        }
        final locations =
            await customers.getLocationsForCustomer(draft.customerId!);
        return locations.any((location) => location.adresId == '101');
      }))!;
    });
    await tester.runAsync(() async {
      final storedOriginal =
          await customers.getCustomerById(originalCustomer.id!);
      final storedLocations =
          await customers.getLocationsForCustomer(originalCustomer.id!);
      final matches = await customers.searchCustomers('Bogaert');
      expect(storedOriginal?.lastName, 'Aerts');
      expect(storedLocations.single.adresId, '901');
      expect(matches, hasLength(1));
      final draft = await drafts.getOrCreateActiveDraft();
      expect(draft.customerId, matches.single.id);
      expect(draft.serviceLocationId, isNot(originalLocation.id));
    });
  }

  testWidgets('Opslaan commits the new customer and clears undo',
      (tester) async {
    await startNewCustomer(tester);
    await tap(tester, AppDictionary.btnSave);
    await waitFor(tester,
        () async => find.text(AppDictionary.btnEdit).evaluate().isNotEmpty);
    await tester.runAsync(() async {
      final draft = await drafts.getOrCreateActiveDraft();
      final newCustomer = (await customers.searchCustomers('Bogaert')).single;
      expect(draft.customerId, newCustomer.id);
      expect(draft.klantUndoJson, isNull);
      expect((await customers.getCustomerById(originalCustomer.id!))?.lastName,
          'Aerts');
    });
  });
  for (final useWarmup in [false, true]) {
    testWidgets(
      'Annuleren restores the original customer after reopening '
      '(${useWarmup ? 'after app warmup' : 'direct load'})',
      (tester) async {
        await startNewCustomer(tester);
        await tester.pumpWidget(const SizedBox.shrink());
        int? boilerId;
        await tester.runAsync(() async {
          await appDb.close();
          await openDatabase();
          if (useWarmup) boilerId = (await warmup.warmup()).activeBoiler!.id;
        });
        await pumpTab(tester, useWarmup: useWarmup);
        expect(find.text('Bogaert'), findsOneWidget);
        expect(find.text(AppDictionary.btnSave), findsOneWidget);
        await tap(tester, AppDictionary.btnCancel);
        await tap(tester, AppDictionary.dlgYes);
        await waitFor(
            tester, () async => find.text('Aerts').evaluate().isNotEmpty);
        await tester.runAsync(() async {
          final draft = await drafts.getOrCreateActiveDraft();
          expect(draft.customerId, originalCustomer.id);
          expect(draft.serviceLocationId, originalLocation.id);
          expect(draft.klantUndoJson, isNull);
          expect(await customers.searchCustomers('Bogaert'), isEmpty);
          final original =
              await customers.getLocationsForCustomer(originalCustomer.id!);
          expect(original.single.adresId, '901');
          if (useWarmup) {
            final db = await appDb.database;
            expect((await db.query('maintenance_visits')).single['boiler_id'],
                boilerId);
            final boiler = (await db.query('boilers')).single;
            expect(boiler['service_location_id'], originalLocation.id);
          }
        });
      },
    );
  }
}
