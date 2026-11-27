import 'package:sqflite/sqflite.dart';
import '../../certificate_draft/domain/reiniging_controls_draft.dart';

/// Immutable cleaning-specific data attached to [PdfVisitData] for
/// Reinigingsattest Vlaanderen A4 PDF export.
class PdfCleaningData {
  final String certificateType;
  final bool technicianRoleErkend;
  final bool technicianRoleSchoorsteenveger;
  final ReinigingControlsDraft controls;
  final String remedialMeasuresNotes;
  final String nextChimneyInspectionDate;

  const PdfCleaningData({
    this.certificateType = 'verbranding',
    this.technicianRoleErkend = true,
    this.technicianRoleSchoorsteenveger = false,
    this.controls = const ReinigingControlsDraft(),
    this.remedialMeasuresNotes = '',
    this.nextChimneyInspectionDate = '',
  });

  /// Loads the `reiniging_controls` row for [visitId] from SQLite, returning an
  /// empty map when no row exists (e.g. legacy `verbranding` visits).
  static Future<Map<String, Object?>> loadRow(
    DatabaseExecutor db,
    int visitId,
  ) async {
    if (visitId <= 0) return const {};
    final rows = await db.query(
      'reiniging_controls',
      where: 'visit_id = ?',
      whereArgs: [visitId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : const {};
  }

  /// Maps raw `maintenance_visits` and `reiniging_controls` rows into a
  /// validated [PdfCleaningData] instance, pruning `allOtherText` when
  /// `allOtherChecked` is false.
  factory PdfCleaningData.fromRows({
    required Map<String, Object?> visit,
    Map<String, Object?> reinigingRow = const {},
  }) {
    final certType = (visit['certificate_type'] as String? ?? 'verbranding')
        .trim()
        .toLowerCase();
    final erkendRaw = visit['technician_role_erkend'] as int?;
    final vegerRaw = visit['technician_role_schoorsteenveger'] as int?;
    final controls = reinigingRow.isEmpty
        ? const ReinigingControlsDraft()
        : ReinigingControlsDraft.fromMap(reinigingRow);

    return PdfCleaningData(
      certificateType: certType.isEmpty ? 'verbranding' : certType,
      technicianRoleErkend: erkendRaw == null ? true : erkendRaw == 1,
      technicianRoleSchoorsteenveger: vegerRaw == 1,
      controls: controls,
      remedialMeasuresNotes:
          (visit['remedial_measures_notes'] as String? ?? '').trim(),
      nextChimneyInspectionDate:
          (visit['next_chimney_inspection_date'] as String? ?? '').trim(),
    );
  }
}
