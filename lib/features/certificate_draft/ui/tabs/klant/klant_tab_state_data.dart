import '../../../../customers_installations/domain/customer.dart';
import '../../../../customers_installations/domain/service_location.dart';
import 'klant_form_controllers.dart';

/// Mutable state model backing the Klant & Installatieadres tab.
class KlantTabStateData {
  Customer? activeCustomer;
  ServiceLocation? activeLocation;
  KlantFormSnapshot? snapshot;
  String role = 'owner';
  bool isSameAsCustomer = true;
  bool isEditing = false;
  bool isLoading = true;
  int? draftVisitId;

  bool hasCustomer(KlantFormControllers c) =>
      activeCustomer != null ||
      c.lastName.text.trim().isNotEmpty ||
      c.company.text.trim().isNotEmpty;

  void applyLocation(
    ServiceLocation loc,
    KlantFormControllers c, [
    String? street,
    String? nr,
  ]) {
    activeLocation = loc;
    role = loc.role;
    isSameAsCustomer = !(loc.street != (street ?? c.street.text) ||
        loc.houseNumber != (nr ?? c.houseNumber.text));
    c.populateLocation(loc);
  }

  void takeSnapshot() {
    snapshot = KlantFormSnapshot(
      customer: activeCustomer,
      location: activeLocation,
      role: role,
      isSameAsCustomer: isSameAsCustomer,
    );
  }

  void restoreSnapshot(KlantFormControllers c) {
    activeCustomer = snapshot?.customer;
    activeLocation = snapshot?.location;
    role = snapshot?.role ?? 'owner';
    isSameAsCustomer = snapshot?.isSameAsCustomer ?? true;
    snapshot?.restoreInto(c);
  }

  void clear(KlantFormControllers c) {
    activeCustomer = null;
    activeLocation = null;
    c.clearAll();
    role = 'owner';
    isSameAsCustomer = true;
  }
}
