import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant_edit_session.dart';
import 'klant_rollback_helper.dart';

typedef KlantSavedRows = ({Customer customer, ServiceLocation location});

/// Orders all Klant writes and keeps their identity tied to the edit session.
class KlantDataCoordinator {
  final CustomerRepository customerRepo;
  final DraftRepository draftRepo;
  final AppDatabase appDatabase;

  KlantEditSession? _activeSession;
  Future<void> _writeQueue = Future.value();

  KlantDataCoordinator({
    CustomerRepository? customerRepository,
    DraftRepository? draftRepository,
    AppDatabase? appDb,
  })  : customerRepo = customerRepository ?? CustomerRepository(),
        draftRepo = draftRepository ?? DraftRepository(),
        appDatabase = appDb ?? AppDatabase.instance;

  Future<
      ({
        int draftId,
        Customer? customer,
        ServiceLocation? location,
        KlantEditSession? pendingSession,
      })> loadDraftData({String certificateType = 'verbranding'}) async {
    final draft = await draftRepo.getOrCreateActiveDraft(
        certificateType: certificateType);
    final customerId = draft.customerId;
    final locationId = draft.serviceLocationId;
    final customer = customerId == null
        ? null
        : await customerRepo.getCustomerById(customerId);
    final locations = customerId == null || locationId == null
        ? const <ServiceLocation>[]
        : await customerRepo.getLocationsForCustomer(customerId);
    final location =
        locations.where((item) => item.id == locationId).firstOrNull;
    final saved = KlantEditSession.fromJson(draft.klantUndoJson);
    final pending = saved?.draftId == draft.id ? saved : null;
    _activeSession = pending;
    return (
      draftId: draft.id,
      customer: customer,
      location: location,
      pendingSession: pending,
    );
  }

  /// The original links stay in SQLite until the new customer is first saved.
  void startNewSession({
    required int draftId,
    Customer? currentCustomer,
    ServiceLocation? currentLocation,
    bool? sameAsCustomer,
  }) {
    _activeSession = KlantEditSession(
      draftId: draftId,
      initialCustomerId: currentCustomer?.id,
      initialLocationId: currentLocation?.id,
      initialCustomer: currentCustomer,
      initialLocation: currentLocation,
      initialSameAsCustomer: sameAsCustomer,
    );
  }

  void startEditSession({
    required int draftId,
    required Customer currentCustomer,
    ServiceLocation? currentLocation,
    bool? sameAsCustomer,
  }) {
    _activeSession = KlantEditSession(
      draftId: draftId,
      initialCustomerId: currentCustomer.id,
      initialLocationId: currentLocation?.id,
      initialCustomer: currentCustomer,
      initialLocation: currentLocation,
      initialSameAsCustomer: sameAsCustomer,
      activeCustomerId: currentCustomer.id,
      activeLocationId: currentLocation?.id,
    );
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final operation = _writeQueue.then((_) => action());
    // A failed write is reported to its caller and leaves the queue usable.
    _writeQueue =
        operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  Future<KlantSavedRows?> enqueueSave({
    required int draftId,
    required KlantFormDataSnapshot snapshot,
  }) {
    final session = _activeSession ??= KlantEditSession(draftId: draftId);
    if (session.draftId != draftId || session.isFinishing) {
      return Future.value(null);
    }
    return _enqueue(() async {
      if (!identical(_activeSession, session) || session.isCancelled) {
        return null;
      }
      final result = await _save(session, snapshot, finalSave: false);
      return session.isCancelled ? null : result;
    });
  }

  Future<KlantSavedRows> _save(
    KlantEditSession session,
    KlantFormDataSnapshot snapshot, {
    required bool finalSave,
  }) async {
    // Resolve the IDs after earlier saves have committed to avoid duplicate inserts.
    final customerId = session.activeCustomerId;
    final locationId = session.activeLocationId;
    final result = await customerRepo.saveCustomerWithLocation(
      customer: snapshot.customerValues.copyWith(id: customerId),
      location: snapshot.locationValues.copyWith(
        id: locationId,
        customerId: customerId ?? 0,
      ),
      visitId: session.draftId,
      buildUndoJson: (savedCustomer, savedLocation) => finalSave
          ? null
          : session.undoAfterSave(
              customerId: savedCustomer,
              locationId: savedLocation,
              sameAsCustomer: snapshot.isSameAsCustomer,
            ),
    );

    final savedCustomer = result.customer.id!;
    final savedLocation = result.location.id!;
    if (customerId == null) session.createdCustomerIds.add(savedCustomer);
    if (locationId == null) session.createdLocationIds.add(savedLocation);
    session.activeCustomerId = savedCustomer;
    session.activeLocationId = savedLocation;
    return result;
  }

  Future<bool> cancelSession(int draftId) async {
    final session = _activeSession;
    if (session == null || session.draftId != draftId || session.isFinishing) {
      return false;
    }
    session.isFinishing = true;
    session.isCancelled = true;
    return _enqueue(() async {
      try {
        if (!identical(_activeSession, session)) return false;
        await KlantRollbackHelper.rollbackInTxn(
          appDatabase: appDatabase,
          session: session,
        );
        _activeSession = null;
        return true;
      } catch (e, stack) {
        debugPrint('[KlantDataCoordinator] cancelSession error: $e\n$stack');
        return false;
      } finally {
        session.isFinishing = false;
        session.isCancelled = false;
      }
    });
  }

  Future<KlantSavedRows?> confirmSave({
    required int draftId,
    required KlantFormDataSnapshot snapshot,
  }) async {
    final session = _activeSession;
    if (session == null || session.draftId != draftId || session.isFinishing) {
      return null;
    }
    session.isFinishing = true;
    return _enqueue(() async {
      try {
        if (!identical(_activeSession, session)) return null;
        final result = await _save(session, snapshot, finalSave: true);
        _activeSession = null;
        return result;
      } catch (e, stack) {
        debugPrint('[KlantDataCoordinator] confirmSave error: $e\n$stack');
        return null;
      } finally {
        session.isFinishing = false;
      }
    });
  }

  Future<ServiceLocation?> linkPickedCustomer({
    required int? draftId,
    required Customer customer,
  }) =>
      _enqueue(() async {
        final location =
            await customerRepo.getPrimaryLocationForCustomer(customer.id!);
        if (draftId != null) {
          await KlantRollbackHelper.setDraftLinks(
            appDatabase: appDatabase,
            draftId: draftId,
            customerId: customer.id,
            locationId: location?.id,
          );
        }
        return location;
      });

  Future<void> unlinkCustomer(int draftId) => _enqueue(
        () => KlantRollbackHelper.setDraftLinks(
          appDatabase: appDatabase,
          draftId: draftId,
          customerId: null,
          locationId: null,
        ),
      );
}
