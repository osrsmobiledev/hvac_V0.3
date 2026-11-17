import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant_edit_session.dart';
import 'klant_form_controllers.dart';
import 'klant_form_snapshot.dart';

enum AddressLookupTarget { billing, shared, installation }

/// State for the Klant form and its pre-edit values.
class KlantTabStateData {
  Customer? activeCustomer;
  ServiceLocation? activeLocation;
  KlantFormSnapshot? snapshot;
  String role = 'owner';
  bool isSameAsCustomer = true;
  bool isEditing = false;
  bool isLoading = true;
  int? draftVisitId;

  void populateFromData(
    Customer? customer,
    ServiceLocation? location,
    KlantFormControllers controllers,
  ) {
    clear(controllers);
    activeCustomer = customer;
    if (customer != null) controllers.populateCustomer(customer);
    if (location != null) applyLocation(location, controllers);
    isLoading = false;
  }

  bool hasCustomer(KlantFormControllers controllers) =>
      activeCustomer != null ||
      controllers.lastName.text.trim().isNotEmpty ||
      controllers.company.text.trim().isNotEmpty;

  void applyLocation(
      ServiceLocation location, KlantFormControllers controllers) {
    activeLocation = location;
    role = location.role;
    isSameAsCustomer =
        _sameAddress(activeCustomer ?? controllers.toCustomer(), location);
    controllers.populateLocation(location);
  }

  static bool _sameAddress(Customer? customer, ServiceLocation? location) {
    if (location == null) return true;
    String normalized(String? value) => (value ?? '').trim().toLowerCase();
    return customer != null &&
        normalized(customer.street).isNotEmpty &&
        normalized(customer.street) == normalized(location.street) &&
        normalized(customer.houseNumber) == normalized(location.houseNumber) &&
        normalized(customer.boxNumber) == normalized(location.boxNumber) &&
        normalized(customer.postalCode) == normalized(location.postalCode) &&
        normalized(customer.city) == normalized(location.municipality);
  }

  void applyLookup(
    AddressLookupTarget target,
    AddressMatch match,
    KlantFormControllers controllers,
  ) {
    switch (target) {
      case AddressLookupTarget.billing:
        controllers.populateCustomerAddressOnly(match);
      case AddressLookupTarget.shared:
      case AddressLookupTarget.installation:
        controllers.populateFromLookup(
          match,
          isSameAsCustomer: target == AddressLookupTarget.shared,
        );
    }
  }

  void takeSnapshot() {
    snapshot = KlantFormSnapshot(
      customer: activeCustomer,
      location: activeLocation,
      role: role,
      isSameAsCustomer: isSameAsCustomer,
    );
  }

  /// Old undo records infer the address mode from their stored addresses.
  void resumeSession(KlantEditSession session) {
    snapshot = KlantFormSnapshot(
      customer: session.initialCustomer,
      location: session.initialLocation,
      role: session.initialLocation?.role ?? 'owner',
      isSameAsCustomer: session.initialSameAsCustomer ??
          _sameAddress(session.initialCustomer, session.initialLocation),
    );
    isSameAsCustomer = session.savedSameAsCustomer ?? isSameAsCustomer;
    isEditing = true;
  }

  void restoreSnapshot(KlantFormControllers controllers) {
    final original = snapshot;
    if (original == null) return;
    populateFromData(original.customer, original.location, controllers);
    role = original.role;
    isSameAsCustomer = original.isSameAsCustomer;
    snapshot = null;
  }

  void clear(KlantFormControllers controllers) {
    activeCustomer = null;
    activeLocation = null;
    controllers.clearAll();
    role = 'owner';
    isSameAsCustomer = true;
  }
}
