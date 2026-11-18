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
