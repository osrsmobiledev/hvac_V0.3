part of 'eindbeoordeling_tab_test.dart';

void _assessmentTests() {
  testWidgets(
      'Tapping +3 Maanden sets remediation date, and marking Niet goed auto-switches to +3 Maanden',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: EindbeoordelingTab(
            visitId: 1,
            repositoryOverride: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state has no conclusions and empty date
    expect(
        find.text(EindbeoordelingDictionary.datePlaceholder), findsOneWidget);

    // Verify +3 Maanden button exists and tap it
    expect(
        find.text(EindbeoordelingDictionary.chipPlus3Months), findsOneWidget);
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus3Months));
    await tester.pumpAndSettle();
    expect(find.text('25/01/2026'), findsOneWidget);

    // Tap +3 Maanden again deselects to empty
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus3Months));
    await tester.pumpAndSettle();
    expect(
        find.text(EindbeoordelingDictionary.datePlaceholder), findsOneWidget);
  });

  testWidgets(
      'MeasurementAssessmentNotifier dynamically updates EindbeoordelingTab when combustion fails',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    final assessmentNotifier = MeasurementAssessmentNotifier();
    final boilerNotifier = BoilerDraftNotifier();
    boilerNotifier.updateDraft(const BoilerDraft(fuelCategory: 'gas'));
    addTearDown(assessmentNotifier.dispose);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: EindbeoordelingTab(
            visitId: 1,
            repositoryOverride: repo,
            boilerNotifier: boilerNotifier,
            assessmentNotifier: assessmentNotifier,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially Goed is null/initialized, date is empty placeholder
    expect(
        find.text(EindbeoordelingDictionary.datePlaceholder), findsOneWidget);

    // Tab 6 signals combustion failure (e.g. NOK on CO or Efficiency)
    assessmentNotifier.updateAssessment(
      combustionPassed: false,
      safetyChecksPassed: true,
    );
    await tester.pumpAndSettle();

    // Tab 7 immediately reacts: Niet goed is selected and date auto-switched to +3 months (25/01/2026)
    expect(find.text('25/01/2026'), findsOneWidget);
    expect(repo.draft.toestelWerkingGoed, 'Niet goed');
    expect(repo.draft.nextInspectionDate, '25/01/2026');

    // Now Tab 6 signals all passing again
    assessmentNotifier.updateAssessment(
      combustionPassed: true,
      safetyChecksPassed: true,
    );
    await tester.pumpAndSettle();

    // Tab 7 restores Goed and statutory interval
    expect(find.text('25/10/2027'), findsOneWidget);
    expect(repo.draft.toestelWerkingGoed, 'Goed');
    expect(repo.draft.nextInspectionDate, '25/10/2027');

    // Tab 6 signals measurements/checks cleared back to null
    assessmentNotifier.updateAssessment(
      combustionPassed: null,
      safetyChecksPassed: null,
    );
    await tester.pumpAndSettle();

    // Tab 7 reverts conclusions back to null (unselected)
    expect(repo.draft.toestelWerkingGoed, isNull);
    expect(repo.draft.toestelWerkingVeilig, isNull);
  });

  testWidgets('Staat van werking card displays both section labels',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    expect(find.text(EindbeoordelingDictionary.headerHetStooktoestelWerkt),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.lblVerluchtingRookgasafvoer),
        findsOneWidget);
  });

  testWidgets(
      'Customer signature exception buttons (Weigert / Afwezig) toggle and update tile display',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    // Initially, prompt says 'Tik om te ondertekenen'
    expect(find.text(EindbeoordelingDictionary.btnTikOmTeTekenen),
        findsNWidgets(2)); // Tech + Customer

    // Progressive disclosure trigger is present, buttons initially collapsed
    expect(find.text(EindbeoordelingDictionary.lblKlantKanNietTekenen),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.btnKlantWeigert), findsNothing);

    // Tap trigger to expand
    await tester
        .tap(find.text(EindbeoordelingDictionary.lblKlantKanNietTekenen));
    await tester.pumpAndSettle();

    expect(
        find.text(EindbeoordelingDictionary.btnKlantWeigert), findsOneWidget);
    expect(
        find.text(EindbeoordelingDictionary.btnKlantAfwezig), findsOneWidget);

    // 1. Tap "Weigert"
    await tester.tap(find.text(EindbeoordelingDictionary.btnKlantWeigert));
    await tester.pumpAndSettle();

    expect(repo.draft.customerSignatureException, 'refused');
    expect(find.text(EindbeoordelingDictionary.statusKlantWeigert),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.subStatutairVermeld),
        findsOneWidget);

    // 2. Tap "Weigert" again to unselect (toggle off)
    await tester.tap(find.text(EindbeoordelingDictionary.btnKlantWeigert));
    await tester.pumpAndSettle();

    expect(repo.draft.customerSignatureException, isNull);
    expect(find.text(EindbeoordelingDictionary.btnTikOmTeTekenen),
        findsNWidgets(2));

    // 3. Tap "Afwezig"
    await tester.tap(find.text(EindbeoordelingDictionary.btnKlantAfwezig));
    await tester.pumpAndSettle();

    expect(repo.draft.customerSignatureException, 'absent');
    expect(find.text(EindbeoordelingDictionary.statusKlantAfwezig),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.subStatutairVermeld),
        findsOneWidget);

    // 4. Tap "Weigert" while "Afwezig" is active switches directly to refused
    await tester.tap(find.text(EindbeoordelingDictionary.btnKlantWeigert));
    await tester.pumpAndSettle();

    expect(repo.draft.customerSignatureException, 'refused');
    expect(find.text(EindbeoordelingDictionary.statusKlantWeigert),
        findsOneWidget);
  });
}
