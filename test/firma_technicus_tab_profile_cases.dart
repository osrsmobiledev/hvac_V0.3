part of 'firma_technicus_tab_test.dart';

void _profileTests() {
  testWidgets('Renders Firma and Technicus sections with all core inputs',
      (tester) async {
    await pumpTab(tester);

    // Verify Main Section Titles
    expect(find.text('Firma'), findsOneWidget);
    expect(find.text('Technicus'), findsOneWidget);

    // Verify Company Labels (matching Klant standard)
    expect(find.text(AppDictionary.lblCompanyName), findsOneWidget);
    expect(find.text(AppDictionary.lblStreet), findsOneWidget);
    expect(find.text(AppDictionary.lblHouseNumber), findsOneWidget);
    expect(find.text(AppDictionary.lblBox), findsOneWidget);
    expect(find.text(AppDictionary.lblPostalCode), findsOneWidget);
    expect(find.text(AppDictionary.lblCity), findsOneWidget);
    expect(find.text(AppDictionary.lblPhone), findsOneWidget);
    expect(find.text(AppDictionary.lblEmail), findsOneWidget);
    expect(find.text(AppDictionary.lblKBO), findsOneWidget);

    // Verify Technician Labels (no trailing colons)
    expect(find.text(AppDictionary.lblFirstName), findsOneWidget);
    expect(find.text(AppDictionary.lblLastName), findsOneWidget);
    expect(find.text(AppDictionary.lblGV), findsOneWidget);
    expect(find.text(AppDictionary.lblTV), findsOneWidget);

    // Verify Visit Timings Labels (no trailing colons)
    expect(find.text(AppDictionary.lblDate), findsOneWidget);
    expect(find.text(AppDictionary.lblTimeFrom), findsOneWidget);
    expect(find.text(AppDictionary.lblTimeTo), findsOneWidget);

    // Verify Date and Time input fields have centered text alignment
    final dateField =
        tester.widget<TextField>(find.widgetWithText(TextField, 'JJJJ-MM-DD'));
    expect(dateField.textAlign, equals(TextAlign.center));

    final startTimeField =
        tester.widget<TextField>(find.widgetWithText(TextField, '08:00'));
    expect(startTimeField.textAlign, equals(TextAlign.center));

    final endTimeField =
        tester.widget<TextField>(find.widgetWithText(TextField, '10:00'));
    expect(endTimeField.textAlign, equals(TextAlign.center));
  });

  testWidgets(
      'Editing company name debounces and persists to technician_profile',
      (tester) async {
    await pumpTab(tester);

    // Enter company name
    final nameField = find.widgetWithText(TextField, 'bv. HVAC Solutions BV');
    await tester.enterText(nameField, 'Klimaat Pro BV');
    await tester.pump(const Duration(milliseconds: 350));

    late TechnicianProfile profile;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      profile = await profileRepository.getProfile();
    });

    expect(profile.companyName, equals('Klimaat Pro BV'));
  });

  testWidgets('Tapping time field launches BO2 Time Spinner with Dutch labels',
      (tester) async {
    await pumpTab(tester);

    // Scroll to 'Arbeidsduur van'
    final timeField = find.widgetWithText(TextField, '08:00');
    await tester.ensureVisible(timeField);
    await tester.pumpAndSettle();

    await tester.tap(timeField);
    await tester.pumpAndSettle();

    // Verify BO2 Time Spinner Header & Dutch labels
    expect(find.text('Tijd instellen'), findsOneWidget);
    expect(find.text('UREN'), findsOneWidget);
    expect(find.text('MINUTEN'), findsOneWidget);
    expect(find.text('Annuleren'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    // Tap OK
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Spinner should dismiss
    expect(find.text('Tijd instellen'), findsNothing);
  });

  testWidgets('Pre-populated profile is restored in form fields',
      (tester) async {
    await tester.runAsync(() async {
      await profileRepository.saveProfile(
        const TechnicianProfile(
          companyName: 'Pre-existing HVAC',
          boxNumber: 'Bus 4B',
          technicianFirstName: 'Pieter',
          technicianLastName: 'Claes',
          gvNumber: 'GV99999',
        ),
      );
    });

    await pumpTab(tester);

    expect(find.text('Pre-existing HVAC'), findsOneWidget);
    expect(find.text('Bus 4B'), findsOneWidget);
    expect(find.text('Pieter'), findsOneWidget);
    expect(find.text('Claes'), findsOneWidget);
    expect(find.text('99999'), findsOneWidget);
  });

  testWidgets(
      'Disposing FirmaTechnicusTab flushes pending debounced profile to SQLite',
      (tester) async {
    await pumpTab(tester);

    // Enter company name (triggers 300ms debounce timer)
    final nameField = find.widgetWithText(TextField, 'bv. HVAC Solutions BV');
    await tester.enterText(nameField, 'Emergency Flush BV');

    // Unmount before 300ms expires (e.g. after 50ms)
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());

    late TechnicianProfile profile;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      profile = await profileRepository.getProfile();
    });

    // Profile was saved during dispose!
    expect(profile.companyName, equals('Emergency Flush BV'));
  });

  testWidgets(
      'onFormKeyReady exposes formKey and validate() checks required fields',
      (tester) async {
    GlobalKey<FormState>? formKey;
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
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }

    expect(formKey, isNotNull);
    // Empty fields -> validate() fails
    expect(formKey!.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    // Verify fields highlight red border and NO text underneath
    final firstNameField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('technician_firstName')),
      matching: find.byType(TextField),
    ));
    expect(
      (firstNameField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
    expect(find.text('Naam firma is verplicht'), findsNothing);
    expect(find.text('Voornaam is verplicht'), findsNothing);
    expect(find.text('GV-nummer vereist'), findsNothing);
  });
}
