// File: lib/features/certificate_draft/ui/measurement_assessment_notifier.dart
// Responsibility: In-memory reactive state holder linking Tab 6 (Meting) compliance to Tab 7 (Eindbeoordeling).

import 'package:flutter/foundation.dart';

/// Immutable snapshot of Tab 6 (Meting) combustion and safety compliance.
@immutable
class MeasurementAssessmentState {
  /// Whether the decisive combustion measurements (Proef II Eindmeting) passed:
  /// true = all OK, false = 1 or more NOK (CO > 150 mg/kWh, Hi < norm, roet > 1, oliespoor), null = unmeasured.
  final bool? combustionPassed;

  /// Whether the statutorily required boiler-room & flue safety checks passed:
  /// true = all applicable OK, false = 1 or more Niet OK, null = unselected.
  final bool? safetyChecksPassed;

  const MeasurementAssessmentState({
    this.combustionPassed,
    this.safetyChecksPassed,
  });

  /// True if any evaluated combustion value or safety check has failed.
  bool get hasAnyFailure =>
      combustionPassed == false || safetyChecksPassed == false;

  /// True if both combustion and safety checks have been evaluated and fully passed.
  bool get isFullyCompliant =>
      combustionPassed == true && safetyChecksPassed == true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementAssessmentState &&
          other.combustionPassed == combustionPassed &&
          other.safetyChecksPassed == safetyChecksPassed;

  @override
  int get hashCode => Object.hash(combustionPassed, safetyChecksPassed);
}

/// Reactive ChangeNotifier coordinator linking Tab 6 (Meting) and Tab 7 (Eindbeoordeling).
class MeasurementAssessmentNotifier extends ChangeNotifier {
  MeasurementAssessmentState _state = const MeasurementAssessmentState();

  MeasurementAssessmentState get state => _state;

  void updateAssessment({bool? combustionPassed, bool? safetyChecksPassed}) {
    final next = MeasurementAssessmentState(
      combustionPassed: combustionPassed,
      safetyChecksPassed: safetyChecksPassed,
    );
    if (_state != next) {
      _state = next;
      notifyListeners();
    }
  }
}
