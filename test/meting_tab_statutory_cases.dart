part of 'meting_tab_test.dart';

void _statutoryCases(
    Future<void> Function(WidgetTester, {BoilerDraftNotifier? notifier})
        pumpTab,
    Future<void> Function(WidgetTester) settleDebounce) {
  testWidgets(
      'Combustion measurements support Proef I and Proef II values independently',
      (tester) async {
    await pumpTab(tester);

    // 1. Proef I: enter failing CO (250 mg/kWh) and compliant Hi (95%)
    final coField = find.descendant(
      of: find.byType(StatutoryCombustionField).first,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(coField, '250.0');

    final hiField = find.descendant(
      of: find.byType(StatutoryCombustionField).last,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(hiField, '95.0');
    await settleDebounce(tester);

    // Warning triangle (!) appears for failing CO in Proef I
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

    // 2. Switch to Proef II (Eindmeting after cleaning)
    await tester.tap(find.text(MetingDictionary.slotProef2));
    await tester.pumpAndSettle();

    // Enter compliant readings in Proef II (CO 25, Hi 98)
    final p2CoField = find.descendant(
      of: find.byType(StatutoryCombustionField).first,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(p2CoField, '25.0');
    final p2HiField = find.descendant(
      of: find.byType(StatutoryCombustionField).last,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(p2HiField, '98.0');
    await settleDebounce(tester);

    // Proef II is compliant: no warning triangle
    expect(find.byIcon(Icons.warning_rounded), findsNothing);

    // 3. Switch back to Proef I: failing state remains isolated in Proef I
    await tester.tap(find.text(MetingDictionary.slotProef1));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
  });

  testWidgets(
      'Technician has full manual authority: tapping OK on failing CO (250 mg/kWh) retains OK',
      (tester) async {
    await pumpTab(tester);

    final coFieldWidget = find.byType(StatutoryCombustionField).first;
    final coInput = find.descendant(
      of: coFieldWidget,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(coInput, '250.0');
    await settleDebounce(tester);

    // Automatically assessed as NOK
    final binaryCheckBefore = tester.widget<TacticalBinaryCheck>(
      find.descendant(
        of: coFieldWidget,
        matching: find.byType(TacticalBinaryCheck),
      ),
    );
    expect(binaryCheckBefore.value, isFalse);

    // Tap OK button inside CO field
    final coOkBtn = find.descendant(
      of: coFieldWidget,
      matching: find.text(MetingDictionary.lblOk),
    );
    await tester.tap(coOkBtn);
    await settleDebounce(tester);

    // Verify technician choice is preserved and not clobbered
    final binaryCheckAfter = tester.widget<TacticalBinaryCheck>(
      find.descendant(
        of: coFieldWidget,
        matching: find.byType(TacticalBinaryCheck),
      ),
    );
    expect(binaryCheckAfter.value, isTrue);
  });

  testWidgets(
      'Numeric combustion fields display right-side unit when value is entered',
      (tester) async {
    await pumpTab(tester);

    // Initially no % unit is visible for O2
    expect(
      find.descendant(
        of: find.byType(DarkTextField).first,
        matching: find.textContaining('%'),
      ),
      findsNothing,
    );

    // Enter value in O2 field
    final o2Field = find.descendant(
      of: find.byType(DarkTextField).first,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(o2Field, '4.8');
    await tester.pump();

    // % unit now appears attached to the number!
    expect(
      find.descendant(
        of: find.byType(DarkTextField).first,
        matching: find.text('4.8 %'),
      ),
      findsOneWidget,
    );

    // Enter value in flue temp (tg) field (4th DarkTextField)
    final tgField = find.descendant(
      of: find.byType(DarkTextField).at(3),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(tgField, '54.2');
    await tester.pump();

    // °C unit appears attached to tg field!
    expect(
      find.descendant(
        of: find.byType(DarkTextField).at(3),
        matching: find.text('54.2 °C'),
      ),
      findsOneWidget,
    );
  });
}
