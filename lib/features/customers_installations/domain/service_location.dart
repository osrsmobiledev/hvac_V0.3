/// Immutable domain entity representing a boiler service/installation location.
///
/// Preserves the customer's role at the location ('owner' or 'tenant')
/// and holds official Basisregisters IDs for government VEKA reporting.
class ServiceLocation {
  final int? id;
  final int customerId;
  final String role; // 'owner' or 'tenant'
  final String street;
  final String houseNumber;
  final String? boxNumber;
  final String postalCode;
  final String municipality;
  final String? adresId;
  final String? gebouwId;
  final String? gebouweenheidId;
  final String verificationStatus; // 'unverified', 'verified'
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceLocation({
    this.id,
    required this.customerId,
    this.role = 'owner',
    required this.street,
    required this.houseNumber,
    this.boxNumber,
    required this.postalCode,
    required this.municipality,
    this.adresId,
    this.gebouwId,
    this.gebouweenheidId,
    this.verificationStatus = 'unverified',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOwner => role == 'owner';
  bool get isTenant => role == 'tenant';

  /// Compact one-line formatted address for display and PDF export.
  String get formattedAddress {
    final numStr = [
      houseNumber,
      if (boxNumber != null && boxNumber!.isNotEmpty) 'bus $boxNumber',
    ].join(' ');
    return '$street $numStr, $postalCode $municipality'.trim();
  }

  ServiceLocation copyWith({
    int? id,
    int? customerId,
    String? role,
    String? street,
    String? houseNumber,
    String? boxNumber,
    String? postalCode,
    String? municipality,
    String? adresId,
    String? gebouwId,
    String? gebouweenheidId,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceLocation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      role: role ?? this.role,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      boxNumber: boxNumber ?? this.boxNumber,
      postalCode: postalCode ?? this.postalCode,
      municipality: municipality ?? this.municipality,
      adresId: adresId ?? this.adresId,
      gebouwId: gebouwId ?? this.gebouwId,
      gebouweenheidId: gebouweenheidId ?? this.gebouweenheidId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'role': role,
      'street': street,
      'house_number': houseNumber,
      'box_number': boxNumber,
      'postal_code': postalCode,
      'municipality': municipality,
      'adres_id': adresId,
      'gebouw_id': gebouwId,
      'gebouweenheid_id': gebouweenheidId,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ServiceLocation.fromMap(Map<String, dynamic> map) {
    return ServiceLocation(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      role: (map['role'] as String?) ?? 'owner',
      street: (map['street'] as String?) ?? '',
      houseNumber: (map['house_number'] as String?) ?? '',
      boxNumber: map['box_number'] as String?,
      postalCode: (map['postal_code'] as String?) ?? '',
      municipality: (map['municipality'] as String?) ?? '',
      adresId: map['adres_id'] as String?,
      gebouwId: map['gebouw_id'] as String?,
      gebouweenheidId: map['gebouweenheid_id'] as String?,
      verificationStatus:
          (map['verification_status'] as String?) ?? 'unverified',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
