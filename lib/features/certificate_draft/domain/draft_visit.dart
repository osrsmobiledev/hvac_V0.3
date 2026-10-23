/// Lightweight domain model representing an active draft visit.
///
/// Holds the primary setup fields edited on Tab 2 (Start), Tab 3 (Firma - Technicus)
/// & Tab 4 (Klant) and synchronized with the SQLite `maintenance_visits` table.
class DraftVisit {
  final int id;
  final String activityType; // 'onderhoud' or 'eerste_ingebruikname'
  final String attestNumber;
  final String visitDate;
  final String startTime;
  final String endTime;
  final int? customerId;
  final int? serviceLocationId;

  const DraftVisit({
    required this.id,
    required this.activityType,
    required this.attestNumber,
    required this.visitDate,
    this.startTime = '',
    this.endTime = '',
    this.customerId,
    this.serviceLocationId,
  });

  /// Factory constructor to map an SQLite row into a [DraftVisit] entity.
  factory DraftVisit.fromMap(Map<String, dynamic> map) {
    return DraftVisit(
      id: map['id'] as int,
      activityType: (map['activity_type'] as String?) ?? 'onderhoud',
      attestNumber: (map['attest_number'] as String?) ?? '',
      visitDate: (map['visit_date'] as String?) ?? '',
      startTime: (map['start_time'] as String?) ?? '',
      endTime: (map['end_time'] as String?) ?? '',
      customerId: map['customer_id'] as int?,
      serviceLocationId: map['service_location_id'] as int?,
    );
  }

  /// Copies this instance with optional updated fields.
  DraftVisit copyWith({
    String? activityType,
    String? attestNumber,
    String? visitDate,
    String? startTime,
    String? endTime,
    int? customerId,
    int? serviceLocationId,
  }) {
    return DraftVisit(
      id: id,
      activityType: activityType ?? this.activityType,
      attestNumber: attestNumber ?? this.attestNumber,
      visitDate: visitDate ?? this.visitDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      customerId: customerId ?? this.customerId,
      serviceLocationId: serviceLocationId ?? this.serviceLocationId,
    );
  }
}
