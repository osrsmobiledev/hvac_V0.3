import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';

void main() {
  group('Basisregisters Models Tests', () {
    test('AddressMatch parses official Basisregisters v2 JSON correctly', () {
      final sampleJson = {
        'identificator': {
          'id': 'https://data.vlaanderen.be/id/adres/2447812',
          'objectId': '2447812',
        },
        'straatnaam': {
          'straatnaam': {
            'geografischeNaam': {
              'spelling': 'Koning Albert II-laan',
            },
          },
        },
        'huisnummer': '20',
        'busnummer': '3',
        'postinfo': {
          'objectId': '1000',
        },
        'gemeente': {
          'gemeentenaam': {
            'geografischeNaam': {
              'spelling': 'Brussel',
            },
          },
        },
        'volledigAdres': {
          'geografischeNaam': {
            'spelling': 'Koning Albert II-laan 20 bus 3, 1000 Brussel',
          },
        },
      };

      final match = AddressMatch.fromJson(sampleJson);

      expect(match.adresId, '2447812');
      expect(match.straatNaam, 'Koning Albert II-laan');
      expect(match.huisNummer, '20');
      expect(match.busNummer, '3');
      expect(match.postcode, '1000');
      expect(match.gemeenteNaam, 'Brussel');
      expect(
        match.volledigAdres,
        'Koning Albert II-laan 20 bus 3, 1000 Brussel',
      );
      expect(match.gebouwId, isNull);
      expect(match.gebouweenheidId, isNull);
      expect(match.gebouwIdNietGekend, isTrue);
      expect(match.gebouweenheidIdNietGekend, isTrue);
    });

    test('withVekaIds enriches address and derives compliance flags', () {
      const initial = AddressMatch(
        adresId: '2447812',
        volledigAdres: 'Koning Albert II-laan 20 bus 3, 1000 Brussel',
        straatNaam: 'Koning Albert II-laan',
        huisNummer: '20',
        busNummer: '3',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      );

      final enriched = initial.withVekaIds(
        gebouwId: '9400001',
        gebouweenheidId: '9400075',
      );

      expect(enriched.adresId, '2447812');
      expect(enriched.gebouwId, '9400001');
      expect(enriched.gebouweenheidId, '9400075');
      expect(enriched.gebouwIdNietGekend, isFalse);
      expect(enriched.gebouweenheidIdNietGekend, isFalse);
    });

    test('AddressMatch equality and hashCode are based on adresId', () {
      const match1 = AddressMatch(
        adresId: '2447812',
        volledigAdres: 'Adres 1',
        straatNaam: 'Straat',
        huisNummer: '1',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      );
      const match2 = AddressMatch(
        adresId: '2447812',
        volledigAdres: 'Adres 2 (Updated)',
        straatNaam: 'Straat',
        huisNummer: '1',
        postcode: '1000',
        gemeenteNaam: 'Brussel',
      );
      const match3 = AddressMatch(
        adresId: '9999999',
        volledigAdres: 'Ander Adres',
        straatNaam: 'Ander',
        huisNummer: '2',
        postcode: '2000',
        gemeenteNaam: 'Antwerpen',
      );

      expect(match1, equals(match2));
      expect(match1.hashCode, equals(match2.hashCode));
      expect(match1, isNot(equals(match3)));
    });

    test('BasisregistersResult handles success and failure constructors', () {
      const match = AddressMatch(
        adresId: '100',
        volledigAdres: 'Teststraat 1, 9000 Gent',
        straatNaam: 'Teststraat',
        huisNummer: '1',
        postcode: '9000',
        gemeenteNaam: 'Gent',
      );

      const success = BasisregistersResult.success([match]);
      expect(success.isSuccess, isTrue);
      expect(success.matches.length, 1);
      expect(success.errorMessage, isNull);

      const failure = BasisregistersResult.failure('Netwerkfout');
      expect(failure.isSuccess, isFalse);
      expect(failure.matches, isEmpty);
      expect(failure.errorMessage, 'Netwerkfout');
    });
  });
}
