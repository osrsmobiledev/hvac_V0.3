import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/customer_result_tile.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/customer_search_modal.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late CustomerRepository repository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    repository = CustomerRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Future<void> pumpAsync(WidgetTester tester) async {
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

  testWidgets(
      'CustomerSearchModal selects and deletes customers via tactical dialogs',
      (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    await tester.runAsync(() async {
      await repository.saveCustomer(Customer(
        lastName: 'Willems',
        firstName: 'Sophie',
        street: 'Kerkstraat',
        houseNumber: '12',
        postalCode: '9000',
        city: 'Gent',
        createdAt: now,
        updatedAt: now,
      ));
      await repository.saveCustomer(Customer(
        lastName: 'De Smet',
        firstName: 'Koen',
        street: 'Veldstraat',
        houseNumber: '4',
        postalCode: '8000',
        city: 'Brugge',
        createdAt: now,
        updatedAt: now,
      ));
    });

    Customer? selectedCustomer;
    int? deletedId;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedCustomer = await CustomerSearchModal.show(
                  context,
                  repository: repository,
                  onCustomerDeleted: (id) => deletedId = id,
                );
              },
              child: const Text('Open Search'),
            ),
          ),
        ),
      ),
    );

    // Open search modal
    await tester.tap(find.text('Open Search'));
    await tester.pump();
    await pumpAsync(tester);
    await tester.pump(const Duration(milliseconds: 350));

    // Verify CustomerSearchHeader and customers rendered
    expect(find.text(AppDictionary.dlgSearchCustomerTitle), findsOneWidget);
    expect(find.text('Sophie Willems'), findsOneWidget);
    expect(find.text('Koen De Smet'), findsOneWidget);

    // Tap delete icon on 'Koen De Smet'
    final koenTile = find.ancestor(
      of: find.text('Koen De Smet'),
      matching: find.byType(CustomerResultTile),
    );
    final deleteBtn = find.descendant(
      of: koenTile,
      matching: find.byIcon(Icons.delete_outline_rounded),
    );
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text(AppDictionary.dlgDeleteFromDbTitle), findsOneWidget);
    expect(find.text(AppDictionary.dlgDeleteFromDbConfirm), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text(AppDictionary.dlgDeleteFromDbConfirm));
    await tester.pumpAndSettle();
    await pumpAsync(tester);
    await tester.pumpAndSettle();

    // Verify customer deleted from list and DB
    expect(deletedId, isNotNull);
    expect(find.text('Koen De Smet'), findsNothing);
    late List<Customer> remaining;
    await tester.runAsync(() async {
      remaining = await repository.getAllCustomers();
    });
    expect(remaining.length, 1);
    expect(remaining.first.lastName, 'Willems');

    // Select remaining customer
    await tester.tap(find.text('Sophie Willems'));
    await tester.pumpAndSettle();

    // Dialog closed and customer returned
    expect(find.text(AppDictionary.dlgSearchCustomerTitle), findsNothing);
    expect(selectedCustomer?.lastName, 'Willems');
  });

  testWidgets(
      'TacticalSearchBar renders pill shape and morphs magnifying glass to back arrow when searching',
      (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CustomerSearchModal.show(
                context,
                repository: repository,
              ),
              child: const Text('Open Search'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Search'));
    await tester.pump();
    await pumpAsync(tester);
    await tester.pump(const Duration(milliseconds: 350));

    // Initially shows magnifying glass and 'Zoek klanten' hint
    expect(find.byKey(const ValueKey('search_glass_icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_back_button')), findsNothing);
    expect(find.text('Zoek klanten'), findsOneWidget);

    // Tap into SearchBar
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();

    // Leading icon morphs to '<' and trailing gets 'x' before typing
    expect(find.byKey(const ValueKey('search_back_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_clear_button')), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(SearchBar), 'Willems');
    await tester.pump();
    await pumpAsync(tester);
    await tester.pumpAndSettle();

    // Trailing clear button '✕' remains present
    expect(find.byKey(const ValueKey('search_clear_button')), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byKey(const ValueKey('search_clear_button')));
    await tester.pump();
    await pumpAsync(tester);
    await tester.pumpAndSettle();

    // Tap back button '<' to unfocus
    await tester.tap(find.byKey(const ValueKey('search_back_button')));
    await tester.pump();
    await pumpAsync(tester);
    await tester.pump(const Duration(milliseconds: 350));

    // Returns to magnifying glass and clear button vanishes
    expect(find.byKey(const ValueKey('search_glass_icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_clear_button')), findsNothing);
  });
}
