import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant/customer_details_card.dart';
import 'klant/customer_search_modal.dart';
import 'klant/installation_location_card.dart';
import 'klant/klant_form_controllers.dart';

/// Tab 4 — Klant & Installatieadres
/// Handles customer details, owner/tenant role, installation address, and autosave.
class KlantTab extends StatefulWidget {
  final CustomerRepository? customerRepository;
  final DraftRepository? draftRepository;

  const KlantTab({
    super.key,
    this.customerRepository,
    this.draftRepository,
  });

  @override
  State<KlantTab> createState() => _KlantTabState();
}

class _KlantTabState extends State<KlantTab>
    with AutomaticKeepAliveClientMixin {
  late final CustomerRepository _customerRepo;
  late final DraftRepository _draftRepo;
  final _controllers = KlantFormControllers();

  Customer? _activeCustomer;
  ServiceLocation? _activeLocation;
  int? _draftVisitId;
  String _role = 'owner';
  bool _isSameAsCustomer = true;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _customerRepo = widget.customerRepository ?? CustomerRepository();
    _draftRepo = widget.draftRepository ?? DraftRepository();
    _loadDraftCustomerData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadDraftCustomerData() async {
    try {
      final draft = await _draftRepo.getOrCreateActiveDraft();
      _draftVisitId = draft.id;

      if (draft.customerId != null) {
        final customer = await _customerRepo.getCustomerById(draft.customerId!);
        if (customer != null && mounted) {
          setState(() {
            _activeCustomer = customer;
            _controllers.populateCustomer(customer);
          });
        }
      }

      if (draft.serviceLocationId != null) {
        final locations =
            await _customerRepo.getLocationsForCustomer(draft.customerId ?? 0);
        final location =
            locations.where((l) => l.id == draft.serviceLocationId).firstOrNull;
        if (location != null && mounted) {
          setState(() {
            _activeLocation = location;
            _role = location.role;
            final isDiff = location.street != _controllers.street.text ||
                location.houseNumber != _controllers.houseNumber.text;
            _isSameAsCustomer = !isDiff;
            _controllers.populateLocation(location);
          });
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e, stack) {
      // Log unexpected DB errors; form stays empty but the user is not blocked.
      debugPrint('[KlantTab] _loadDraftCustomerData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFormChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveToDatabase);
  }

  Future<void> _saveToDatabase() async {
    final lastName = _controllers.lastName.text.trim();
    final company = _controllers.company.text.trim();
    if (lastName.isEmpty && company.isEmpty) return;

    try {
      final customerToSave = _controllers.toCustomer(
        id: _activeCustomer?.id,
        createdAt: _activeCustomer?.createdAt,
      );
      final locationToSave = _controllers.toLocation(
        id: _activeLocation?.id,
        customerId: _activeCustomer?.id ?? 0,
        role: _role,
        isSameAsCustomer: _isSameAsCustomer,
        createdAt: _activeLocation?.createdAt,
      );

      final draftId =
          _draftVisitId ?? (await _draftRepo.getOrCreateActiveDraft()).id;
      _draftVisitId = draftId;

      final result = await _customerRepo.saveCustomerWithLocation(
        customer: customerToSave,
        location: locationToSave,
        visitId: draftId,
      );
      _activeCustomer = result.customer;
      _activeLocation = result.location;
    } catch (e, stack) {
      // Autosave errors are logged but not surfaced to avoid interrupting the user.
      debugPrint('[KlantTab] _saveToDatabase error: $e\n$stack');
    }
  }

  Future<void> _pickCustomer() async {
    final picked =
        await CustomerSearchModal.show(context, repository: _customerRepo);
    if (picked != null && mounted) {
      setState(() {
        _activeCustomer = picked;
        _controllers.populateCustomer(picked);
      });
      final location =
          await _customerRepo.getPrimaryLocationForCustomer(picked.id!);
      if (location != null && mounted) {
        setState(() {
          _activeLocation = location;
          _role = location.role;
          final isDiff = location.street != picked.street ||
              location.houseNumber != picked.houseNumber;
          _isSameAsCustomer = !isDiff;
          _controllers.populateLocation(location);
        });
      }
      final draftId =
          _draftVisitId ?? (await _draftRepo.getOrCreateActiveDraft()).id;
      _draftVisitId = draftId;

      await _draftRepo.updateVisitCustomer(
        visitId: draftId,
        customerId: picked.id,
        serviceLocationId: location?.id,
      );
    }
  }

  void _clearCustomerForm() {
    setState(() {
      _activeCustomer = null;
      _activeLocation = null;
      _controllers.clearAll();
      _role = 'owner';
      _isSameAsCustomer = true;
    });
    if (_draftVisitId != null) {
      _draftRepo.updateVisitCustomer(
        visitId: _draftVisitId!,
        customerId: null,
        serviceLocationId: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey<String>('klant_tab_scroll'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              CustomerDetailsCard(
                controllers: _controllers,
                onChooseCustomer: _pickCustomer,
                onNewCustomer: _clearCustomerForm,
                onChanged: _onFormChanged,
              ),
              const SizedBox(height: 14),
              InstallationLocationCard(
                controllers: _controllers,
                role: _role,
                onRoleChanged: (newRole) {
                  setState(() => _role = newRole);
                  _onFormChanged();
                },
                isSameAsCustomer: _isSameAsCustomer,
                onSameAddressChanged: (val) {
                  setState(() => _isSameAsCustomer = val);
                  _onFormChanged();
                },
                onChanged: _onFormChanged,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
