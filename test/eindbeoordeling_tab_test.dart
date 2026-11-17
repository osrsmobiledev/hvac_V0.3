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

part 'eindbeoordeling_tab_completion_cases.dart';
part 'eindbeoordeling_tab_assessment_cases.dart';

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
    final hasConclusions =
        draft.toestelWerkingGoed != null || draft.toestelWerkingVeilig != null;

    if (!hasConclusions) {
      return draft.withAssessmentState(
        combustionPassed: summary.combustionPassed,
        safetyChecksPassed: summary.safetyChecksPassed,
        fuelType: activeFuel,
        visitDate: visitDt,
      );
    }
    if (draft.nextInspectionDate?.isEmpty ?? true) {
      if (activeFuel.isNotEmpty && draft.isGood && draft.isSafe) {
        return draft.copyWith(
          nextInspectionDate: EindbeoordelingDraft.calculateStatutoryNextDate(
            fuelType: activeFuel,
            fromDate: visitDt,
          ),
        );
      }
    }
    return draft;
  }
}

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

void main() {
  group('Slice 3.3 — Tab 7 (Eindbeoordeling & Handtekeningen) Widget Tests',
      () {
    _completionTests();
    _assessmentTests();
  });
}
