part of 'firma_technicus_tab_test.dart';

void _inputTests() {
  testWidgets(
      'Phone field is optional when empty but validates strictly when entered',
      (tester) async {
    await pumpTab(tester);

    final phoneFinder = find.byKey(const ValueKey('company_phone'));
    expect(phoneFinder, findsOneWidget);

    // Empty phone does not show any error
    expect(
      find.text('Ongeldig telefoonnummer (bv. 470 12 34 56)'),
      findsNothing,
    );

    // Enter invalid phone (8 digits starting with 4)
    await tester.enterText(phoneFinder, '47012345');
    await tester.pumpAndSettle();
    final phoneFieldInvalid = tester.widget<TextField>(find.descendant(
      of: phoneFinder,
      matching: find.byType(TextField),
    ));
    expect(
      (phoneFieldInvalid.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
    expect(
      find.text('Ongeldig telefoonnummer (bv. 470 12 34 56)'),
      findsNothing,
    );

    // Complete to valid 9 digits
    await tester.enterText(phoneFinder, '470123456');
    await tester.pumpAndSettle();
    final phoneFieldValid = tester.widget<TextField>(find.descendant(
      of: phoneFinder,
      matching: find.byType(TextField),
    ));
    expect(
      (phoneFieldValid.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );

    // Clearing back to empty removes error
    await tester.enterText(phoneFinder, '');
    await tester.pumpAndSettle();
    final phoneFieldEmpty = tester.widget<TextField>(find.descendant(
      of: phoneFinder,
      matching: find.byType(TextField),
    ));
    expect(
      (phoneFieldEmpty.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );

    // Let debounce timer and async persistence complete cleanly
    await tester.pump(const Duration(milliseconds: 350));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  });

  testWidgets(
      'Typing in GV immediately clears TV validation error and vice-versa',
      (tester) async {
    await pumpTab(tester);

    // Validate form to trigger initial errors
    final form = tester.widget<Form>(find.byType(Form));
    (form.key as GlobalKey<FormState>).currentState!.validate();
    await tester.pumpAndSettle();

    final tvFinder = find.descendant(
      of: find.byType(TechnicianSection),
      matching: find.widgetWithText(TextField, 'TV01234'),
    );
    final gvFinder = find.descendant(
      of: find.byType(TechnicianSection),
      matching: find.widgetWithText(TextField, 'GV01234'),
    );
    expect(
      (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
    expect(
      (tester.widget<TextField>(gvFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
    expect(find.text('GV-nummer vereist'), findsNothing);

    // Typing into GV immediately clears both errors
    await tester.enterText(gvFinder, 'GV98765');
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );
    expect(
      (tester
              .widget<TextField>(find.widgetWithText(TextField, 'GV98765'))
              .decoration!
              .enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );

    // Clearing GV brings both errors back
    await tester.enterText(find.widgetWithText(TextField, 'GV98765'), '');
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );

    // Let debounce timer complete
    await tester.pump(const Duration(milliseconds: 350));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  });

  testWidgets('Voornaam and Achternaam auto-capitalize words in real time',
      (tester) async {
    await pumpTab(tester);

    final firstNameFinder = find.widgetWithText(TextField, 'bv. Jan');
    await tester.enterText(firstNameFinder, 'jan-pieter');
    await tester.pumpAndSettle();
    expect(find.text('Jan-Pieter'), findsOneWidget);

    final lastNameFinder = find.widgetWithText(TextField, 'bv. Janssens');
    await tester.enterText(lastNameFinder, 'van den berg');
    await tester.pumpAndSettle();
    expect(find.text('Van Den Berg'), findsOneWidget);

    // Let debounce timer complete
    await tester.pump(const Duration(milliseconds: 350));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  });
}
