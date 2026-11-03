// File: lib/features/certificate_draft/data/eindbeoordeling_repository.dart
// Responsibility: SQLite persistence layer for Tab 7 (Eindbeoordeling & Signatures).

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';

class VisitContextSummary {
  const VisitContextSummary({
    required this.fuelType,
    required this.visitDate,
    required this.customerName,
    this.combustionPassed,
    this.safetyChecksPassed,
  });

  final String fuelType;
  final String visitDate;
  final String customerName;
  final bool? combustionPassed;
  final bool? safetyChecksPassed;
}

class EindbeoordelingRepository {
  EindbeoordelingRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  /// Loads the saved Tab 7 draft for the given visit.
  Future<EindbeoordelingDraft> loadDraft({
    required int visitId,
    Database? dbOverride,
  }) async {
    try {
      final db = dbOverride ?? await _appDatabase.database;
      final results = await db.query(
        'maintenance_visits',
        columns: [
          'toestel_werking_goed',
          'toestel_werking_veilig',
          'next_inspection_date',
          'defects_notes',
          'general_remarks',
          'technician_signature_path',
          'customer_signature_path',
          'customer_signature_name',
        ],
        where: 'id = ?',
        whereArgs: [visitId],
        limit: 1,
      );

      if (results.isEmpty) {
        return const EindbeoordelingDraft();
      }
      return EindbeoordelingDraft.fromMap(results.first);
    } catch (e, stack) {
      debugPrint('[EindbeoordelingRepository] loadDraft error: $e\n$stack');
      return const EindbeoordelingDraft();
    }
  }

  /// Resolves the initial draft with smart defaults from visit context.
  Future<EindbeoordelingDraft> resolveInitialDraft({
    required int visitId,
    required VisitContextSummary summary,
    String? notifierFuel,
    Database? dbOverride,
  }) async {
    final loaded = await loadDraft(visitId: visitId, dbOverride: dbOverride);
    final activeFuel = (notifierFuel != null && notifierFuel.isNotEmpty)
        ? notifierFuel
        : summary.fuelType;
    final visitDt = EindbeoordelingDraft.parseDate(summary.visitDate);
    final hasConclusions = loaded.toestelWerkingGoed != null ||
        loaded.toestelWerkingVeilig != null;

    if (!hasConclusions) {
      return loaded.withAssessmentState(
        combustionPassed: summary.combustionPassed,
        safetyChecksPassed: summary.safetyChecksPassed,
        fuelType: activeFuel,
        visitDate: visitDt,
      );
    }
    if (loaded.nextInspectionDate?.isEmpty ?? true) {
      return loaded.copyWith(
        nextInspectionDate: EindbeoordelingDraft.calculateStatutoryNextDate(
          fuelType: activeFuel,
          fromDate: visitDt,
        ),
      );
    }
    return loaded;
  }

  /// Loads the context (fuel type, visit date, customer name) to provide smart defaults.
  Future<VisitContextSummary> loadVisitContext({
    required int visitId,
    Database? dbOverride,
  }) async {
    try {
      final db = dbOverride ?? await _appDatabase.database;
      final rows = await db.rawQuery(
        '''
        SELECT mv.visit_date, b.fuel_type, c.first_name, c.last_name, c.company_name,
               mv.verbrandingscontrole,
               mv.flue_pressure_ok, mv.ventilation_ok, mv.fuel_supply_tightness_ok,
               mv.flue_tightness_ok, mv.no_unwanted_condensation_ok, mv.no_oil_trace_ok,
               mv.rarely_polluting_smoke_ok
        FROM maintenance_visits mv
        LEFT JOIN boilers b ON mv.boiler_id = b.id
        LEFT JOIN customers c ON mv.customer_id = c.id
        WHERE mv.id = ?
        LIMIT 1
        ''',
        [visitId],
      );

      if (rows.isEmpty) {
        return const VisitContextSummary(
          fuelType: 'gas',
          visitDate: '',
          customerName: '',
        );
      }

      final row = rows.first;
      final fuel = (row['fuel_type'] as String?) ?? 'gas';
      final date = (row['visit_date'] as String?) ?? '';
      final firstName = (row['first_name'] as String?) ?? '';
      final lastName = (row['last_name'] as String?) ?? '';
      final company = (row['company_name'] as String?) ?? '';
      final fullName =
          [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      final customerName = fullName.isNotEmpty ? fullName : company;

      bool? combustionPassed;
      final vb = row['verbrandingscontrole'] as String?;
      if (vb == 'OK') combustionPassed = true;
      if (vb == 'NOK') combustionPassed = false;

      final safetyValues = [
        row['flue_pressure_ok'],
        row['ventilation_ok'],
        row['fuel_supply_tightness_ok'],
        row['flue_tightness_ok'],
        row['no_unwanted_condensation_ok'],
        row['no_oil_trace_ok'],
        row['rarely_polluting_smoke_ok'],
      ];
      bool? safetyChecksPassed;
      if (safetyValues.any((v) => v == 0)) {
        safetyChecksPassed = false;
      } else if (safetyValues.where((v) => v != null).isNotEmpty &&
          safetyValues.where((v) => v != null).every((v) => v == 1)) {
        safetyChecksPassed = true;
      }

      return VisitContextSummary(
        fuelType: fuel,
        visitDate: date,
        customerName: customerName,
        combustionPassed: combustionPassed,
        safetyChecksPassed: safetyChecksPassed,
      );
    } catch (e, stack) {
      debugPrint(
          '[EindbeoordelingRepository] loadVisitContext error: $e\n$stack');
      return const VisitContextSummary(
        fuelType: 'gas',
        visitDate: '',
        customerName: '',
      );
    }
  }

  /// Saves or updates the entire Eindbeoordeling draft.
  Future<void> updateDraft({
    required int visitId,
    required EindbeoordelingDraft draft,
    Database? dbOverride,
  }) async {
    try {
      final db = dbOverride ?? await _appDatabase.database;
      final map = draft.toMap();
      map['updated_at'] = DateTime.now().toIso8601String();

      await db.update(
        'maintenance_visits',
        map,
        where: 'id = ?',
        whereArgs: [visitId],
      );
    } catch (e, stack) {
      debugPrint('[EindbeoordelingRepository] updateDraft error: $e\n$stack');
    }
  }

  /// Clears either the technician or customer signature from SQLite.
  Future<void> clearSignature({
    required int visitId,
    required bool isTechnician,
    Database? dbOverride,
  }) async {
    try {
      final db = dbOverride ?? await _appDatabase.database;
      final column = isTechnician
          ? 'technician_signature_path'
          : 'customer_signature_path';

      await db.update(
        'maintenance_visits',
        {
          column: null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [visitId],
      );
    } catch (e, stack) {
      debugPrint(
          '[EindbeoordelingRepository] clearSignature error: $e\n$stack');
    }
  }
}
