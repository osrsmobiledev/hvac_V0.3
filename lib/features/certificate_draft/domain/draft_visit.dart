/// Lightweight domain model representing an active draft visit.
///
/// Holds the primary setup fields edited on Tab 2 (Start), Tab 3 (Firma - Technicus)
/// & Tab 4 (Klant) and synchronized with the SQLite `maintenance_visits` table.
class DraftVisit {
  final int id;
  final String certificateType; // 'verbranding' | 'reiniging' | 'combined'
  final String activityType; // 'onderhoud' or 'eerste_ingebruikname'
  final String attestNumber;
  final String visitDate;
  final String startTime;
  final String endTime;
  final bool technicianRoleErkend;
  final bool technicianRoleSchoorsteenveger;
  final int? customerId;
  final int? serviceLocationId;
  final String? snapshotJson;
  final String? klantUndoJson;

  const DraftVisit({
    required this.id,
    this.certificateType = 'verbranding',
    required this.activityType,
    required this.attestNumber,
    required this.visitDate,
    this.startTime = '',
    this.endTime = '',
    this.technicianRoleErkend = true,
    this.technicianRoleSchoorsteenveger = false,
    this.customerId,
    this.serviceLocationId,
    this.snapshotJson,
    this.klantUndoJson,
  });

  /// Factory constructor to map an SQLite row into a [DraftVisit] entity.
  factory DraftVisit.fromMap(Map<String, dynamic> map) {
    return DraftVisit(
      id: map['id'] as int,
      certificateType: (map['certificate_type'] as String?) ?? 'verbranding',
      activityType: (map['activity_type'] as String?) ?? '',
      attestNumber: (map['attest_number'] as String?) ?? '',
      visitDate: (map['visit_date'] as String?) ?? '',
      startTime: (map['start_time'] as String?) ?? '',
      endTime: (map['end_time'] as String?) ?? '',
      technicianRoleErkend: (map['technician_role_erkend'] as int? ?? 1) == 1,
      technicianRoleSchoorsteenveger:
          (map['technician_role_schoorsteenveger'] as int? ?? 0) == 1,
      customerId: map['customer_id'] as int?,
      serviceLocationId: map['service_location_id'] as int?,
      snapshotJson: map['snapshot_json'] as String?,
      klantUndoJson: map['klant_undo_json'] as String?,
    );
  }

  /// Copies this instance with optional updated fields.
  DraftVisit copyWith({
    String? certificateType,
    String? activityType,
    String? attestNumber,
    String? visitDate,
    String? startTime,
    String? endTime,
    bool? technicianRoleErkend,
    bool? technicianRoleSchoorsteenveger,
    int? customerId,
    int? serviceLocationId,
    String? snapshotJson,
    String? klantUndoJson,
  }) {
    return DraftVisit(
      id: id,
      certificateType: certificateType ?? this.certificateType,
      activityType: activityType ?? this.activityType,
      attestNumber: attestNumber ?? this.attestNumber,
      visitDate: visitDate ?? this.visitDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      technicianRoleErkend: technicianRoleErkend ?? this.technicianRoleErkend,
      technicianRoleSchoorsteenveger:
          technicianRoleSchoorsteenveger ?? this.technicianRoleSchoorsteenveger,
      customerId: customerId ?? this.customerId,
      serviceLocationId: serviceLocationId ?? this.serviceLocationId,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      klantUndoJson: klantUndoJson ?? this.klantUndoJson,
    );
  }
}
