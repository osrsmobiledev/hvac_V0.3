/// Domain model representing the reusable Company and Technician profile.
///
/// Backed by the singleton `technician_profile` table in SQLite so the technician
/// only enters these details once, automatically pre-populating all future visits.
class TechnicianProfile {
  final int? id;
  final String companyName;
  final String kboNumber;
  final String street;
  final String houseNumber;
  final String boxNumber;
  final String postalCode;
  final String city;
  final String phone;
  final String email;
  final String technicianFirstName;
  final String technicianLastName;
  final String gvNumber;
  final String tvNumber;

  const TechnicianProfile({
    this.id,
    this.companyName = '',
    this.kboNumber = '',
    this.street = '',
    this.houseNumber = '',
    this.boxNumber = '',
    this.postalCode = '',
    this.city = '',
    this.phone = '',
    this.email = '',
    this.technicianFirstName = '',
    this.technicianLastName = '',
    this.gvNumber = '',
    this.tvNumber = '',
  });

  factory TechnicianProfile.fromMap(Map<String, Object?> map) {
    return TechnicianProfile(
      id: map['id'] as int?,
      companyName: (map['company_name'] as String?) ?? '',
      kboNumber: (map['kbo_number'] as String?) ?? '',
      street: (map['street'] as String?) ?? '',
      houseNumber: (map['house_number'] as String?) ?? '',
      boxNumber: (map['box_number'] as String?) ?? '',
      postalCode: (map['postal_code'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      technicianFirstName: (map['technician_first_name'] as String?) ?? '',
      technicianLastName: (map['technician_last_name'] as String?) ?? '',
      gvNumber: (map['gv_number'] as String?) ?? '',
      tvNumber: (map['tv_number'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      'company_name': companyName,
      'kbo_number': kboNumber,
      'street': street,
      'house_number': houseNumber,
      'box_number': boxNumber,
      'postal_code': postalCode,
      'city': city,
      'phone': phone,
      'email': email,
      'technician_first_name': technicianFirstName,
      'technician_last_name': technicianLastName,
      'gv_number': gvNumber,
      'tv_number': tvNumber,
      'updated_at': now,
    };
  }
}
