import 'dart:convert';

import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant_form_controllers.dart';

/// Captures form values before a queued save can outlive the tab's controllers.
class KlantFormDataSnapshot {
  final Customer customerValues;
  final ServiceLocation locationValues;
  final bool? isSameAsCustomer;

  const KlantFormDataSnapshot({
    required this.customerValues,
    required this.locationValues,
    this.isSameAsCustomer,
  });

  factory KlantFormDataSnapshot.fromControllers({
    required KlantFormControllers controllers,
    required String role,
    required bool isSameAsCustomer,
  }) =>
      KlantFormDataSnapshot(
        customerValues: controllers.toCustomer(),
        locationValues: controllers.toLocation(
          customerId: 0,
          role: role,
          isSameAsCustomer: isSameAsCustomer,
        ),
        isSameAsCustomer: isSameAsCustomer,
      );
}

/// Keeps the original records and the IDs created by a single edit.
class KlantEditSession {
  final int draftId;
  final int? initialCustomerId;
  final int? initialLocationId;
  final Customer? initialCustomer;
  final ServiceLocation? initialLocation;
  final bool? initialSameAsCustomer;
  final bool? savedSameAsCustomer;

  int? activeCustomerId;
  int? activeLocationId;
  final Set<int> createdCustomerIds;
  final Set<int> createdLocationIds;

  bool isCancelled = false;
  bool isFinishing = false;

  KlantEditSession({
    required this.draftId,
    this.initialCustomerId,
    this.initialLocationId,
    this.initialCustomer,
    this.initialLocation,
    this.initialSameAsCustomer,
    this.savedSameAsCustomer,
    this.activeCustomerId,
    this.activeLocationId,
    Iterable<int>? createdCustomerIds,
    Iterable<int>? createdLocationIds,
  })  : createdCustomerIds = {...?createdCustomerIds},
        createdLocationIds = {...?createdLocationIds};

  /// Encodes the new IDs inside the transaction without mutating live state.
  String undoAfterSave({
    required int customerId,
    required int locationId,
    required bool? sameAsCustomer,
  }) =>
      jsonEncode({
        'draftId': draftId,
        'initialCustomerId': initialCustomerId,
        'initialLocationId': initialLocationId,
        'initialCustomer': initialCustomer?.toMap(),
        'initialLocation': initialLocation?.toMap(),
        'initialSameAsCustomer': initialSameAsCustomer,
        'savedSameAsCustomer': sameAsCustomer,
        'activeCustomerId': customerId,
        'activeLocationId': locationId,
        'createdCustomerIds': [
          ...createdCustomerIds,
          if (activeCustomerId == null) customerId,
        ],
        'createdLocationIds': [
          ...createdLocationIds,
          if (activeLocationId == null) locationId,
        ],
      });

  static KlantEditSession? fromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return KlantEditSession(
        draftId: map['draftId'] as int,
        initialCustomerId: map['initialCustomerId'] as int?,
        initialLocationId: map['initialLocationId'] as int?,
        initialCustomer: map['initialCustomer'] != null
            ? Customer.fromMap(
                Map<String, dynamic>.from(map['initialCustomer'] as Map))
            : null,
        initialLocation: map['initialLocation'] != null
            ? ServiceLocation.fromMap(
                Map<String, dynamic>.from(map['initialLocation'] as Map))
            : null,
        initialSameAsCustomer: map['initialSameAsCustomer'] as bool?,
        savedSameAsCustomer: map['savedSameAsCustomer'] as bool?,
        activeCustomerId: map['activeCustomerId'] as int?,
        activeLocationId: map['activeLocationId'] as int?,
        createdCustomerIds:
            (map['createdCustomerIds'] as List<dynamic>?)?.cast<int>(),
        createdLocationIds:
            (map['createdLocationIds'] as List<dynamic>?)?.cast<int>(),
      );
    } catch (_) {
      return null;
    }
  }
}
