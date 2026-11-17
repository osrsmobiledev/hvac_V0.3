part of 'start_tab_test.dart';

void _persistenceAndValidationCases(
    Future<void> Function(WidgetTester) pumpStartTab,
    DraftRepository Function() getRepository) {
  testWidgets(
      'On narrow S23 phone (360dp width), activity options render on one line without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpStartTab(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(
          ActivityOptionTile, AppDictionary.activityMaintenance),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(
        ActivityOptionTile,
        AppDictionary.activityCommissioningShort,
      ),
      findsOneWidget,
    );

    // Verify the button text widget has maxLines: 1
    final textFinder = find.descendant(
      of: find.widgetWithText(
        ActivityOptionTile,
        AppDictionary.activityCommissioningShort,
      ),
      matching: find.text(AppDictionary.activityCommissioningShort),
    );
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.maxLines, equals(1));
  });

  testWidgets(
      'Submitting sequence number immediately saves without waiting for debounce',
      (tester) async {
    await pumpStartTab(tester);

    // Enter text and immediately submit (tap Done on keyboard)
    await tester.enterText(find.byType(TextField), 'IMMEDIATE-777');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    late DraftVisit draft;
    await tester.runAsync(() async {
      draft = await getRepository().getOrCreateActiveDraft();
    });

    // Should be saved immediately without 300ms wait
    expect(draft.attestNumber, equals('IMMEDIATE-777'));
  });

  testWidgets('Disposing StartTab flushes pending debounce input to SQLite',
      (tester) async {
    await pumpStartTab(tester);

    // Enter text (triggers 300ms timer)
    await tester.enterText(find.byType(TextField), 'FLUSH-ON-DISPOSE');

    // Immediately unmount/replace widget BEFORE debounce expires (only 50ms)
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());

    late DraftVisit draft;
    await tester.runAsync(() async {
      draft = await getRepository().getOrCreateActiveDraft();
    });

    // Flushed to database during dispose
    expect(draft.attestNumber, equals('FLUSH-ON-DISPOSE'));
  });

  testWidgets(
      'onFormKeyReady exposes formKey and validate() checks required fields',
      (tester) async {
    GlobalKey<FormState>? formKey;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: StartTab(
            draftRepository: getRepository(),
            onFormKeyReady: (key) => formKey = key,
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

    // Zero error text rendered on screen
    expect(
      find.text('Kies een activiteitstype (Onderhoud of Eerste ingebruikname)'),
      findsNothing,
    );
    expect(find.text('Volgnummer attest is verplicht'), findsNothing);

    // Verify unified TacticalGroupOutline has red border outlining both activity options
    final groupOutline = tester.widget<TacticalGroupOutline>(
      find.byType(TacticalGroupOutline),
    );
    expect(groupOutline.hasError, isTrue);

    final groupContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TacticalGroupOutline),
            matching: find.byType(Container),
          )
          .first,
    );
    final border = (groupContainer.decoration as BoxDecoration).border;
    expect(border?.top.color, AppColors.errorRed);

    // Verify individual buttons keep resting border (not individual error outlines)
    final activityTiles = tester.widgetList<ActivityOptionTile>(
      find.byType(ActivityOptionTile),
    );
    expect(activityTiles.first.isError, isFalse);
    expect(activityTiles.last.isError, isFalse);

    // Selecting an activity option immediately clears the group error outline
    await tester.tap(find.widgetWithText(ActivityOptionTile, 'Onderhoud'));
    await tester.pump();

    final updatedGroupOutline = tester.widget<TacticalGroupOutline>(
      find.byType(TacticalGroupOutline),
    );
    expect(updatedGroupOutline.hasError, isFalse);

    final updatedContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TacticalGroupOutline),
            matching: find.byType(Container),
          )
          .first,
    );
    final updatedBorder = (updatedContainer.decoration as BoxDecoration).border;
    expect(updatedBorder?.top.color, Colors.transparent);

    // Verify sequence number input box has red border
    final attestTextField = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('start_attestNumber')),
      matching: find.byType(TextField),
    ));
    expect(
      (attestTextField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );
  });
}
