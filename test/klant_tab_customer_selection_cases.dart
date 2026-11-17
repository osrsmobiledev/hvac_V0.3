part of 'klant_tab_test.dart';

void _customerSelectionTests() {
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
    final cityField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('customer_city')),
      matching: find.byType(TextField),
    ));
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

  testWidgets(
      'onFormKeyReady exposes formKey and validate() checks required fields and highlights red',
      (tester) async {
    GlobalKey<FormState>? formKey;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: KlantTab(
            customerRepository: customerRepository,
            draftRepository: draftRepository,
            onFormKeyReady: (k) => formKey = k,
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(formKey, isNotNull);
    // Empty fields -> validate() fails
    expect(formKey!.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    // Verify required fields highlight red border and NO text underneath
    final firstNameField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('customer_firstName')),
      matching: find.byType(TextField),
    ));
    expect(
      (firstNameField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
    expect(find.text('Voornaam is verplicht'), findsNothing);

    final streetField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('customer_street')),
      matching: find.byType(TextField),
    ));
    expect(
      (streetField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );

    // Bedrijfsnaam remains optional (not red)
    final companyField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('customer_company')),
      matching: find.byType(TextField),
    ));
    expect(
      (companyField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );
  });

  testWidgets(
      'Rebuilding invalid fields or secondary tap does not trigger setState during build',
      (tester) async {
    GlobalKey<FormState>? formKey;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: KlantTab(
          customerRepository: customerRepository,
          draftRepository: draftRepository,
          onFormKeyReady: (k) => formKey = k,
        ),
      ),
    ));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    // Trigger validation error
    expect(formKey!.currentState!.validate(), isFalse);
    await tester.pump();

    // Simulate secondary tap / right click on invalid field
    await tester.tap(
      find.byKey(const ValueKey('customer_firstName')),
      buttons: kSecondaryMouseButton,
      warnIfMissed: false,
    );
    await tester.pump();

    // Re-pump widget tree to trigger didUpdateWidget across the form
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: KlantTab(
          customerRepository: customerRepository,
          draftRepository: draftRepository,
          onFormKeyReady: (k) => formKey = k,
        ),
      ),
    ));
    await tester.pump();

    // No exception thrown
    expect(tester.takeException(), isNull);
  });
}
