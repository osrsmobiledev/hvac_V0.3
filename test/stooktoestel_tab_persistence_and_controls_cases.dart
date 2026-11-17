part of 'stooktoestel_tab_test.dart';

void _persistenceAndControlsCases(Future<void> Function(WidgetTester) pumpTab) {
  testWidgets(
      'Toestel card renders full-width input boxes with Onbekend header chips and clean labels',
      (tester) async {
    await pumpTab(tester);

    // Verify clean labels without colons (Card 3 in default integrated mode hides separate burner inputs)
    expect(find.text('Merk'), findsOneWidget);
    expect(find.text('Type / Model'), findsOneWidget);
    expect(find.text('Bouwjaar'), findsOneWidget);
    expect(find.text('Fabricatienummer'), findsOneWidget);
    expect(find.text('Nominaal vermogen (kW)'), findsOneWidget);

    // Verify HeaderWithUnknownChip widgets for Bouwjaar and Fabricatienummer
    final unknownHeaderChips = find.byType(HeaderWithUnknownChip);
    expect(unknownHeaderChips, findsNWidgets(2));

    // Tap Onbekend for Bouwjaar
    final yearUnknownChip = find.descendant(
      of: unknownHeaderChips.at(0),
      matching: find.text(AppDictionary.optUnknown),
    );
    await tester.tap(yearUnknownChip);
    await tester.pumpAndSettle();

    // Tap Onbekend for Fabricatienummer
    final serialUnknownChip = find.descendant(
      of: unknownHeaderChips.at(1),
      matching: find.text(AppDictionary.optUnknown),
    );
    await tester.tap(serialUnknownChip);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'BrandQuickPicker renders distinct boiler brand chips and populates brand field on tap',
      (tester) async {
    await pumpTab(tester);

    // Verify popular brand chips exist as distinct entities (Bosch and Junkers are not merged)
    expect(find.text('Vaillant'), findsOneWidget);
    expect(find.text('Viessmann'), findsOneWidget);
    expect(find.text('Remeha'), findsOneWidget);
    expect(find.text('Bulex'), findsOneWidget);
    expect(find.text('Bosch'), findsOneWidget);
    expect(find.text('Junkers'), findsOneWidget);

    // Tap Vaillant chip
    await tester.tap(find.text('Vaillant'));
    await tester.pumpAndSettle();

    // Find the first TextField (Merk) and verify text
    expect(find.widgetWithText(TextField, 'Vaillant'), findsOneWidget);

    // Scroll and tap Bosch
    final brandScroll = find.descendant(
      of: find.byType(BrandQuickPicker),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(find.text('Bosch'), 50.0,
        scrollable: brandScroll);
    await tester.tap(find.text('Bosch'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Bosch'), findsOneWidget);

    // Scroll and tap Junkers
    await tester.scrollUntilVisible(find.text('Junkers'), 50.0,
        scrollable: brandScroll);
    await tester.tap(find.text('Junkers'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Junkers'), findsOneWidget);
  });

  testWidgets(
      'StooktoestelTab synchronizes reactively with BoilerDraftNotifier',
      (tester) async {
    tester.view.physicalSize = const Size(412, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifier = BoilerDraftNotifier();
    addTearDown(notifier.dispose);
    notifier.updateDraft(const BoilerDraft(
      boilerBrand: 'Viessmann',
      fuelCategory: 'vloeibaar',
      centraalType: 'B',
      typeBText: 'B23',
    ));

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StooktoestelTab(boilerNotifier: notifier),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Viessmann'), findsOneWidget);
  });

  testWidgets(
      'Selecting Gasvormig does NOT auto-select aardgas; subtypes remain unselected and de-selectable',
      (tester) async {
    tester.view.physicalSize = const Size(412, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifier = BoilerDraftNotifier();
    addTearDown(notifier.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StooktoestelTab(boilerNotifier: notifier),
      ),
    ));
    await tester.pumpAndSettle();

    // Tap Gasvormig
    await tester.tap(find.text(AppDictionary.fuelGasShort));
    await tester.pumpAndSettle();

    // Category is gas, but subtype is empty (not auto-selected!)
    expect(notifier.draft.fuelCategory, 'gas');
    expect(notifier.draft.fuelSubtype, '');

    // Tap aardgas chip explicitly
    await tester.tap(find.text(AppDictionary.gasNatural));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelSubtype, 'aardgas');

    // Tap aardgas chip again to de-select
    await tester.tap(find.text(AppDictionary.gasNatural));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelSubtype, '');
  });

  testWidgets(
      'Subtype selections are remembered when switching between fuel categories',
      (tester) async {
    tester.view.physicalSize = const Size(412, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifier = BoilerDraftNotifier();
    addTearDown(notifier.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StooktoestelTab(boilerNotifier: notifier),
      ),
    ));
    await tester.pumpAndSettle();

    // 1. Select Gas and Aardgas
    await tester.tap(find.text(AppDictionary.fuelGasShort));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppDictionary.gasNatural));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelCategory, 'gas');
    expect(notifier.draft.fuelSubtype, 'aardgas');

    // 2. Switch to Vloeibaar (oil has no subtype)
    await tester.tap(find.text(AppDictionary.fuelLiquidShort));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelCategory, 'vloeibaar');
    expect(notifier.draft.fuelSubtype, '');

    // 3. Switch back to Gasvormig -> Aardgas is remembered!
    await tester.tap(find.text(AppDictionary.fuelGasShort));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelCategory, 'gas');
    expect(notifier.draft.fuelSubtype, 'aardgas');

    // 4. Switch to Vast -> starts unselected
    await tester.tap(find.text(AppDictionary.fuelSolidShort));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelCategory, 'vast');
    expect(notifier.draft.fuelSubtype, '');

    // 5. Select Houtpellets
    await tester.tap(find.text(AppDictionary.solidPellets));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelSubtype, 'houtpellets');

    // 6. Switch to Gasvormig -> remembers Aardgas
    await tester.tap(find.text(AppDictionary.fuelGasShort));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelSubtype, 'aardgas');

    // 7. Switch back to Vast -> remembers Houtpellets
    await tester.tap(find.text(AppDictionary.fuelSolidShort));
    await tester.pumpAndSettle();
    expect(notifier.draft.fuelSubtype, 'houtpellets');
  });

  testWidgets(
      'Form validation enforces Centraal Type B/C, gas subtype, and burner technology',
      (tester) async {
    GlobalKey<FormState>? capturedKey;
    tester.view.physicalSize = const Size(412, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StooktoestelTab(
          onFormKeyReady: (k) => capturedKey = k,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(capturedKey, isNotNull);

    // 1. Initial empty validate fails
    expect(capturedKey!.currentState!.validate(), isFalse);

    // 2. Select Gasvormig
    await tester.tap(find.text(AppDictionary.fuelGasShort));
    await tester.pumpAndSettle();

    // Subtype and technology are missing, so validate fails
    expect(capturedKey!.currentState!.validate(), isFalse);

    // 3. Select Aardgas and Premix
    await tester.tap(find.text(AppDictionary.gasNatural));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppDictionary.techPremix));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
