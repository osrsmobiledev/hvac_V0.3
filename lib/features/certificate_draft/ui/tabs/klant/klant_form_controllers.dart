import 'package:flutter/material.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';

/// Holds and manages TextEditingControllers for Tab 4 (Klant & Installatieadres).
class KlantFormControllers {
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

  final locStreet = TextEditingController();
  final locHouseNumber = TextEditingController();
  final locBoxNumber = TextEditingController();
  final locPostalCode = TextEditingController();
  final locMunicipality = TextEditingController();

  String? vekaAdresId;
  String? vekaGebouwId;
  String? vekaGebouweenheidId;
  String vekaVerificationStatus = 'unverified';

  String? _vStreet;
  String? _vHouse;
  String? _vBox;
  String? _vPostcode;
  String? _vCity;
  bool? _vIsSame;

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
    vekaAdresId = location.adresId;
    vekaGebouwId = location.gebouwId;
    vekaGebouweenheidId = location.gebouweenheidId;
    vekaVerificationStatus = location.verificationStatus;

    if (location.verificationStatus != 'unverified' &&
        location.adresId != null) {
      _vStreet = location.street.trim().toLowerCase();
      _vHouse = location.houseNumber.trim().toLowerCase();
      _vBox = (location.boxNumber ?? '').trim().toLowerCase();
      _vPostcode = location.postalCode.trim().toLowerCase();
      _vCity = location.municipality.trim().toLowerCase();
      _vIsSame = null;
    } else {
      _resetVerification();
    }
  }

  void populateFromLookup(AddressMatch match, {bool isSameAsCustomer = false}) {
    if (isSameAsCustomer) {
      populateCustomerAddressOnly(match);
    } else {
      locStreet.text = match.straatNaam;
      locHouseNumber.text = match.huisNummer;
      locBoxNumber.text = match.busNummer ?? '';
      locPostalCode.text = match.postcode;
      locMunicipality.text = match.gemeenteNaam;
    }
    vekaAdresId = match.adresId;
    vekaGebouwId = match.gebouwId;
    vekaGebouweenheidId = match.gebouweenheidId;
    vekaVerificationStatus = match.verificationStatus;

    _vStreet = match.straatNaam.trim().toLowerCase();
    _vHouse = match.huisNummer.trim().toLowerCase();
    _vBox = (match.busNummer ?? '').trim().toLowerCase();
    _vPostcode = match.postcode.trim().toLowerCase();
    _vCity = match.gemeenteNaam.trim().toLowerCase();
    _vIsSame = isSameAsCustomer;
  }

  /// Fills the billing address while preserving the installation verification.
  void populateCustomerAddressOnly(AddressMatch match) {
    street.text = match.straatNaam;
    houseNumber.text = match.huisNummer;
    boxNumber.text = match.busNummer ?? '';
    postalCode.text = match.postcode;
    city.text = match.gemeenteNaam;
  }

  bool isCurrentAddressVerified({required bool isSameAsCustomer}) {
    if (vekaVerificationStatus == 'unverified' ||
        vekaAdresId == null ||
        _vStreet == null) {
      return false;
    }
    if (_vIsSame != null && _vIsSame != isSameAsCustomer) {
      return false;
    }
    final cStr =
        (isSameAsCustomer ? street.text : locStreet.text).trim().toLowerCase();
    final cNr = (isSameAsCustomer ? houseNumber.text : locHouseNumber.text)
        .trim()
        .toLowerCase();
    final cBox = (isSameAsCustomer ? boxNumber.text : locBoxNumber.text)
        .trim()
        .toLowerCase();
    final cZip = (isSameAsCustomer ? postalCode.text : locPostalCode.text)
        .trim()
        .toLowerCase();
    final cCity = (isSameAsCustomer ? city.text : locMunicipality.text)
        .trim()
        .toLowerCase();

    return cStr == _vStreet &&
        cNr == _vHouse &&
        cBox == _vBox &&
        cZip == _vPostcode &&
        cCity == _vCity;
  }

  void _resetVerification() {
    vekaAdresId = null;
    vekaGebouwId = null;
    vekaGebouweenheidId = null;
    vekaVerificationStatus = 'unverified';
    _vStreet = null;
    _vHouse = null;
    _vBox = null;
    _vPostcode = null;
    _vCity = null;
    _vIsSame = null;
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
    _resetVerification();
  }

  Customer toCustomer({int? id, DateTime? createdAt}) {
    final lName = lastName.text.trim();
    final cName = company.text.trim();
    return Customer(
      id: id,
      firstName: firstName.text.trim(),
      lastName: lName.isEmpty ? cName : lName,
      companyName: cName.isEmpty ? null : cName,
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

    final verified =
        isCurrentAddressVerified(isSameAsCustomer: isSameAsCustomer);

    return ServiceLocation(
      id: id,
      customerId: customerId,
      role: role,
      street: sStreet,
      houseNumber: sHouseNum,
      boxNumber: sBox.isEmpty ? null : sBox,
      postalCode: sPostcode,
      municipality: sCity,
      adresId: verified ? vekaAdresId : null,
      gebouwId: verified ? vekaGebouwId : null,
      gebouweenheidId: verified ? vekaGebouweenheidId : null,
      verificationStatus: verified ? vekaVerificationStatus : 'unverified',
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
