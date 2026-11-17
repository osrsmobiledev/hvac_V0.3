part of 'eindbeoordeling_tab_test.dart';

void _completionTests() {
  testWidgets('Renders all four bento cards and complete button',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    expect(find.text(EindbeoordelingDictionary.cardTitleConclusie),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.cardTitleVolgendeControle),
        findsOneWidget);
    expect(
        find.text(EindbeoordelingDictionary.cardTitleGebreken), findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.cardTitleHandtekeningen),
        findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.btnVoltooien), findsOneWidget);
  });

  testWidgets('Tapping Goed and Veilig updates draft in repository',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    await tester.tap(find.text(EindbeoordelingDictionary.optGoed));
    await tester.pumpAndSettle();

    await tester.tap(find.text(EindbeoordelingDictionary.optVeilig));
    await tester.pumpAndSettle();

    expect(repo.draft.toestelWerkingGoed, 'Goed');
    expect(repo.draft.toestelWerkingVeilig, 'Veilig');
    expect(repo.draft.hasNegativeAssessment, isFalse);
  });

  testWidgets('Tapping already selected Goed deselects it back to null',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    await tester.tap(find.text(EindbeoordelingDictionary.optGoed));
    await tester.pumpAndSettle();
    expect(repo.draft.toestelWerkingGoed, 'Goed');

    // Tap again to toggle off
    await tester.tap(find.text(EindbeoordelingDictionary.optGoed));
    await tester.pumpAndSettle();
    expect(repo.draft.toestelWerkingGoed, isNull);
  });

  testWidgets('Tapping Niet goed triggers the 3-month legal remediation banner',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    // Initially no remediation banner
    expect(find.text(EindbeoordelingDictionary.bannerRemediation3Months),
        findsNothing);

    // Tap Niet goed
    await tester.tap(find.text(EindbeoordelingDictionary.optNietGoed));
    await tester.pumpAndSettle();

    // Banner appears dynamically
    expect(find.text(EindbeoordelingDictionary.bannerRemediation3Months),
        findsOneWidget);
    expect(repo.draft.hasNegativeAssessment, isTrue);
  });

  testWidgets('Entering defect notes updates controller and persists to draft',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    final defectField = find.widgetWithText(
      TextField,
      EindbeoordelingDictionary.hintGebreken,
    );
    expect(defectField, findsOneWidget);
    await tester.enterText(defectField, 'Onvoldoende verluchting stooklokaal');
    await tester.pump(const Duration(milliseconds: 500));

    expect(
        repo.draft.defectsNotes, equals('Onvoldoende verluchting stooklokaal'));
  });

  testWidgets(
      'Tapping quick date chips updates next inspection date and allows deselect',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    await pumpTabScreen(tester, repo: repo);

    // Initially empty. Tapping +2 Jaar sets date to +2 years
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus2Years));
    await tester.pumpAndSettle();
    expect(repo.draft.nextInspectionDate, '25/10/2027');

    // Tapping already selected +2 Jaar deselects it back to empty
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus2Years));
    await tester.pumpAndSettle();
    expect(repo.draft.nextInspectionDate, '');

    // Tapping +1 Jaar sets date to +1 year
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus1Year));
    await tester.pumpAndSettle();
    expect(repo.draft.nextInspectionDate, '25/10/2026');

    // Tapping already selected +1 Jaar deselects it back to empty
    await tester.tap(find.text(EindbeoordelingDictionary.chipPlus1Year));
    await tester.pumpAndSettle();
    expect(repo.draft.nextInspectionDate, '');
  });

  testWidgets(
      'Tapping Voltooien button always invokes onComplete to delegate to pre-flight check',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    bool completed = false;

    await pumpTabScreen(
      tester,
      repo: repo,
      onComplete: () => completed = true,
    );

    await tester.tap(find.text(EindbeoordelingDictionary.btnVoltooien));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('Completing with conclusions succeeds and triggers onComplete',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    bool completed = false;

    await pumpTabScreen(
      tester,
      repo: repo,
      onComplete: () => completed = true,
    );

    await tester.tap(find.text(EindbeoordelingDictionary.optGoed));
    await tester.pumpAndSettle();
    await tester.tap(find.text(EindbeoordelingDictionary.optVeilig));
    await tester.pumpAndSettle();

    await tester.tap(find.text(EindbeoordelingDictionary.btnVoltooien));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets(
      'Reactive fuel switch from Stooktoestel via BoilerDraftNotifier updates statutory date',
      (tester) async {
    final repo = FakeEindbeoordelingRepository();
    repo.draft = const EindbeoordelingDraft(
      toestelWerkingGoed: 'Goed',
      toestelWerkingVeilig: 'Veilig',
      nextInspectionDate: '25/10/2027',
    );
    final notifier = BoilerDraftNotifier();
    notifier.updateDraft(const BoilerDraft(fuelCategory: 'gas'));

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
            boilerNotifier: notifier,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Gas: 2025-10-25 + 2 years = 25/10/2027 displayed in the UI
    expect(find.text('25/10/2027'), findsOneWidget);

    // Switch to oil
    notifier.updateDraft(const BoilerDraft(fuelCategory: 'vloeibaar'));
    await tester.pumpAndSettle();

    // Oil: 2025-10-25 + 1 year = 25/10/2026 displayed and saved
    expect(find.text('25/10/2026'), findsOneWidget);
    expect(repo.draft.nextInspectionDate, '25/10/2026');
  });
}
