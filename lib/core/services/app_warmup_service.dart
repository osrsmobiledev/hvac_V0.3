// File: lib/core/services/app_warmup_service.dart
// Responsibility: Core service that pre-warms SQLite database, active draft, and all tab models into RAM.

import 'package:flutter/foundation.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/boiler_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/measurement_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/operating_conditions_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';

/// Result snapshot returned when core engine warmup completes.
class WarmupResult {
  final DraftVisit? activeDraft;
  final TechnicianProfile? profile;
  final BoilerDraft? activeBoiler;
  final OperatingConditionsDraft? operatingConditions;
  final Map<String, MeasurementSlotDraft>? measurementSlots;
  final MeasurementSlotDraft? tab1RawMeasurement;
  final EindbeoordelingDraft? eindbeoordeling;
  final Duration elapsed;

  const WarmupResult({
    this.activeDraft,
    this.profile,
    this.activeBoiler,
    this.operatingConditions,
    this.measurementSlots,
    this.tab1RawMeasurement,
    this.eindbeoordeling,
    required this.elapsed,
  });
}

/// Singleton coordinator that performs true asynchronous warm-up of core services.
///
/// Prevents UI freezes on first user swipe by ensuring SQLite tables, active draft,
/// boiler, measurements, and assessment models are already hot in RAM before the main screen presents.
class AppWarmupService {
  AppWarmupService._();
  static final AppWarmupService instance = AppWarmupService._();

  bool _isWarmedUp = false;
  WarmupResult? _cachedResult;

  bool get isWarmedUp => _isWarmedUp;
  WarmupResult? get cachedResult => _cachedResult;

  /// Performs true asynchronous warm-up of the database, active draft, and all tab models.
  Future<WarmupResult> warmup({
    AppDatabase? databaseOverride,
    DraftRepository? draftRepoOverride,
    TechnicianProfileRepository? profileRepoOverride,
  }) async {
    if (_isWarmedUp && _cachedResult != null) {
      return _cachedResult!;
    }

    final stopwatch = Stopwatch()..start();
    DraftVisit? draft;
    TechnicianProfile? profile;
    BoilerDraft? boiler;
    OperatingConditionsDraft? operatingConditions;
    Map<String, MeasurementSlotDraft>? measurementSlots;
    MeasurementSlotDraft? tab1Raw;
    EindbeoordelingDraft? eindbeoordeling;

    try {
      final db = databaseOverride ?? AppDatabase.instance;
      await db.database;

      final draftRepo = draftRepoOverride ?? DraftRepository(appDatabase: db);
      final profileRepo =
          profileRepoOverride ?? TechnicianProfileRepository(appDatabase: db);

      // Pre-fetch draft visit and technician profile in parallel
      final results = await Future.wait([
        draftRepo.getOrCreateActiveDraft(),
        profileRepo.getProfile(),
      ]);

      draft = results[0] as DraftVisit;
      profile = results[1] as TechnicianProfile;

      // Warm up and cache all workflow models into RAM concurrently
      if (draft.id > 0) {
        final measurementRepo = MeasurementDraftRepository(dbProvider: db);
        final tabResults = await Future.wait([
          BoilerDraftRepository(appDatabase: db).getOrCreateActiveBoiler(),
          measurementRepo.loadOperatingConditions(draft.id),
          measurementRepo.loadMeasurementSlots(draft.id),
          measurementRepo.loadTab1RawMeasurement(draft.id),
          EindbeoordelingRepository(appDatabase: db)
              .loadDraft(visitId: draft.id),
        ]);

        boiler = tabResults[0] as BoilerDraft?;
        operatingConditions = tabResults[1] as OperatingConditionsDraft?;
        measurementSlots = tabResults[2] as Map<String, MeasurementSlotDraft>?;
        tab1Raw = tabResults[3] as MeasurementSlotDraft?;
        eindbeoordeling = tabResults[4] as EindbeoordelingDraft?;
      }
    } catch (e, stack) {
      debugPrint('[AppWarmupService] warmup error: $e\n$stack');
    } finally {
      stopwatch.stop();
    }

    _isWarmedUp = true;
    _cachedResult = WarmupResult(
      activeDraft: draft,
      profile: profile,
      activeBoiler: boiler,
      operatingConditions: operatingConditions,
      measurementSlots: measurementSlots,
      tab1RawMeasurement: tab1Raw,
      eindbeoordeling: eindbeoordeling,
      elapsed: stopwatch.elapsed,
    );
    return _cachedResult!;
  }

  @visibleForTesting
  void resetForTesting() {
    _isWarmedUp = false;
    _cachedResult = null;
  }
}
