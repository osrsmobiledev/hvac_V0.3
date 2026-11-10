import 'package:flutter/foundation.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/measurement_assessment_notifier.dart';

/// Helper responsible for loading and resolving the initial draft state for Tab 7.
abstract final class EindbeoordelingLoader {
  static Future<void> load({
    required int visitId,
    required EindbeoordelingRepository repository,
    required BoilerDraftNotifier? boilerNotifier,
    required MeasurementAssessmentNotifier? assessmentNotifier,
    required void Function(EindbeoordelingDraft draft, String fuel, String date)
        onLoaded,
  }) async {
    final cached = AppWarmupService.instance.cachedResult;
    if (cached?.eindbeoordeling != null) {
      final nFuel = boilerNotifier?.draft.fuelCategory;
      final fuel = (nFuel != null && nFuel.isNotEmpty)
          ? nFuel
          : (cached!.activeBoiler?.fuelCategory ?? '');
      onLoaded(
        resolveDraftWithAssessment(
          cached!.eindbeoordeling!,
          fuel,
          cached.activeDraft?.visitDate ?? '',
          assessmentNotifier,
        ),
        fuel,
        cached.activeDraft?.visitDate ?? '',
      );
      return;
    }

    try {
      final summary = await repository.loadVisitContext(visitId: visitId);
      final draft = await repository.resolveInitialDraft(
        visitId: visitId,
        summary: summary,
        notifierFuel: boilerNotifier?.draft.fuelCategory,
      );

      final nFuel = boilerNotifier?.draft.fuelCategory;
      final fuel =
          (nFuel != null && nFuel.isNotEmpty) ? nFuel : summary.fuelType;
      onLoaded(
        resolveDraftWithAssessment(
          draft,
          fuel,
          summary.visitDate,
          assessmentNotifier,
        ),
        fuel,
        summary.visitDate,
      );
    } catch (e, stack) {
      debugPrint('[EindbeoordelingLoader] load error: $e\n$stack');
    }
  }

  static EindbeoordelingDraft resolveDraftWithAssessment(
    EindbeoordelingDraft draft,
    String fuel,
    String date,
    MeasurementAssessmentNotifier? assessmentNotifier,
  ) {
    final assessment = assessmentNotifier?.state;
    if (draft.toestelWerkingGoed == null &&
        draft.toestelWerkingVeilig == null &&
        assessment != null &&
        (assessment.combustionPassed != null ||
            assessment.safetyChecksPassed != null)) {
      return draft.withAssessmentState(
        combustionPassed: assessment.combustionPassed,
        safetyChecksPassed: assessment.safetyChecksPassed,
        fuelType: fuel,
        visitDate: EindbeoordelingDraft.parseDate(date),
      );
    }
    return draft;
  }
}
