/// Parameters resolved from the frozen snapshot for a recipient confirmation.
class RecipientConfirmation {
  final bool sendToCustomer;
  final String customerEmail;
  final String customerName;
  final bool sendToTechnician;
  final String technicianEmail;

  const RecipientConfirmation({
    required this.sendToCustomer,
    required this.customerEmail,
    required this.customerName,
    required this.sendToTechnician,
    required this.technicianEmail,
  });
}

/// Action chosen by the technician in the recipient confirmation dialog.
enum RecipientAction {
  queue,
  skip,
  cancel,
}

/// Result returned by the recipient confirmation dialog.
class RecipientDialogResult {
  final RecipientAction action;
  final RecipientConfirmation? confirmation;

  const RecipientDialogResult.queue(RecipientConfirmation this.confirmation)
      : action = RecipientAction.queue;

  const RecipientDialogResult.skip()
      : action = RecipientAction.skip,
        confirmation = null;

  const RecipientDialogResult.cancel()
      : action = RecipientAction.cancel,
        confirmation = null;

  bool get isQueue => action == RecipientAction.queue;
  bool get isSkip => action == RecipientAction.skip;
  bool get isCancel => action == RecipientAction.cancel;
}
