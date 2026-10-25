import 'package:flutter/foundation.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant_form_controllers.dart';

/// Coordinates SQLite reads and writes for the Klant tab.
///
/// Keeps database orchestration separate from widget UI state to ensure
/// clean testability and strictly enforce the 250-line file limit.
class KlantDataCoordinator {
  final CustomerRepository customerRepo;
  final DraftRepository draftRepo;

  KlantDataCoordinator({
    CustomerRepository? customerRepository,
    DraftRepository? draftRepository,
  })  : customerRepo = customerRepository ?? CustomerRepository(),
        draftRepo = draftRepository ?? DraftRepository();

  /// Loads the active draft and any associated customer & service location.
  Future<({int draftId, Customer? customer, ServiceLocation? location})>
      loadDraftData() async {
    final draft = await draftRepo.getOrCreateActiveDraft();
    Customer? customer;
    ServiceLocation? location;

    if (draft.customerId != null) {
      customer = await customerRepo.getCustomerById(draft.customerId!);
    }

    if (draft.serviceLocationId != null) {
      final locs =
          await customerRepo.getLocationsForCustomer(draft.customerId ?? 0);
      location = locs.where((l) => l.id == draft.serviceLocationId).firstOrNull;
    }

    return (draftId: draft.id, customer: customer, location: location);
  }

  /// Saves form data from [controllers] linked to [draftId].
  Future<({Customer customer, ServiceLocation location})?> saveFromControllers({
    required int draftId,
    required KlantFormControllers controllers,
    Customer? activeCustomer,
    ServiceLocation? activeLocation,
    required String role,
    required bool isSameAsCustomer,
  }) async {
    final customer = controllers.toCustomer(
      id: activeCustomer?.id,
      createdAt: activeCustomer?.createdAt,
    );
    final location = controllers.toLocation(
      id: activeLocation?.id,
      customerId: activeCustomer?.id ?? 0,
      role: role,
      isSameAsCustomer: isSameAsCustomer,
      createdAt: activeLocation?.createdAt,
    );
    return saveCustomer(
      draftId: draftId,
      customer: customer,
      location: location,
    );
  }

  /// Persists customer and location details linked to [draftId].
  Future<({Customer customer, ServiceLocation location})?> saveCustomer({
    required int draftId,
    required Customer customer,
    required ServiceLocation location,
  }) async {
    try {
      return await customerRepo.saveCustomerWithLocation(
        customer: customer,
        location: location,
        visitId: draftId,
      );
    } catch (e, stack) {
      debugPrint('[KlantDataCoordinator] saveCustomer error: $e\n$stack');
      return null;
    }
  }

  /// Links a chosen customer and location to the active draft.
  Future<void> linkCustomer({
    required int draftId,
    required int customerId,
    int? locationId,
  }) async {
    await draftRepo.updateVisitCustomer(
      visitId: draftId,
      customerId: customerId,
      serviceLocationId: locationId,
    );
  }

  /// Resolves primary location for [customer] and links both to [draftId].
  Future<ServiceLocation?> linkPickedCustomer({
    required int? draftId,
    required Customer customer,
  }) async {
    final loc = await customerRepo.getPrimaryLocationForCustomer(customer.id!);
    if (draftId != null) {
      await linkCustomer(
        draftId: draftId,
        customerId: customer.id!,
        locationId: loc?.id,
      );
    }
    return loc;
  }

  /// Removes customer association from the active draft.
  Future<void> unlinkCustomer(int draftId) async {
    await draftRepo.updateVisitCustomer(
      visitId: draftId,
      customerId: null,
      serviceLocationId: null,
    );
  }
}
