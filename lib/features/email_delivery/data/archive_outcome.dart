/// Result from [PdfArchivingCoordinator.archiveAndUpdateStatus].
class ArchiveOutcome {
  final bool archiveSuccess;
  final String archivePath;
  final String? errorMessage;

  /// True when the PDF was safely created on disk, but updating SQLite failed.
  final bool isDatabaseRegistrationFailure;

  /// Email settings needed to build the recipient dialog.
  final bool copyTechnicianDefault;
  final String technicianEmail;

  /// The frozen snapshot decoded for the recipient dialog.
  final Map<String, Object?> snapshot;

  const ArchiveOutcome({
    required this.archiveSuccess,
    required this.archivePath,
    required this.copyTechnicianDefault,
    required this.technicianEmail,
    required this.snapshot,
    this.isDatabaseRegistrationFailure = false,
    this.errorMessage,
  });
}
