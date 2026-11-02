// File: lib/features/certificate_draft/domain/eindbeoordeling_draft.dart
// Responsibility: Immutable domain entity representing Tab 7 (Eindbeoordeling & Handtekeningen).

class EindbeoordelingDraft {
  const EindbeoordelingDraft({
    this.toestelWerkingGoed,
    this.toestelWerkingVeilig,
    this.nextInspectionDate,
    this.defectsNotes,
    this.generalRemarks,
    this.technicianSignaturePath,
    this.customerSignaturePath,
    this.customerSignatureName,
  });

  final String? toestelWerkingGoed;
  final String? toestelWerkingVeilig;
  final String? nextInspectionDate;
  final String? defectsNotes;
  final String? generalRemarks;
  final String? technicianSignaturePath;
  final String? customerSignaturePath;
  final String? customerSignatureName;

  bool get isGood => toestelWerkingGoed == 'Goed';
  bool get isSafe => toestelWerkingVeilig == 'Veilig';

  /// Returns true if either conclusion is marked as negative/failing.
  bool get hasNegativeAssessment =>
      toestelWerkingGoed == 'Niet goed' ||
      toestelWerkingVeilig == 'Niet veilig';

  bool get isTechnicianSigned =>
      technicianSignaturePath != null &&
      technicianSignaturePath!.trim().isNotEmpty;

  bool get isCustomerSigned =>
      customerSignaturePath != null && customerSignaturePath!.trim().isNotEmpty;

  /// Calculates statutory next inspection date per Flemish regulations:
  /// - Gas: +2 years from inspection date
  /// - Liquid (Stookolie) & Solid: +1 year from inspection date
  static String calculateStatutoryNextDate({
    required String fuelType,
    DateTime? fromDate,
  }) {
    final base = fromDate ?? DateTime.now();
    final isGas = fuelType.toLowerCase().contains('gas');
    final yearsToAdd = isGas ? 2 : 1;
    final nextDate = DateTime(base.year + yearsToAdd, base.month, base.day);
    return formatDateDmy(nextDate);
  }

  /// Calculates the statutory 3-month remediation deadline date
  /// (Art. 6 Vlaams Stooktoestellenbesluit for non-compliant boilers).
  static String calculateRemediationNextDate({DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final nextDate = DateTime(base.year, base.month + 3, base.day);
    return formatDateDmy(nextDate);
  }

  /// Returns a copy of the draft with updated conclusions and reactive
  /// statutory interval recalculation (3 months for failing, statutory for compliant).
  EindbeoordelingDraft withUpdatedConclusions({
    String? goed,
    String? veilig,
    required bool isGoed,
    required String fuelType,
    DateTime? visitDate,
  }) {
    final newGoed = isGoed ? goed : toestelWerkingGoed;
    final newVeilig = !isGoed ? veilig : toestelWerkingVeilig;
    final willFail = newGoed == 'Niet goed' || newVeilig == 'Niet veilig';
    final wasFailing = hasNegativeAssessment;

    var nextDate = nextInspectionDate;
    if (willFail && !wasFailing) {
      nextDate = calculateRemediationNextDate(fromDate: visitDate);
    } else if (!willFail && wasFailing) {
      nextDate = calculateStatutoryNextDate(
        fuelType: fuelType,
        fromDate: visitDate,
      );
    }

    return copyWith(
      toestelWerkingGoed: newGoed,
      clearToestelWerkingGoed: newGoed == null,
      toestelWerkingVeilig: newVeilig,
      clearToestelWerkingVeilig: newVeilig == null,
      nextInspectionDate: nextDate,
    );
  }

  /// Returns a copy of the draft with smart defaults derived from Tab 6 (Meting)
  /// compliance assessment (combustion verdict and safety checks).
  EindbeoordelingDraft withAssessmentState({
    bool? combustionPassed,
    bool? safetyChecksPassed,
    required String fuelType,
    DateTime? visitDate,
  }) {
    String? newGoed = toestelWerkingGoed;
    String? newVeilig = toestelWerkingVeilig;

    // 1. Proef II combustion verdict maps to 'Het stooktoestel werkt'
    if (combustionPassed == false) {
      newGoed = 'Niet goed';
    } else if (combustionPassed == true) {
      newGoed = 'Goed';
    }

    // 2. Safety checks verdict maps to 'Veilige staat van werking'
    if (safetyChecksPassed == false) {
      newVeilig = 'Niet veilig';
    } else if (safetyChecksPassed == true) {
      newVeilig = 'Veilig';
    }

    // 3. 3-Month statutory rule vs standard statutory term
    final willFail = newGoed == 'Niet goed' || newVeilig == 'Niet veilig';
    final wasFailing = hasNegativeAssessment;

    var nextDate = nextInspectionDate;
    if (willFail && (!wasFailing || nextDate == null || nextDate.isEmpty)) {
      nextDate = calculateRemediationNextDate(fromDate: visitDate);
    } else if (!willFail && wasFailing) {
      nextDate = calculateStatutoryNextDate(
        fuelType: fuelType,
        fromDate: visitDate,
      );
    } else if (nextDate == null || nextDate.isEmpty) {
      nextDate = willFail
          ? calculateRemediationNextDate(fromDate: visitDate)
          : calculateStatutoryNextDate(
              fuelType: fuelType,
              fromDate: visitDate,
            );
    }

    return copyWith(
      toestelWerkingGoed: newGoed,
      clearToestelWerkingGoed: newGoed == null,
      toestelWerkingVeilig: newVeilig,
      clearToestelWerkingVeilig: newVeilig == null,
      nextInspectionDate: nextDate,
    );
  }

  /// Formats a DateTime to standard Flemish DD/MM/YYYY.
  static String formatDateDmy(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return '$day/$month/$year';
  }

  /// Parses standard ISO YYYY-MM-DD or DD/MM/YYYY into DateTime.
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(RegExp(r'[-/]'));
    if (parts.length != 3) return null;
    if (parts[0].length == 4) {
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? 1;
      final d = int.tryParse(parts[2]) ?? 1;
      return DateTime(y, m, d);
    } else {
      final d = int.tryParse(parts[0]) ?? 1;
      final m = int.tryParse(parts[1]) ?? 1;
      final y = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(y, m, d);
    }
  }

