import 'package:flutter/material.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';

/// Holds and manages TextEditingControllers for Tab 4 (Klant & Installatieadres).
class KlantFormControllers {
  // Customer Controllers
  final company = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final street = TextEditingController();
  final houseNumber = TextEditingController();
  final boxNumber = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  // Location Controllers
  final locStreet = TextEditingController();
  final locHouseNumber = TextEditingController();
  final locBoxNumber = TextEditingController();
  final locPostalCode = TextEditingController();
  final locMunicipality = TextEditingController();

  void populateCustomer(Customer customer) {
    company.text = customer.companyName ?? '';
    firstName.text = customer.firstName ?? '';
    lastName.text = customer.lastName;
    street.text = customer.street ?? '';
    houseNumber.text = customer.houseNumber ?? '';
    boxNumber.text = customer.boxNumber ?? '';
    postalCode.text = customer.postalCode ?? '';
    city.text = customer.city ?? '';
    phone.text = BelgianFormatters.stripPhonePrefix(customer.phone ?? '');
    email.text = customer.email ?? '';
  }

  void populateLocation(ServiceLocation location) {
    locStreet.text = location.street;
    locHouseNumber.text = location.houseNumber;
    locBoxNumber.text = location.boxNumber ?? '';
    locPostalCode.text = location.postalCode;
    locMunicipality.text = location.municipality;
  }

  void clearAll() {
    company.clear();
    firstName.clear();
    lastName.clear();
    street.clear();
    houseNumber.clear();
    boxNumber.clear();
    postalCode.clear();
    city.clear();
    phone.clear();
    email.clear();
    locStreet.clear();
    locHouseNumber.clear();
    locBoxNumber.clear();
    locPostalCode.clear();
    locMunicipality.clear();
  }

  /// Builds a [Customer] domain object from current form values.
  Customer toCustomer({int? id, DateTime? createdAt}) {
    final lastNameVal = lastName.text.trim();
    final companyVal = company.text.trim();
    final effectiveLastName = lastNameVal.isEmpty ? companyVal : lastNameVal;

    return Customer(
      id: id,
      firstName: firstName.text.trim(),
      lastName: effectiveLastName,
      companyName: companyVal.isEmpty ? null : companyVal,
      street: street.text.trim(),
      houseNumber: houseNumber.text.trim(),
      boxNumber: boxNumber.text.trim(),
      postalCode: postalCode.text.trim(),
      city: city.text.trim(),
      phone: BelgianFormatters.normalizePhone(phone.text),
      email: email.text.trim(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Builds a [ServiceLocation] domain object from current form values.
  ServiceLocation toLocation({
    int? id,
    required int customerId,
    required String role,
    required bool isSameAsCustomer,
    DateTime? createdAt,
  }) {
    final sStreet =
        isSameAsCustomer ? street.text.trim() : locStreet.text.trim();
    final sHouseNum =
        isSameAsCustomer ? houseNumber.text.trim() : locHouseNumber.text.trim();
    final sBox =
        isSameAsCustomer ? boxNumber.text.trim() : locBoxNumber.text.trim();
    final sPostcode =
        isSameAsCustomer ? postalCode.text.trim() : locPostalCode.text.trim();
    final sCity =
        isSameAsCustomer ? city.text.trim() : locMunicipality.text.trim();

    return ServiceLocation(
      id: id,
      customerId: customerId,
      role: role,
      street: sStreet,
      houseNumber: sHouseNum,
      boxNumber: sBox.isEmpty ? null : sBox,
      postalCode: sPostcode,
      municipality: sCity,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    company.dispose();
    firstName.dispose();
    lastName.dispose();
    street.dispose();
    houseNumber.dispose();
    boxNumber.dispose();
    postalCode.dispose();
    city.dispose();
    phone.dispose();
    email.dispose();
    locStreet.dispose();
    locHouseNumber.dispose();
    locBoxNumber.dispose();
    locPostalCode.dispose();
    locMunicipality.dispose();
  }
}

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

  /// Restores controllers from this snapshot into [controllers].
  void restoreInto(KlantFormControllers controllers) {
    if (customer != null) {
      controllers.populateCustomer(customer!);
    } else {
      controllers.clearAll();
    }
    if (location != null) {
      controllers.populateLocation(location!);
    }
  }
}
