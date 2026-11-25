import 'archive_outcome.dart';

/// Pure outcome and snapshot helpers for [PdfArchivingCoordinator].
abstract final class PdfArchivingOutcomeHelper {
  static ArchiveOutcome failureOutcome(String error) => ArchiveOutcome(
        archiveSuccess: false,
        archivePath: '',
        errorMessage: error,
        copyTechnicianDefault: true,
        technicianEmail: '',
        snapshot: const {},
      );

  static ArchiveOutcome buildOutcome({
    required bool success,
    required String path,
    String? error,
    bool isDbRegFailure = false,
    Map<String, Object?> smtp = const {},
    Map<String, Object?> snapshot = const {},
  }) =>
      ArchiveOutcome(
        archiveSuccess: success,
        archivePath: path,
        isDatabaseRegistrationFailure: isDbRegFailure,
        errorMessage: error,
        copyTechnicianDefault:
            (smtp['email_copy_technician'] as int? ?? 1) == 1,
        technicianEmail: (smtp['email'] as String? ?? '').trim(),
        snapshot: snapshot,
      );

  /// Extracts attest number from a decoded snapshot map.
  static String attestNumberFromSnapshot(Map<String, Object?> snapshot) =>
      ((snapshot['visit'] as Map?)?['attest_number'] as String? ?? '').trim();
}