  EindbeoordelingDraft copyWith({
    String? toestelWerkingGoed,
    String? toestelWerkingVeilig,
    String? nextInspectionDate,
    String? defectsNotes,
    String? generalRemarks,
    String? technicianSignaturePath,
    String? customerSignaturePath,
    String? customerSignatureName,
    bool clearTechnicianSignature = false,
    bool clearCustomerSignature = false,
    bool clearToestelWerkingGoed = false,
    bool clearToestelWerkingVeilig = false,
  }) {
    return EindbeoordelingDraft(
      toestelWerkingGoed: clearToestelWerkingGoed
          ? null
          : (toestelWerkingGoed ?? this.toestelWerkingGoed),
      toestelWerkingVeilig: clearToestelWerkingVeilig
          ? null
          : (toestelWerkingVeilig ?? this.toestelWerkingVeilig),
      nextInspectionDate: nextInspectionDate ?? this.nextInspectionDate,
      defectsNotes: defectsNotes ?? this.defectsNotes,
      generalRemarks: generalRemarks ?? this.generalRemarks,
      technicianSignaturePath: clearTechnicianSignature
          ? null
          : (technicianSignaturePath ?? this.technicianSignaturePath),
      customerSignaturePath: clearCustomerSignature
          ? null
          : (customerSignaturePath ?? this.customerSignaturePath),
      customerSignatureName:
          customerSignatureName ?? this.customerSignatureName,
    );
  }

  factory EindbeoordelingDraft.fromMap(Map<String, dynamic> map) {
    return EindbeoordelingDraft(
      toestelWerkingGoed: map['toestel_werking_goed'] as String?,
      toestelWerkingVeilig: map['toestel_werking_veilig'] as String?,
      nextInspectionDate: map['next_inspection_date'] as String?,
      defectsNotes: map['defects_notes'] as String?,
      generalRemarks: map['general_remarks'] as String?,
      technicianSignaturePath: map['technician_signature_path'] as String?,
      customerSignaturePath: map['customer_signature_path'] as String?,
      customerSignatureName: map['customer_signature_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toestel_werking_goed': toestelWerkingGoed,
      'toestel_werking_veilig': toestelWerkingVeilig,
      'next_inspection_date': nextInspectionDate,
      'defects_notes': defectsNotes,
      'general_remarks': generalRemarks,
      'technician_signature_path': technicianSignaturePath,
      'customer_signature_path': customerSignaturePath,
      'customer_signature_name': customerSignatureName,
    };
  }
}
