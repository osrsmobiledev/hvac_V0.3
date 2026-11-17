part of 'meting_tab_test.dart';

void _layoutCases(
    Future<void> Function(WidgetTester, {BoilerDraftNotifier? notifier})
        pumpTab,
    Future<void> Function(WidgetTester) settleDebounce) {
  testWidgets('Instant reactive fuel switch from Gas to Stookolie via Notifier',
      (tester) async {
    final notifier = BoilerDraftNotifier();
    await tester.runAsync(() async => notifier.loadInitial());
    await pumpTab(tester, notifier: notifier);

    // Initially gas
    expect(find.textContaining('Gas'), findsWidgets);

    // Switch to Stookolie (vloeibaar)
    notifier.updateDraft(notifier.draft.copyWith(
      fuelCategory: 'vloeibaar',
      fuelSubtype: 'stookolie',
    ));
    await tester.pump();

    // Top banner immediately updates
    expect(find.text('Stookolie (Mazout)'), findsOneWidget);
    // Card 1 immediately switches to nozzle brand
    expect(find.text(MetingDictionary.lblNozzleBrandType), findsOneWidget);

    await settleDebounce(tester);
    notifier.dispose();
  });

  testWidgets(
      '2-Tier Collapsible MeasurementSlotSelector switches between Proef I and Proef II and expands modulation on demand',
      (tester) async {
    await pumpTab(tester);

    // 1. Initially on Proef I
    expect(find.text(MetingDictionary.slotProef1), findsOneWidget);
    expect(find.text(MetingDictionary.slotProef1Sub), findsOneWidget);
    expect(find.text(MetingDictionary.slotProef2), findsOneWidget);
    expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);

    // Modulation sub-toggle is hidden on Proef I
    expect(find.text(MetingDictionary.subSlotLaaglast), findsNothing);
    expect(find.text(MetingDictionary.subSlotHooglast), findsNothing);

    // 2. Tap Proef II: activates Proef II displaying [ L / H ▾ ] badge next to Proef II
    await tester.tap(find.text(MetingDictionary.slotProef2));
    await tester.pumpAndSettle();

    // Proef II displays compact Proef2ModulationBadge on top line and "Eindmeting" on bottom line
    expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);
    expect(find.byType(Proef2ModulationBadge), findsOneWidget);
    expect(find.text('L'), findsOneWidget);
    expect(find.text('H'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);

    // 3. Tap Proef II while active to expand modulation dropdown
    await tester.tap(find.text(MetingDictionary.slotProef2));
    await tester.pumpAndSettle();

    // Modulation sub-toggle is now smoothly revealed with full Dutch names
    expect(find.text(MetingDictionary.subSlotLaaglast), findsOneWidget);
    expect(find.text(MetingDictionary.subSlotHooglast), findsOneWidget);
    expect(find.byIcon(Icons.expand_less_rounded), findsOneWidget);

    // 4. Tap Hooglast: switches active mode to Hooglast and closes dropdown
    await tester.tap(find.text(MetingDictionary.subSlotHooglast));
    await tester.pumpAndSettle();

    // Dropdown closes, top badge remains showing L / H
    expect(find.text(MetingDictionary.subSlotHooglast), findsNothing);
    expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);

    // 5. Tap Proef I -> switches back cleanly
    await tester.tap(find.text(MetingDictionary.slotProef1));
    await settleDebounce(tester);
    expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);
  });

  testWidgets(
      'Statutory combustion fields adapt norm labels smartly to fuel and boiler type',
      (tester) async {
    final notifier = BoilerDraftNotifier();
    notifier.updateDraft(const BoilerDraft(
      fuelCategory: 'gas',
      centraalType: 'C',
      boilerOperation: 'condenserend',
    ));
    await pumpTab(tester, notifier: notifier);

    // Default: Gas Type C Condenserend
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

    // Update to Gas Type B1 -> Hi norm changes to >= 88%
    notifier.updateDraft(const BoilerDraft(
      fuelCategory: 'gas',
      centraalType: 'B',
      typeBText: 'B11',
    ));
    await settleDebounce(tester);

    expect(
      find.text(MetingDictionary.getHiNormText(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B11',
      )),
      findsOneWidget,
    );

    // Update to Gas Type B23P -> Hi norm changes to >= 90%
    notifier.updateDraft(const BoilerDraft(
      fuelCategory: 'gas',
      centraalType: 'B',
      typeBText: 'B23P',
    ));
    await settleDebounce(tester);

    expect(
      find.text(MetingDictionary.getHiNormText(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B23P',
      )),
      findsOneWidget,
    );

    // Update to Vloeibaar (Stookolie) -> Hi norm changes to >= 90% Stookolie
    notifier.updateDraft(const BoilerDraft(
      fuelCategory: 'vloeibaar',
      fuelSubtype: 'stookolie',
    ));
    await settleDebounce(tester);

    expect(
      find.text(MetingDictionary.getHiNormText(
        fuelCategory: 'vloeibaar',
        centraalType: 'C',
      )),
      findsOneWidget,
    );

    // Switch to Proef II: Fields remain present
    await tester.tap(find.text(MetingDictionary.slotProef2));
    await tester.pumpAndSettle();

    expect(find.byType(StatutoryCombustionField), findsNWidgets(2));
  });

  testWidgets(
      'CombustionFieldsLayout adapts on narrow Galaxy S23 (<380px) and wide screens',
      (tester) async {
    // 1. Narrow Galaxy S23 (360px viewport width)
    tester.view.physicalSize = const Size(360, 2200);
    tester.view.devicePixelRatio = 1.0;
    await pumpTab(tester);

    // All 8 labels with bracketed units are rendered without clipping
    expect(find.text(MetingDictionary.lblO2), findsOneWidget);
    expect(find.text(MetingDictionary.lblCO2), findsOneWidget);
    expect(find.text(MetingDictionary.lblCO), findsOneWidget);
    expect(find.text(MetingDictionary.lblFlueTempTg), findsOneWidget);
    expect(find.text(MetingDictionary.lblAirTempTa), findsOneWidget);
    expect(find.text(MetingDictionary.lblNetTemp), findsOneWidget);
    expect(find.text(MetingDictionary.lblEfficiencyHi), findsOneWidget);
    expect(find.text(MetingDictionary.lblEfficiencyHs), findsOneWidget);
  });

  testWidgets(
      'StatutoryCombustionField shows warning triangle (!) next to number when non-compliant or NOK',
      (tester) async {
    await pumpTab(tester);

    // Initially compliant or empty: no warning triangle
    expect(find.byIcon(Icons.warning_rounded), findsNothing);

    // Enter failing CO value (250 mg/kWh > 150)
    final coField = find.descendant(
      of: find.byType(StatutoryCombustionField).first,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(coField, '250.0');
    await tester.pump();

    // Warning triangle (!) appears next to the number
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
  });
}
