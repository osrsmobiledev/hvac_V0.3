import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hvac_app/app/localization/basisregisters_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';

/// Stateless data-layer service calling the Basisregisters Vlaanderen v2 API.
abstract final class BasisregistersService {
  @visibleForTesting
  static String baseUrl = 'https://api.basisregisters.vlaanderen.be';
  @visibleForTesting
  static Duration timeout = const Duration(seconds: 10);
  @visibleForTesting
  static Future<BasisregistersResult> Function({
    required String straat,
    required String huisNummer,
    String? gemeente,
    String? postcode,
    String? bus,
  })? mockZoekAdres;

  /// Loads address text first so billing lookups never need building requests.
  static Future<BasisregistersResult> searchCandidates({
    required String straat,
    required String huisNummer,
    String? gemeente,
    String? postcode,
    String? bus,
  }) =>
      zoekAdres(
        straat: straat,
        huisNummer: huisNummer,
        gemeente: gemeente,
        postcode: postcode,
        bus: bus,
        enrichCandidates: false,
      );

  /// Finds Flemish address matches for the given address fields.
  static Future<BasisregistersResult> zoekAdres({
    required String straat,
    required String huisNummer,
    String? gemeente,
    String? postcode,
    String? bus,
    HttpClient? customClient,
    bool enrichCandidates = true,
  }) async {
    if (mockZoekAdres != null) {
      return mockZoekAdres!(
        straat: straat,
        huisNummer: huisNummer,
        gemeente: gemeente,
        postcode: postcode,
        bus: bus,
      );
    }
    final client = customClient ?? HttpClient();
    client.connectionTimeout = timeout;
    final bool shouldClose = customClient == null;

    try {
      final queryParams = <String, String>{
        'straatnaam': straat.trim(),
        'huisnummer': huisNummer.trim(),
      };
      if (gemeente != null && gemeente.trim().isNotEmpty) {
        queryParams['gemeentenaam'] = gemeente.trim();
      }
      if (postcode != null && postcode.trim().isNotEmpty) {
        queryParams['postcode'] = postcode.trim();
      }
      if (bus != null && bus.trim().isNotEmpty) {
        queryParams['busnummer'] = bus.trim();
      }

      final uri = Uri.parse('$baseUrl/v2/adresmatch')
          .replace(queryParameters: queryParams);

      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set('Accept', 'application/json');
      final response = await request.close().timeout(timeout);

      if (response.statusCode != 200) {
        return BasisregistersResult.failure(
          'Fout: HTTP ${response.statusCode} van Basisregisters.',
        );
      }

      final body =
          await response.transform(utf8.decoder).join().timeout(timeout);
      final json = jsonDecode(body) as Map<String, dynamic>;
      final rawMatches =
          (json['adresMatches'] as List<dynamic>?) ?? <dynamic>[];

      final matches = rawMatches
          .whereType<Map<String, dynamic>>()
          .map(AddressMatch.fromJson)
          .where((m) => m.adresId.isNotEmpty)
          .toList();

      if (matches.isEmpty) {
        return const BasisregistersResult.failure(
          'Geen adresresultaten gevonden. Probeer een andere schrijfwijze.',
        );
      }

      if (!enrichCandidates) return BasisregistersResult.success(matches);
      final enriched = await Future.wait(
        matches.map((m) => enrichMatch(m, client: client)),
      );

      return BasisregistersResult.success(enriched);
    } on SocketException {
      return const BasisregistersResult.failure(
        BasisregistersDictionary.lookupOffline,
      );
    } on TimeoutException {
      return const BasisregistersResult.failure(
        BasisregistersDictionary.lookupTimeoutError,
      );
    } on HttpException catch (e, stack) {
      debugPrint('[BasisregistersService] zoekAdres HttpException: $e\n$stack');
      return const BasisregistersResult.failure(
        'Verbindingsfout. Controleer uw netwerk.',
      );
    } catch (e, stack) {
      debugPrint('[BasisregistersService] unexpected error: $e\n$stack');
      return const BasisregistersResult.failure(
        'Onverwachte fout bij adressopzoeking.',
      );
    } finally {
      if (shouldClose) client.close(force: true);
    }
  }

  /// Enriches an [AddressMatch] by following the official v2 link hierarchy:
  /// 1. `/v2/gebouweenheden?adresobjectid={adresId}` -> gebouweenheidId
  /// 2. `/v2/gebouweenheden/{gebouweenheidId}` -> gebouwId
  static Future<AddressMatch> enrichMatch(
    AddressMatch match, {
    HttpClient? client,
  }) async {
    if (match.isEnriched) return match;

    final localClient = client ?? HttpClient();
    localClient.connectionTimeout = const Duration(seconds: 8);
    final shouldClose = client == null;

    try {
      final geUri = Uri.parse(
        '$baseUrl/v2/gebouweenheden?adresobjectid=${match.adresId}',
      );
      final geReq = await localClient.getUrl(geUri).timeout(timeout);
      geReq.headers.set('Accept', 'application/json');
      final geResp = await geReq.close().timeout(timeout);

      if (geResp.statusCode != 200) return match.withVekaIds();

      final geBody =
          await geResp.transform(utf8.decoder).join().timeout(timeout);
      final geJson = jsonDecode(geBody) as Map<String, dynamic>;
      final geList =
          (geJson['gebouweenheden'] as List<dynamic>?) ?? <dynamic>[];

      if (geList.isEmpty) return match.withVekaIds();

      // A lone unit is only stored after its detail response confirms its ID.
      String? gebouweenheidId;

      // Check building IDs across all units:
      // If all units point to the same building, gebouwId is unambiguous.
      // If units point to different buildings or any fails to resolve, gebouwId is ambiguous -> null!
      final buildingLookups = geList.map((ge) async {
        final geMap = ge as Map<String, dynamic>?;
        final geIdMap = geMap?['identificator'] as Map<String, dynamic>?;
        final uId = geIdMap?['objectId']?.toString();
        if (uId == null || uId.isEmpty) return null;

        try {
          final detailUri = Uri.parse('$baseUrl/v2/gebouweenheden/$uId');
          final detReq = await localClient.getUrl(detailUri).timeout(timeout);
          detReq.headers.set('Accept', 'application/json');
          final detResp = await detReq.close().timeout(timeout);

          if (detResp.statusCode == 200) {
            final detBody =
                await detResp.transform(utf8.decoder).join().timeout(timeout);
            final detJson = jsonDecode(detBody) as Map<String, dynamic>;
            final detailId = detJson['identificator'] as Map<String, dynamic>?;
            if (detailId?['objectId']?.toString() != uId) return null;
            if (geList.length == 1) gebouweenheidId = uId;
            final gebouwMap = detJson['gebouw'] as Map<String, dynamic>?;
            return gebouwMap?['objectId']?.toString();
          }
        } catch (_) {}
        return null;
      });

      final buildingResults = await Future.wait(buildingLookups);
      final bool allResolved = buildingResults.isNotEmpty &&
          buildingResults.every((b) => b != null && b.isNotEmpty);
      final Set<String> distinctBuildings =
          buildingResults.whereType<String>().toSet();

      final gebouwId = (allResolved && distinctBuildings.length == 1)
          ? distinctBuildings.first
          : null;

      return match.withVekaIds(
        gebouwId: gebouwId,
        gebouweenheidId: gebouweenheidId,
      );
    } catch (e, stack) {
      debugPrint('[BasisregistersService] enrichMatch error: $e\n$stack');
      return match.withVekaIds();
    } finally {
      if (shouldClose) localClient.close(force: true);
    }
  }
}
