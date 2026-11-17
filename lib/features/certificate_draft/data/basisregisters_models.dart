/// Lightweight DTO for a single address returned by the Basisregisters v2 API.
class AddressMatch {
  /// Official Basisregisters adres objectId (e.g. "2447812").
  final String adresId;

  /// Fully formatted Flemish address (e.g. "Dorpstraat 5 bus 2, 2000 Antwerpen").
  final String volledigAdres;

  /// Extracted street name from the response.
  final String straatNaam;

  /// Extracted house number.
  final String huisNummer;

  /// Extracted box number, null when absent.
  final String? busNummer;

  /// Extracted postal code (objectId of postinfo).
  final String postcode;

  /// Extracted municipality name.
  final String gemeenteNaam;

  /// Building ID fetched from the detail endpoint, null when unavailable.
  final String? gebouwId;

  /// Building unit ID fetched from the detail endpoint, null when unavailable.
  final String? gebouweenheidId;

  /// True when enrichment has already been executed for this match.
  final bool isEnriched;

  /// Convenience VEKA flag: true when no gebouweenheidId was found.
  bool get gebouweenheidIdNietGekend => gebouweenheidId == null;

  /// Convenience VEKA flag: true when no gebouwId was found.
  bool get gebouwIdNietGekend => gebouwId == null;

  /// Full match: address ID, building ID, and building unit ID all present.
  bool get hasFullVekaMatch =>
      adresId.isNotEmpty &&
      gebouwId != null &&
      gebouwId!.isNotEmpty &&
      gebouweenheidId != null &&
      gebouweenheidId!.isNotEmpty;

  /// Partial match: address ID present, but building or unit partially known.
  bool get hasPartialVekaMatch =>
      adresId.isNotEmpty &&
      !hasFullVekaMatch &&
      ((gebouwId != null && gebouwId!.isNotEmpty) ||
          (gebouweenheidId != null && gebouweenheidId!.isNotEmpty));

  String get verificationStatus {
    if (hasFullVekaMatch) return 'verified';
    return adresId.isNotEmpty ? 'partial' : 'unverified';
  }

  const AddressMatch({
    required this.adresId,
    required this.volledigAdres,
    required this.straatNaam,
    required this.huisNummer,
    this.busNummer,
    required this.postcode,
    required this.gemeenteNaam,
    this.gebouwId,
    this.gebouweenheidId,
    this.isEnriched = false,
  });

  /// Parses a single entry from the `adresMatches` JSON array.
  factory AddressMatch.fromJson(Map<String, dynamic> json) {
    final id = json['identificator'] as Map<String, dynamic>?;
    final adresId = (id?['objectId'] as String?) ?? '';

    final vollMap = json['volledigAdres'] as Map<String, dynamic>?;
    final geoName = vollMap?['geografischeNaam'] as Map<String, dynamic>?;
    final volledigAdres = (geoName?['spelling'] as String?) ?? '';

    final straatMap = json['straatnaam'] as Map<String, dynamic>?;
    final straatNaamMap = straatMap?['straatnaam'] as Map<String, dynamic>?;
    final geoStraat =
        straatNaamMap?['geografischeNaam'] as Map<String, dynamic>?;
    final straatNaam = (geoStraat?['spelling'] as String?) ?? '';

    final huisNummer = (json['huisnummer'] as String?) ?? '';
    final busNummer = json['busnummer'] as String?;

    final postMap = json['postinfo'] as Map<String, dynamic>?;
    final postcode = (postMap?['objectId'] as String?) ?? '';

    final gemMap = json['gemeente'] as Map<String, dynamic>?;
    final gemNaamMap = gemMap?['gemeentenaam'] as Map<String, dynamic>?;
    final gemGeo = gemNaamMap?['geografischeNaam'] as Map<String, dynamic>?;
    final gemeenteNaam = (gemGeo?['spelling'] as String?) ?? '';

    return AddressMatch(
      adresId: adresId,
      volledigAdres: volledigAdres,
      straatNaam: straatNaam,
      huisNummer: huisNummer,
      busNummer: busNummer,
      postcode: postcode,
      gemeenteNaam: gemeenteNaam,
      isEnriched: false,
    );
  }

  /// Returns a copy with VEKA IDs filled in after the detail endpoint is called.
  AddressMatch withVekaIds({String? gebouwId, String? gebouweenheidId}) {
    return AddressMatch(
      adresId: adresId,
      volledigAdres: volledigAdres,
      straatNaam: straatNaam,
      huisNummer: huisNummer,
      busNummer: busNummer,
      postcode: postcode,
      gemeenteNaam: gemeenteNaam,
      gebouwId: gebouwId,
      gebouweenheidId: gebouweenheidId,
      isEnriched: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressMatch &&
          runtimeType == other.runtimeType &&
          adresId == other.adresId;

  @override
  int get hashCode => adresId.hashCode;
}

/// Result of a Basisregisters lookup call.
class BasisregistersResult {
  final List<AddressMatch> matches;
  final String? errorMessage;

  const BasisregistersResult.success(this.matches) : errorMessage = null;
  const BasisregistersResult.failure(this.errorMessage) : matches = const [];

  bool get isSuccess => errorMessage == null;
}
