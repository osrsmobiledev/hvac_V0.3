// File: lib/features/certificate_draft/domain/eindbeoordeling_draft.dart
// Responsibility: Immutable domain entity representing Tab 7 (Eindbeoordeling & Handtekeningen).

import 'eindbeoordeling_date_calculator.dart';

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
    this.customerSignatureException,
  });

  final String? toestelWerkingGoed;
  final String? toestelWerkingVeilig;
  final String? nextInspectionDate;
  final String? defectsNotes;
  final String? generalRemarks;
  final String? technicianSignaturePath;
  final String? customerSignaturePath;
  final String? customerSignatureName;
  final String? customerSignatureException; // 'refused' | 'absent' | null

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

  /// True if customer signed or a statutory exception applies ('refused' | 'absent').
  bool get isCustomerSignatureComplete =>
      isCustomerSigned || customerSignatureException != null;

  static String? calculateStatutoryNextDate({
    required String fuelType,
    DateTime? fromDate,
  }) =>
      EindbeoordelingDateCalculator.calculateStatutoryNextDate(
        fuelType: fuelType,
        fromDate: fromDate,
      );

  static String calculateRemediationNextDate({DateTime? fromDate}) =>
      EindbeoordelingDateCalculator.calculateRemediationNextDate(
        fromDate: fromDate,
      );

  static String formatDateDmy(DateTime dt) =>
      EindbeoordelingDateCalculator.formatDateDmy(dt);

  static DateTime? parseDate(String? raw) =>
      EindbeoordelingDateCalculator.parseDate(raw);

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
    final nextDate = EindbeoordelingDateCalculator.resolveNextDate(
      willFail: newGoed == 'Niet goed' || newVeilig == 'Niet veilig',
      wasFailing: hasNegativeAssessment,
      isCompliant: newGoed == 'Goed' && newVeilig == 'Veilig',
      hasFuel: fuelType.trim().isNotEmpty,
      fuelType: fuelType,
      currentDate: nextInspectionDate,
      visitDate: visitDate,
    );

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
    final newGoed = combustionPassed == false
        ? 'Niet goed'
        : (combustionPassed == true ? 'Goed' : null);
    final newVeilig = safetyChecksPassed == false
        ? 'Niet veilig'
        : (safetyChecksPassed == true ? 'Veilig' : null);

    final nextDate = EindbeoordelingDateCalculator.resolveNextDate(
      willFail: newGoed == 'Niet goed' || newVeilig == 'Niet veilig',
      wasFailing: hasNegativeAssessment,
      isCompliant: newGoed == 'Goed' && newVeilig == 'Veilig',
      hasFuel: fuelType.trim().isNotEmpty,
      fuelType: fuelType,
      currentDate: nextInspectionDate,
      visitDate: visitDate,
    );

    return copyWith(
      toestelWerkingGoed: newGoed,
      clearToestelWerkingGoed: newGoed == null,
      toestelWerkingVeilig: newVeilig,
      clearToestelWerkingVeilig: newVeilig == null,
      nextInspectionDate: nextDate,
    );
  }

  static const Object _sentinel = Object();

  EindbeoordelingDraft copyWith({
    String? toestelWerkingGoed,
    String? toestelWerkingVeilig,
    String? nextInspectionDate,
    String? defectsNotes,
    String? generalRemarks,
    String? technicianSignaturePath,
    String? customerSignaturePath,
    String? customerSignatureName,
    Object? customerSignatureException = _sentinel,
    bool clearTechnicianSignature = false,
    bool clearCustomerSignature = false,
    bool clearToestelWerkingGoed = false,
    bool clearToestelWerkingVeilig = false,
    bool clearCustomerSignatureException = false,
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
      customerSignatureException: clearCustomerSignatureException
          ? null
          : (identical(customerSignatureException, _sentinel)
              ? this.customerSignatureException
              : customerSignatureException as String?),
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
      customerSignatureException:
          map['customer_signature_exception'] as String?,
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
      'customer_signature_exception': customerSignatureException,
    };
  }
}
