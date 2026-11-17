part of 'meting_tab_test.dart';

void _slotCases(
    Future<void> Function(WidgetTester, {BoilerDraftNotifier? notifier})
        pumpTab,
    Future<void> Function(WidgetTester) settleDebounce,
    Database Function() getDatabase) {
  testWidgets(
      'Banner displays Gasvormig when only gas category is selected, and appends subtype when chosen',
      (tester) async {
    final notifier = BoilerDraftNotifier();
    addTearDown(notifier.dispose);
    notifier.updateDraft(const BoilerDraft(
      fuelCategory: 'gas',
      fuelSubtype: '',
    ));
    await pumpTab(tester, notifier: notifier);

    // Only Gasvormig, NOT Gasvormig (Aardgas)
    expect(find.text('Gasvormig'), findsOneWidget);
    expect(find.text('Gasvormig (Aardgas)'), findsNothing);

    // Now set subtype to aardgas
    notifier.updateDraft(notifier.draft.copyWith(fuelSubtype: 'aardgas'));
    await tester.pump();

    expect(find.text('Gasvormig (Aardgas)'), findsOneWidget);
    await settleDebounce(tester);
  });

  testWidgets(
      'Tapping Neem over van Tab 1 populates slot and calculates net temp',
      (tester) async {
    await pumpTab(tester);

    // Tap import button
    await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
    await settleDebounce(tester);

    // Net temp: 54.2 - 19.8 = 34.4 °C
    expect(find.text('34.4 °C'), findsOneWidget);

    // CO (24.5) and Hi (98.4) display populated numbers
    expect(find.text('24.5'), findsOneWidget);
    expect(find.text('98.4'), findsOneWidget);

    // Statutory combustion fields are present with smart norms inside the input box
    expect(find.byType(StatutoryCombustionField), findsNWidgets(2));
    expect(
      find.text(MetingDictionary.getCoNormText(fuelCategory: 'gas')),
      findsOneWidget,
    );
    expect(
      find.text(MetingDictionary.getHiNormText(
        fuelCategory: 'gas',
        centraalType: 'C',
      )),
      findsOneWidget,
    );
  });

  testWidgets('Tapping Wissen clears the active slot after confirmation',
      (tester) async {
    await pumpTab(tester);

    // Initially empty: delete button is disabled
    final clearButton = find.byTooltip(MetingDictionary.btnClearSlot);
    expect(clearButton, findsOneWidget);

    // Populate via Tab 1 import
    await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
    await settleDebounce(tester);
    expect(find.text('34.4 °C'), findsOneWidget);

    // Now tap delete icon button
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text(MetingDictionary.dlgConfirmClearTitle), findsOneWidget);
    await tester.tap(find.text('Wissen'));
    await settleDebounce(tester);

    // Net temp cleared
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('Tapping QR icon opens EurolyzerScannerModal and simulates scan',
      (tester) async {
    await pumpTab(tester);

    final qrButton = find.byTooltip(MetingDictionary.btnScanEurolyzer);
    expect(qrButton, findsOneWidget);
    await tester.tap(qrButton);
    await tester.pumpAndSettle();

    // Scanner modal opens with simulate button
    final simulateBtn =
        find.byKey(const ValueKey('simulate_eurolyzer_qr_button'));
    expect(simulateBtn, findsOneWidget);

    await tester.tap(simulateBtn);
    await settleDebounce(tester);

    // Values populated from simulation!
    expect(find.text('34.4 °C'), findsOneWidget);
  });

  testWidgets('Neem over van Tab 1 shows warning dialog when Tab 1 has no data',
      (tester) async {
    await tester.runAsync(() async {
      await getDatabase()
          .delete('measurement_captures', where: "slot = 'tab1_raw'");
    });

    await pumpTab(tester);

    await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text(MetingDictionary.dlgNoTab1DataTitle), findsOneWidget);
    expect(find.text(MetingDictionary.btnScanDirect), findsOneWidget);

    // Dismiss dialog so async action completes cleanly
    await tester.tap(find.text(AppDictionary.btnCancel));
    await tester.pumpAndSettle();
  });

  testWidgets('Tapping TacticalBinaryCheck toggles OK and Niet OK states',
      (tester) async {
    await pumpTab(tester);

    // Find first TacticalBinaryCheck in Card 3
    final firstCheck = find.descendant(
      of: find.ancestor(
        of: find.text(MetingDictionary.lblCheckFluePressure),
        matching: find.byType(Column),
      ),
      matching: find.byType(TacticalBinaryCheck),
    );
    expect(firstCheck, findsWidgets);

    // 1. Tap OK -> selected
    final okButton = find.descendant(
      of: firstCheck.first,
      matching: find.text(MetingDictionary.lblOk),
    );
    await tester.tap(okButton);
    await settleDebounce(tester);
    expect(tester.widget<TacticalBinaryCheck>(firstCheck.first).value, isTrue);

    // 2. Tap OK again -> de-selected back to null
    await tester.tap(okButton);
    await settleDebounce(tester);
    expect(tester.widget<TacticalBinaryCheck>(firstCheck.first).value, isNull);

    // 3. Tap Niet OK -> selected
    final notOkButton = find.descendant(
      of: firstCheck.first,
      matching: find.text(MetingDictionary.lblNotOk),
    );
    await tester.tap(notOkButton);
    await settleDebounce(tester);
    expect(tester.widget<TacticalBinaryCheck>(firstCheck.first).value, isFalse);

    // 4. Tap Niet OK again -> de-selected back to null
    await tester.tap(notOkButton);
    await settleDebounce(tester);
    expect(tester.widget<TacticalBinaryCheck>(firstCheck.first).value, isNull);

    expect(tester.takeException(), isNull);
  });
}
