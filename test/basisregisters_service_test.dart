import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/basisregisters_dictionary.dart';
import 'package:hvac_app/core/services/basisregisters_service.dart';

Map<String, dynamic> _makeAdresMatchJson({
  required String id,
  required String street,
  required String nr,
  required String zip,
  required String city,
}) =>
    {
      'adresMatches': [
        {
          'identificator': {'objectId': id},
          'straatnaam': {
            'straatnaam': {
              'geografischeNaam': {'spelling': street}
            }
          },
          'huisnummer': nr,
          'postinfo': {'objectId': zip},
          'gemeente': {
            'gemeentenaam': {
              'geografischeNaam': {'spelling': city}
            }
          },
          'volledigAdres': {
            'geografischeNaam': {'spelling': '$street $nr, $zip $city'}
          },
        }
      ]
    };

void main() {
  group('BasisregistersService Network & Error Handling Tests', () {
    late HttpServer mockServer;
    final originalBaseUrl = BasisregistersService.baseUrl;
    final originalTimeout = BasisregistersService.timeout;

    tearDown(() async {
      BasisregistersService.baseUrl = originalBaseUrl;
      BasisregistersService.timeout = originalTimeout;
      await mockServer.close(force: true);
    });

    test('returns timeout error when server connects but stalls', () async {
      mockServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      mockServer.listen((HttpRequest request) {});

      BasisregistersService.baseUrl =
          'http://${mockServer.address.address}:${mockServer.port}';
      BasisregistersService.timeout = const Duration(milliseconds: 200);

      final result = await BasisregistersService.zoekAdres(
        straat: 'Kerkstraat',
        huisNummer: '1',
        postcode: '9000',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, BasisregistersDictionary.lookupTimeoutError);
    });

    for (final mismatchedUnit in [false, true]) {
      test('enriches selected address with matching unit: ${!mismatchedUnit}',
          () async {
        String? municipality;
        mockServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        mockServer.listen((HttpRequest request) {
          final path = request.uri.path;
          request.response.headers.contentType = ContentType.json;

          if (path == '/v2/adresmatch') {
            municipality = request.uri.queryParameters['gemeentenaam'];
            request.response.write(jsonEncode(_makeAdresMatchJson(
              id: '2248917',
              street: 'Kerkstraat',
              nr: '1',
              zip: '9000',
              city: 'Gent',
            )));
          } else if (path == '/v2/gebouweenheden' &&
              request.uri.queryParameters['adresobjectid'] == '2248917') {
            request.response.write(jsonEncode({
              'gebouweenheden': [
                {
                  'identificator': {'objectId': '5818846'},
                  'gebouweenheidStatus': 'gerealiseerd',
                }
              ]
            }));
          } else if (path == '/v2/gebouweenheden/5818846') {
            request.response.write(jsonEncode({
              'identificator': {'objectId': mismatchedUnit ? '123' : '5818846'},
              'gebouw': {'objectId': '5817196'},
            }));
          } else {
            request.response.statusCode = 404;
          }
          request.response.close();
        });

        BasisregistersService.baseUrl =
            'http://${mockServer.address.address}:${mockServer.port}';
        BasisregistersService.timeout = const Duration(seconds: 3);

        final result = await BasisregistersService.zoekAdres(
          straat: 'Kerkstraat',
          huisNummer: '1',
          postcode: '9000',
          gemeente: ' Gent ',
        );

        expect(result.isSuccess, isTrue);
        expect(municipality, 'Gent');
        expect(result.matches.length, 1);
        final match = result.matches.first;
        expect(match.adresId, '2248917');
        expect(match.gebouweenheidId, mismatchedUnit ? isNull : '5818846');
        expect(match.gebouwId, mismatchedUnit ? isNull : '5817196');
        expect(
            match.verificationStatus, mismatchedUnit ? 'partial' : 'verified');
      });
    }

    test('retains shared gebouwId when multiple units share the same building',
        () async {
      mockServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      mockServer.listen((HttpRequest request) {
        final path = request.uri.path;
        request.response.headers.contentType = ContentType.json;

        if (path == '/v2/adresmatch') {
          request.response.write(jsonEncode(_makeAdresMatchJson(
            id: '300',
            street: 'Dorp',
            nr: '5',
            zip: '9000',
            city: 'Gent',
          )));
        } else if (path == '/v2/gebouweenheden') {
          request.response.write(jsonEncode({
            'gebouweenheden': [
              {
                'identificator': {'objectId': 'unit-1'}
              },
              {
                'identificator': {'objectId': 'unit-2'}
              },
            ]
          }));
        } else if (path == '/v2/gebouweenheden/unit-1' ||
            path == '/v2/gebouweenheden/unit-2') {
          request.response.write(jsonEncode({
            'identificator': {'objectId': path.split('/').last},
            'gebouw': {'objectId': 'gebouw-99'},
          }));
        } else {
          request.response.statusCode = 404;
        }
        request.response.close();
      });

      BasisregistersService.baseUrl =
          'http://${mockServer.address.address}:${mockServer.port}';
      BasisregistersService.timeout = const Duration(seconds: 3);

      final result = await BasisregistersService.zoekAdres(
        straat: 'Dorp',
        huisNummer: '5',
        postcode: '9000',
      );

      expect(result.isSuccess, isTrue);
      final match = result.matches.first;
      expect(match.gebouweenheidId, isNull);
      expect(match.gebouweenheidIdNietGekend, isTrue);
      expect(match.gebouwId, 'gebouw-99');
      expect(match.hasFullVekaMatch, isFalse);
      expect(match.hasPartialVekaMatch, isTrue);
    });

    test(
        'clears gebouwId when multiple units at one address point to different buildings',
        () async {
      mockServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      mockServer.listen((HttpRequest request) {
        final path = request.uri.path;
        request.response.headers.contentType = ContentType.json;

        if (path == '/v2/adresmatch') {
          request.response.write(jsonEncode(_makeAdresMatchJson(
            id: '400',
            street: 'Kade',
            nr: '12',
            zip: '9000',
            city: 'Gent',
          )));
        } else if (path == '/v2/gebouweenheden') {
          request.response.write(jsonEncode({
            'gebouweenheden': [
              {
                'identificator': {'objectId': 'unit-A'}
              },
              {
                'identificator': {'objectId': 'unit-B'}
              },
            ]
          }));
        } else if (path == '/v2/gebouweenheden/unit-A') {
          request.response.write(jsonEncode({
            'identificator': {'objectId': 'unit-A'},
            'gebouw': {'objectId': 'gebouw-A'},
          }));
        } else if (path == '/v2/gebouweenheden/unit-B') {
          request.response.write(jsonEncode({
            'identificator': {'objectId': 'unit-B'},
            'gebouw': {'objectId': 'gebouw-B'},
          }));
        } else {
          request.response.statusCode = 404;
        }
        request.response.close();
      });

      BasisregistersService.baseUrl =
          'http://${mockServer.address.address}:${mockServer.port}';
      BasisregistersService.timeout = const Duration(seconds: 3);

      final result = await BasisregistersService.zoekAdres(
        straat: 'Kade',
        huisNummer: '12',
        postcode: '9000',
      );

      expect(result.isSuccess, isTrue);
      final match = result.matches.first;
      expect(match.gebouweenheidId, isNull);
      expect(match.gebouweenheidIdNietGekend, isTrue);
      expect(match.gebouwId, isNull);
      expect(match.hasFullVekaMatch, isFalse);
      expect(match.hasPartialVekaMatch, isFalse);
    });
  });
}
