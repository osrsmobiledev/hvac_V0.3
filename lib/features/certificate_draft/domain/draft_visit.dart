/// Lightweight domain model representing an active draft visit.
///
/// Holds the primary setup fields edited on Tab 2 (Start)
/// and synchronized with the SQLite `maintenance_visits` table.
class DraftVisit {
  final int id;
  final String activityType; // 'onderhoud' or 'eerste_ingebruikname'
  final String attestNumber;
  final String visitDate;

  const DraftVisit({
    required this.id,
    required this.activityType,
    required this.attestNumber,
    required this.visitDate,
  });

  /// Factory constructor to map an SQLite row into a [DraftVisit] entity.
  factory DraftVisit.fromMap(Map<String, dynamic> map) {
    return DraftVisit(
      id: map['id'] as int,
      activityType: (map['activity_type'] as String?) ?? 'onderhoud',
      attestNumber: (map['attest_number'] as String?) ?? '',
      visitDate: (map['visit_date'] as String?) ?? '',
    );
  }

  /// Copies this instance with optional updated fields.
  DraftVisit copyWith({
    String? activityType,
    String? attestNumber,
    String? visitDate,
  }) {
    return DraftVisit(
      id: id,
      activityType: activityType ?? this.activityType,
      attestNumber: attestNumber ?? this.attestNumber,
      visitDate: visitDate ?? this.visitDate,
    );
  }
}
