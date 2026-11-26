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
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';

/// Result snapshot returned when core engine warmup completes.
class WarmupResult {
  final DraftVisit? activeDraft;
  final TechnicianProfile? profile;
  final Customer? activeCustomer;
  final ServiceLocation? activeServiceLocation;
  final BoilerDraft? activeBoiler;
  final OperatingConditionsDraft? operatingConditions;
  final Map<String, MeasurementSlotDraft>? measurementSlots;
  final MeasurementSlotDraft? tab1RawMeasurement;
  final EindbeoordelingDraft? eindbeoordeling;
  final Duration elapsed;

  const WarmupResult({
    this.activeDraft,
    this.profile,
    this.activeCustomer,
    this.activeServiceLocation,
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
  Future<WarmupResult>? _inFlightWarmup;
  int _generation = 0;

  bool get isWarmedUp => _isWarmedUp;
  WarmupResult? get cachedResult => _cachedResult;

  /// Returns the cached active draft only when its [certificateType] matches,
  /// preventing cross-mode draft collision between Verbranding/Reiniging/Combined.
  DraftVisit? activeDraftFor(String certificateType) {
    final draft = _cachedResult?.activeDraft;
    if (draft == null || draft.certificateType != certificateType) return null;
    return draft;
  }

  /// Performs true asynchronous warm-up of the database, active draft, and all tab models.
  Future<WarmupResult> warmup({
    AppDatabase? databaseOverride,
    DraftRepository? draftRepoOverride,
    TechnicianProfileRepository? profileRepoOverride,
  }) async {
    if (_isWarmedUp && _cachedResult != null) {
      return _cachedResult!;
    }
    if (_inFlightWarmup != null) {
      return _inFlightWarmup!;
    }

    final runGeneration = _generation;
    final future = _runWarmup(
      runGeneration,
      databaseOverride: databaseOverride,
      draftRepoOverride: draftRepoOverride,
      profileRepoOverride: profileRepoOverride,
    );
    _inFlightWarmup = future;
    return future;
  }

  Future<WarmupResult> _runWarmup(
    int runGeneration, {
    AppDatabase? databaseOverride,
    DraftRepository? draftRepoOverride,
    TechnicianProfileRepository? profileRepoOverride,
  }) async {
    final stopwatch = Stopwatch()..start();
    var succeeded = false;
    DraftVisit? draft;
    TechnicianProfile? profile;
    Customer? customer;
    ServiceLocation? serviceLocation;
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

      draft = await draftRepo.getOrCreateActiveDraft();
      profile = await profileRepo.getProfile();

      // Sequentially load each tab model to eliminate SQLite connection lock contention
      if (draft.id > 0) {
        final activeDraft = draft;
        final measurementRepo = MeasurementDraftRepository(dbProvider: db);
        final customerRepo = CustomerRepository(db);

        boiler = await BoilerDraftRepository(appDatabase: db)
            .getOrCreateActiveBoiler();
        operatingConditions =
            await measurementRepo.loadOperatingConditions(activeDraft.id);
        measurementSlots =
            await measurementRepo.loadMeasurementSlots(activeDraft.id);
        tab1Raw = await measurementRepo.loadTab1RawMeasurement(activeDraft.id);
        eindbeoordeling = await EindbeoordelingRepository(appDatabase: db)
            .loadDraft(visitId: activeDraft.id);

        if (activeDraft.customerId != null) {
          customer =
              await customerRepo.getCustomerById(activeDraft.customerId!);
          if (activeDraft.serviceLocationId != null) {
            final locs = await customerRepo
                .getLocationsForCustomer(activeDraft.customerId!);
            serviceLocation = locs
                .where((l) => l.id == activeDraft.serviceLocationId)
                .firstOrNull;
          }
        }
      }
      succeeded = true;
    } catch (e, stack) {
      debugPrint('[AppWarmupService] warmup error: $e\n$stack');
    } finally {
      stopwatch.stop();
      if (runGeneration == _generation) {
        _inFlightWarmup = null;
      }
    }

    final result = WarmupResult(
      activeDraft: draft,
      profile: profile,
      activeCustomer: customer,
      activeServiceLocation: serviceLocation,
      activeBoiler: boiler,
      operatingConditions: operatingConditions,
      measurementSlots: measurementSlots,
      tab1RawMeasurement: tab1Raw,
      eindbeoordeling: eindbeoordeling,
      elapsed: stopwatch.elapsed,
    );

    // Only cache when warmup succeeded and was not invalidated mid-flight.
    if (succeeded && runGeneration == _generation) {
      _isWarmedUp = true;
      _cachedResult = result;
    }
    return result;
  }

  @visibleForTesting
  void resetForTesting() => invalidate();

  /// The next visit needs a fresh cache after a certificate is archived.
  void invalidate() {
    _generation++;
    _isWarmedUp = false;
    _cachedResult = null;
    _inFlightWarmup = null;
  }
}
