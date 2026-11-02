// File: test/eindbeoordeling_tab_test.dart
// Responsibility: Widget tests for Slice 3.3 — Tab 7 (Eindbeoordeling & Handtekeningen).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/measurement_assessment_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart';

class FakeEindbeoordelingRepository implements EindbeoordelingRepository {
  EindbeoordelingDraft draft = const EindbeoordelingDraft();
  VisitContextSummary contextSummary = const VisitContextSummary(
    fuelType: 'gas',
    visitDate: '2025-10-25',
    customerName: 'Jan Janssens',
  );

  @override
  Future<EindbeoordelingDraft> loadDraft(
      {required int visitId, Database? dbOverride}) async {
    return draft;
  }

  @override
  Future<VisitContextSummary> loadVisitContext(
      {required int visitId, Database? dbOverride}) async {
    return contextSummary;
  }

  @override
  Future<void> updateDraft({
    required int visitId,
    required EindbeoordelingDraft draft,
    Database? dbOverride,
  }) async {
    this.draft = draft;
  }

  @override
  Future<void> clearSignature({
    required int visitId,
    required bool isTechnician,
    Database? dbOverride,
  }) async {
    if (isTechnician) {
      draft = draft.copyWith(clearTechnicianSignature: true);
    } else {
      draft = draft.copyWith(clearCustomerSignature: true);
    }
  }

  @override
  Future<EindbeoordelingDraft> resolveInitialDraft({
    required int visitId,
    required VisitContextSummary summary,
    String? notifierFuel,
    Database? dbOverride,
  }) async {
    final activeFuel = (notifierFuel != null && notifierFuel.isNotEmpty)
        ? notifierFuel
        : summary.fuelType;
    final visitDt = EindbeoordelingDraft.parseDate(summary.visitDate);
    final hasConclusions = draft.toestelWerkingGoed != null ||
        draft.toestelWerkingVeilig != null;

    if (!hasConclusions) {
      return draft.withAssessmentState(
        combustionPassed: summary.combustionPassed,
        safetyChecksPassed: summary.safetyChecksPassed,
        fuelType: activeFuel,
        visitDate: visitDt,
      );
    }
    if (draft.nextInspectionDate?.isEmpty ?? true) {
      return draft.copyWith(
        nextInspectionDate: EindbeoordelingDraft.calculateStatutoryNextDate(
          fuelType: activeFuel,
          fromDate: visitDt,
        ),
      );
    }
    return draft;
  }
}

void main() {
  Future<void> pumpTabScreen(
    WidgetTester tester, {
    required FakeEindbeoordelingRepository repo,
    VoidCallback? onComplete,
  }) async {
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
            onComplete: onComplete,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Slice 3.3 — Tab 7 (Eindbeoordeling & Handtekeningen) Widget Tests',
      () {
    testWidgets('Renders all four bento cards and complete button',
        (tester) async {
      final repo = FakeEindbeoordelingRepository();
      await pumpTabScreen(tester, repo: repo);

      expect(find.text(EindbeoordelingDictionary.cardTitleConclusie),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.cardTitleVolgendeControle),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.cardTitleGebreken),
          findsOneWidget);
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

    testWidgets(
        'Tapping Niet goed triggers the 3-month legal remediation banner',
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

    testWidgets(
        'Entering defect notes updates controller and persists to draft',
        (tester) async {
      final repo = FakeEindbeoordelingRepository();
      await pumpTabScreen(tester, repo: repo);

      final defectField = find.widgetWithText(
        TextField,
        EindbeoordelingDictionary.hintGebreken,
      );
      expect(defectField, findsOneWidget);
      await tester.enterText(
          defectField, 'Onvoldoende verluchting stooklokaal');
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.draft.defectsNotes,
          equals('Onvoldoende verluchting stooklokaal'));
    });

    testWidgets(
        'Tapping quick date chips updates next inspection date and allows deselect',
        (tester) async {
      final repo = FakeEindbeoordelingRepository();
      await pumpTabScreen(tester, repo: repo);

      // Initially pre-selected at +2 years (gas). Tapping +2 Jaar deselects it back to empty
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

      // Tapping +2 Jaar sets date to +2 years
      await tester.tap(find.text(EindbeoordelingDictionary.chipPlus2Years));
      await tester.pumpAndSettle();
      expect(repo.draft.nextInspectionDate, '25/10/2027');
    });

    testWidgets('Completing without conclusions displays info toast',
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

      expect(completed, isFalse);
      expect(
        find.text(EindbeoordelingDictionary.toastValidationMissingConclusions),
        findsOneWidget,
      );
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
      expect(find.text(EindbeoordelingDictionary.toastSaved), findsOneWidget);
    });

    testWidgets(
        'Reactive fuel switch from Stooktoestel via BoilerDraftNotifier updates statutory date',
        (tester) async {
      final repo = FakeEindbeoordelingRepository();
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

      // Initial statutory gas date: 2025-10-25 + 2 years = 25/10/2027
      expect(find.text('25/10/2027'), findsOneWidget);

      // Verify +3 Maanden button exists and tap it
      expect(find.text(EindbeoordelingDictionary.chipPlus3Months), findsOneWidget);
      await tester.tap(find.text(EindbeoordelingDictionary.chipPlus3Months));
      await tester.pumpAndSettle();

      // Tap Niet goed (fails) -> auto-switches to 3-month remediation date
      await tester.tap(find.text(EindbeoordelingDictionary.optNietGoed));
      await tester.pumpAndSettle();
      expect(find.text('25/01/2026'), findsOneWidget);
      expect(repo.draft.nextInspectionDate, '25/01/2026');

      // Tap Goed (transitions back to compliant) -> restores statutory 25/10/2027
      await tester.tap(find.text(EindbeoordelingDictionary.optGoed));
      await tester.pumpAndSettle();
      expect(find.text('25/10/2027'), findsOneWidget);
      expect(repo.draft.nextInspectionDate, '25/10/2027');

      // Manually tap +3 Maanden
      await tester.tap(find.text(EindbeoordelingDictionary.chipPlus3Months));
      await tester.pumpAndSettle();
      expect(find.text('25/01/2026'), findsOneWidget);

      // Tapping +3 Maanden again deselects to empty
      await tester.tap(find.text(EindbeoordelingDictionary.chipPlus3Months));
      await tester.pumpAndSettle();
      expect(find.text(EindbeoordelingDictionary.datePlaceholder), findsOneWidget);
      expect(repo.draft.nextInspectionDate, '');
    });

    testWidgets(
        'MeasurementAssessmentNotifier dynamically updates EindbeoordelingTab when combustion fails',
        (tester) async {
      final repo = FakeEindbeoordelingRepository();
      final assessmentNotifier = MeasurementAssessmentNotifier();
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
              assessmentNotifier: assessmentNotifier,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Goed is null/initialized, statutory date is 25/10/2027
      expect(find.text('25/10/2027'), findsOneWidget);

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
    });
  });
}
