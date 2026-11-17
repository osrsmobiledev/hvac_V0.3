import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';

/// Point-in-time snapshot of Tab 4 (Klant) state for cancel/undo rollbacks.
class KlantFormSnapshot {
  final Customer? customer;
  final ServiceLocation? location;
  final String role;
  final bool isSameAsCustomer;

  const KlantFormSnapshot({
    this.customer,
    this.location,
    required this.role,
    required this.isSameAsCustomer,
  });
}
