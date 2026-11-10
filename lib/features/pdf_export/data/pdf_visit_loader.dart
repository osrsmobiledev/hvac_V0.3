import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import 'pdf_visit_data.dart';
import 'pdf_data_mapper.dart';

/// Loads raw relational tables, flue gas captures, and signatures for a visit.
abstract final class PdfVisitLoader {
  /// Loads all visit details from SQLite database for [visitId].
  ///
  /// Falls back gracefully to default empty values for any missing row or table.
  static Future<PdfVisitData> loadVisitData(int visitId) async {
    try {
      final db = await AppDatabase.instance.database;

      // 1. Load Visit Draft Row
      Map<String, Object?> visit = {};
      if (visitId > 0) {
        final visitRows = await db.query(
          'maintenance_visits',
          where: 'id = ?',
          whereArgs: [visitId],
          limit: 1,
        );
        if (visitRows.isNotEmpty) visit = visitRows.first;
      }
      if (visit.isEmpty) {
        final fallbackRows = await db.query(
          'maintenance_visits',
          where: 'is_draft = 1',
          orderBy: 'id DESC',
          limit: 1,
        );
        if (fallbackRows.isNotEmpty) {
          visit = fallbackRows.first;
        } else {
          final anyRows = await db.query(
            'maintenance_visits',
            orderBy: 'id DESC',
            limit: 1,
          );
          if (anyRows.isNotEmpty) visit = anyRows.first;
        }
      }
      final resolvedVisitId = (visit['id'] as int?) ?? visitId;

      // 2. Load Singleton Technician Profile
      final profileRows = await db.query(
        'technician_profile',
        limit: 1,
      );
      final profile =
          profileRows.isNotEmpty ? profileRows.first : <String, Object?>{};

      // 3. Load Customer
      final int? customerId = visit['customer_id'] as int?;
      Map<String, Object?> customer = {};
      if (customerId != null) {
        final cRows = await db.query(
          'customers',
          where: 'id = ?',
          whereArgs: [customerId],
          limit: 1,
        );
        if (cRows.isNotEmpty) customer = cRows.first;
      }

      // 4. Load Service Location
      final int? locationId = visit['service_location_id'] as int?;
      Map<String, Object?> location = {};
      if (locationId != null) {
        final locRows = await db.query(
          'service_locations',
          where: 'id = ?',
          whereArgs: [locationId],
          limit: 1,
        );
        if (locRows.isNotEmpty) location = locRows.first;
      }

      // 5. Load Boiler Draft
      final int? boilerId = visit['boiler_id'] as int?;
      Map<String, Object?> boiler = {};
      if (boilerId != null) {
        final bRows = await db.query(
          'boilers',
          where: 'id = ?',
          whereArgs: [boilerId],
          limit: 1,
        );
        if (bRows.isNotEmpty) boiler = bRows.first;
      }

      // 6. Load Flue Gas Measurement Captures
      final captureRows = await db.query(
        'measurement_captures',
        where: 'visit_id = ?',
        whereArgs: [resolvedVisitId],
      );
      Map<String, Object?> slotInitial = {};
      Map<String, Object?> slotLow = {};
      Map<String, Object?> slotHigh = {};
      for (final row in captureRows) {
        final slot = (row['slot'] as String? ?? '').toLowerCase();
        if (slot == 'proef1' || slot == 'initial') {
          slotInitial = row;
        } else if (slot == 'proef2_laaglast' ||
            slot == 'final_low' ||
            slot == 'laaglast') {
          slotLow = row;
        } else if (slot == 'proef2_hooglast' ||
            slot == 'final_high' ||
            slot == 'hooglast') {
          slotHigh = row;
        }
      }

      // Fallback: If Proef I was not explicitly saved, read Tab 1 raw capture
      if (slotInitial.isEmpty) {
        for (final row in captureRows) {
          if ((row['slot'] as String? ?? '').toLowerCase() == 'tab1_raw') {
            slotInitial = row;
            break;
          }
        }
      }

      // 7. Load Signatures (supporting Base64 Data URI, raw Base64, and file paths)
      final techSigData = visit['technician_signature_path'] as String? ?? '';
      final custSigData = visit['customer_signature_path'] as String? ?? '';
      final techSigBytes = _resolveSignatureBytes(techSigData);
      final custSigBytes = _resolveSignatureBytes(custSigData);

      return PdfDataMapper.mapToPdfData(
        visit: visit,
        profile: profile,
        customer: customer,
        location: location,
        boiler: boiler,
        slotInitial: slotInitial,
        slotLow: slotLow,
        slotHigh: slotHigh,
        techSigBytes: techSigBytes,
        custSigBytes: custSigBytes,
      );
    } catch (e, stack) {
      debugPrint('[PdfVisitLoader] loadVisitData error: $e\n$stack');
      return const PdfVisitData();
    }
  }

  /// Safely resolves binary image bytes from data URI, raw base64, or disk file.
  static Uint8List? _resolveSignatureBytes(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();

    // 1. Data URI (data:image/png;base64,...)
    if (trimmed.startsWith('data:image/') && trimmed.contains('base64,')) {
      try {
        final base64Content = trimmed.substring(trimmed.indexOf('base64,') + 7);
        return base64Decode(base64Content);
      } catch (e) {
        debugPrint('[PdfVisitLoader] data URI decode error: $e');
      }
    }

    // 2. Raw Base64 string
    if (!trimmed.startsWith('/') &&
        !trimmed.startsWith('C:') &&
        !trimmed.startsWith('\\') &&
        trimmed.length > 50) {
      try {
        return base64Decode(trimmed);
      } catch (_) {}
    }

    // 3. File path on disk
    try {
      final file = File(trimmed);
      if (file.existsSync()) {
        return file.readAsBytesSync();
      }
    } catch (e) {
      debugPrint('[PdfVisitLoader] file read error: $e');
    }

    return null;
  }
}
