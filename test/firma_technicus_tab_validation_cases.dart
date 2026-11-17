part of 'firma_technicus_tab_test.dart';

void _validationTests() {
  testWidgets('Arbeidsduur van and tot validate presence and time order',
      (tester) async {
    GlobalKey<FormState>? formKey;
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: FirmaTechnicusTab(
            profileRepository: profileRepository,
            draftRepository: draftRepository,
            onFormKeyReady: (key) => formKey = key,
          ),
        ),
      ),
    );

    for (int i = 0; i < 20; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }

    expect(formKey, isNotNull);

    // Validate on initially empty draft -> fails validation
    final initialValid = formKey!.currentState!.validate();
    await tester.pumpAndSettle();
    expect(initialValid, isFalse);

    // Error text is suppressed (showErrorText: false), no error text widgets rendered
    expect(find.text('Starttijd is verplicht'), findsNothing);
    expect(find.text('Eindtijd is verplicht'), findsNothing);

    // Find Start Time and End Time fields by their section label
    final startContainer = find.ancestor(
      of: find.text(AppDictionary.lblTimeFrom),
      matching: find.byType(Expanded),
    );
    final startTimeFinder = find.descendant(
      of: startContainer,
      matching: find.byType(TextField),
    );

    final endContainer = find.ancestor(
      of: find.text(AppDictionary.lblTimeTo),
      matching: find.byType(Expanded),
    );
    final endTimeFinder = find.descendant(
      of: endContainer,
      matching: find.byType(TextField),
    );

    expect(startTimeFinder, findsOneWidget);
    expect(endTimeFinder, findsOneWidget);

    final startTextField = tester.widget<TextField>(startTimeFinder);
    final endTextField = tester.widget<TextField>(endTimeFinder);

    // Verify start time field has error border (red border)
    expect(
      (startTextField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );

    // Filling start time enables tot; set both to valid times (08:15 and 10:30)
    startTextField.controller!.text = '08:15';
    endTextField.controller!.text = '10:30';
    await tester.pumpAndSettle();

    formKey!.currentState!.validate();
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(startTimeFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );
    expect(
      (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );

    // Test invalid time order (end <= start)
    endTextField.controller!.text = '07:30';
    await tester.pumpAndSettle();
    formKey!.currentState!.validate();
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );

    // Restoring valid time order clears the red border
    endTextField.controller!.text = '09:00';
    await tester.pumpAndSettle();
    formKey!.currentState!.validate();
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );
  });

  testWidgets('Entering analyzer brand and serial updates and persists profile',
      (tester) async {
    await pumpTab(tester);

    final brandField = find.byKey(const ValueKey('technician_analyzerBrand'));
    final analyzerField =
        find.byKey(const ValueKey('technician_analyzerSerial'));
    expect(brandField, findsOneWidget);
    expect(analyzerField, findsOneWidget);

    await tester.enterText(brandField, 'Eurolyzer S1');
    await tester.enterText(analyzerField, '06-52-01055');
    await tester.pump(const Duration(milliseconds: 350));

    late TechnicianProfile profile;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      profile = await profileRepository.getProfile();
    });

    expect(profile.analyzerBrandModel, equals('Eurolyzer S1'));
    expect(profile.analyzerSerialNumber, equals('06-52-01055'));
  });
}
