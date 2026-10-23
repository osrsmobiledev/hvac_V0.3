/// Immutable domain entity representing a customer in the HVAC database.
class Customer {
  final int? id;
  final String? firstName;
  final String lastName;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? street;
  final String? houseNumber;
  final String? boxNumber;
  final String? postalCode;
  final String? city;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    this.id,
    this.firstName,
    required this.lastName,
    this.companyName,
    this.email,
    this.phone,
    this.street,
    this.houseNumber,
    this.boxNumber,
    this.postalCode,
    this.city,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted display name combining company and/or personal name.
  String get displayName {
    final fullPersonal = '${firstName ?? ''} $lastName'.trim();
    final company = companyName?.trim() ?? '';
    if (company.isNotEmpty &&
        fullPersonal.isNotEmpty &&
        company != fullPersonal) {
      return '$company ($fullPersonal)';
    }
    if (company.isNotEmpty) return company;
    return fullPersonal.isNotEmpty ? fullPersonal : 'Onbekende klant';
  }

  /// Compact one-line address representation.
  String get formattedAddress {
    final addressParts = <String>[];
    if (street != null && street!.isNotEmpty) {
      final numStr = [
        houseNumber ?? '',
        if (boxNumber != null && boxNumber!.isNotEmpty) 'bus $boxNumber',
      ].where((s) => s.isNotEmpty).join(' ');
      addressParts.add('$street $numStr'.trim());
    }
    final cityParts =
        [postalCode ?? '', city ?? ''].where((s) => s.isNotEmpty).join(' ');
    if (cityParts.isNotEmpty) addressParts.add(cityParts);
    return addressParts.isEmpty
        ? 'Geen adres ingevoerd'
        : addressParts.join(', ');
  }

  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? companyName,
    String? email,
    String? phone,
    String? street,
    String? houseNumber,
    String? boxNumber,
    String? postalCode,
    String? city,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      boxNumber: boxNumber ?? this.boxNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'street': street,
      'house_number': houseNumber,
      'box_number': boxNumber,
      'postal_code': postalCode,
      'city': city,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      firstName: map['first_name'] as String?,
      lastName: (map['last_name'] as String?) ?? '',
      companyName: map['company_name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      street: map['street'] as String?,
      houseNumber: map['house_number'] as String?,
      boxNumber: map['box_number'] as String?,
      postalCode: map['postal_code'] as String?,
      city: map['city'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
