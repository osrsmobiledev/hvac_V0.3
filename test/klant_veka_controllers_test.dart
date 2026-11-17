import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_form_controllers.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_tab_state_data.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';

void main() {
  group('KlantFormControllers VEKA Integration Tests', () {
    late KlantFormControllers controllers;

    setUp(() => controllers = KlantFormControllers());
    tearDown(() => controllers.dispose());

    const testMatch = AddressMatch(
      adresId: '2447812',
      volledigAdres: 'Markt 1, 9000 Gent',
      straatNaam: 'Markt',
      huisNummer: '1',
      postcode: '9000',
      gemeenteNaam: 'Gent',
      gebouwId: '9400001',
      gebouweenheidId: '9400075',
    );

    test('populateFromLookup sets location fields and VEKA IDs', () {
      controllers.populateFromLookup(testMatch);
      expect(controllers.locStreet.text, 'Markt');
      expect(controllers.locHouseNumber.text, '1');
      expect(controllers.locPostalCode.text, '9000');
      expect(controllers.locMunicipality.text, 'Gent');
      expect(controllers.vekaAdresId, '2447812');
      expect(controllers.vekaGebouwId, '9400001');
      expect(controllers.vekaGebouweenheidId, '9400075');
      expect(controllers.vekaVerificationStatus, 'verified');
    });

    test(
        'populateFromLookup updates customer address when isSameAsCustomer is true',
        () {
      controllers.populateFromLookup(testMatch, isSameAsCustomer: true);
      expect(controllers.street.text, 'Markt');
      expect(controllers.houseNumber.text, '1');

      final loc = controllers.toLocation(
        customerId: 1,
        role: 'owner',
        isSameAsCustomer: true,
      );
      expect(loc.street, 'Markt');
      expect(loc.adresId, '2447812');
      expect(loc.verificationStatus, 'verified');
    });

    test(
        'Changing verified house number invalidates verification and clears VEKA IDs',
        () {
      controllers.populateFromLookup(testMatch, isSameAsCustomer: true);
      expect(
          controllers.isCurrentAddressVerified(isSameAsCustomer: true), isTrue);

      // Edit house number manually
      controllers.houseNumber.text = '2';

      expect(controllers.isCurrentAddressVerified(isSameAsCustomer: true),
          isFalse);
      final loc = controllers.toLocation(
        customerId: 1,
        role: 'owner',
        isSameAsCustomer: true,
      );
      expect(loc.houseNumber, '2');
      expect(loc.adresId, isNull);
      expect(loc.gebouwId, isNull);
      expect(loc.gebouweenheidId, isNull);
      expect(loc.verificationStatus, 'unverified');
    });

    test(
        'Switching from separate verified address back to customer address invalidates verification',
        () {
      controllers.street.text = 'Dorpstraat';
      controllers.houseNumber.text = '10';
      controllers.postalCode.text = '9000';
      controllers.city.text = 'Gent';

      // Verify separate installation address
      controllers.populateFromLookup(testMatch, isSameAsCustomer: false);
      expect(controllers.isCurrentAddressVerified(isSameAsCustomer: false),
          isTrue);

      // User unchecks separate address (isSameAsCustomer becomes true)
      expect(controllers.isCurrentAddressVerified(isSameAsCustomer: true),
          isFalse);
      final loc = controllers.toLocation(
        customerId: 1,
        role: 'owner',
        isSameAsCustomer: true,
      );
      expect(loc.street, 'Dorpstraat');
      expect(loc.adresId, isNull);
      expect(loc.verificationStatus, 'unverified');
    });

    test('Apartment with different bus numbers opens in separate address mode',
        () {
      final stateData = KlantTabStateData();
      controllers.street.text = 'Kerkstraat';
      controllers.houseNumber.text = '10';
      controllers.boxNumber.text = 'A';
      controllers.postalCode.text = '9000';
      controllers.city.text = 'Gent';

      final loc = ServiceLocation(
        id: 1,
        customerId: 1,
        street: 'Kerkstraat',
        houseNumber: '10',
        boxNumber: 'B',
        postalCode: '9000',
        municipality: 'Gent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      stateData.applyLocation(loc, controllers);
      expect(stateData.isSameAsCustomer, isFalse);
    });

    test('populateLocation restores VEKA IDs from saved ServiceLocation', () {
      final savedLoc = ServiceLocation(
        id: 42,
        customerId: 1,
        street: 'Gentsesteenweg',
        houseNumber: '5',
        postalCode: '9300',
        municipality: 'Aalst',
        adresId: '556677',
        gebouwId: '889900',
        gebouweenheidId: '112233',
        verificationStatus: 'verified',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      controllers.populateLocation(savedLoc);
      expect(controllers.locStreet.text, 'Gentsesteenweg');
      expect(controllers.vekaAdresId, '556677');
      expect(controllers.vekaVerificationStatus, 'verified');
    });

    test('clearAll resets all VEKA IDs to default unverified state', () {
      controllers.populateFromLookup(testMatch);
      controllers.clearAll();
      expect(controllers.vekaAdresId, isNull);
      expect(controllers.vekaVerificationStatus, 'unverified');
    });

    test('Cancel rollback restores snapshot customer, location, and VEKA IDs',
        () {
      final stateData = KlantTabStateData();
      final initialCustomer = Customer(
        id: 10,
        lastName: 'Peeters',
        street: 'Kerkstraat',
        houseNumber: '9',
        postalCode: '9000',
        city: 'Gent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final initialLocation = ServiceLocation(
        id: 20,
        customerId: 10,
        street: 'Kerkstraat',
        houseNumber: '9',
        postalCode: '9000',
        municipality: 'Gent',
        adresId: '111',
        gebouwId: '222',
        gebouweenheidId: '333',
        verificationStatus: 'verified',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      stateData.activeCustomer = initialCustomer;
      stateData.applyLocation(initialLocation, controllers);
      controllers.populateCustomer(initialCustomer);
      expect(controllers.houseNumber.text, '9');
      expect(controllers.vekaAdresId, '111');

      stateData.takeSnapshot();

      controllers.populateFromLookup(
        const AddressMatch(
          adresId: '999',
          volledigAdres: 'Kerkstraat 10, 9000 Gent',
          straatNaam: 'Kerkstraat',
          huisNummer: '10',
          postcode: '9000',
          gemeenteNaam: 'Gent',
          gebouwId: '888',
          gebouweenheidId: '777',
        ),
        isSameAsCustomer: true,
      );
      expect(controllers.houseNumber.text, '10');
      expect(controllers.vekaAdresId, '999');

      stateData.restoreSnapshot(controllers);

      expect(controllers.houseNumber.text, '9');
      expect(controllers.vekaAdresId, '111');
      expect(controllers.vekaGebouwId, '222');
      expect(controllers.vekaGebouweenheidId, '333');
      expect(
          controllers.isCurrentAddressVerified(isSameAsCustomer: true), isTrue);

      final rolledBackLoc = controllers.toLocation(
        customerId: stateData.activeCustomer!.id!,
        role: stateData.role,
        isSameAsCustomer: stateData.isSameAsCustomer,
      );
      expect(rolledBackLoc.houseNumber, '9');
      expect(rolledBackLoc.adresId, '111');
      expect(rolledBackLoc.verificationStatus, 'verified');
    });
  });
}
