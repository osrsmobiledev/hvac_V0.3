import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant/customer_search_modal.dart';
import 'klant/klant_action_dialogs.dart';
import 'klant/klant_data_coordinator.dart';
import 'klant/klant_form_controllers.dart';
import 'klant/klant_tab_body.dart';

/// Tab 4 — Klant & Installatieadres
/// Features top tactical 4-button action bar (Zoeken, Nieuw, Bewerken/Opslaan, Wissen/Annuleren).
class KlantTab extends StatefulWidget {
  final CustomerRepository? customerRepository;
  final DraftRepository? draftRepository;

  const KlantTab({super.key, this.customerRepository, this.draftRepository});

  @override
  State<KlantTab> createState() => _KlantTabState();
}

class _KlantTabState extends State<KlantTab>
    with AutomaticKeepAliveClientMixin {
  late final KlantDataCoordinator _coord;
  final _controllers = KlantFormControllers();

  Customer? _activeCustomer;
  ServiceLocation? _activeLocation;
  KlantFormSnapshot? _snapshot;
  String _role = 'owner';
  bool _isSameAsCustomer = true;
  int? _draftVisitId;
  bool _isEditing = false;
  bool _isLoading = true;
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  bool get _hasCustomer =>
      _activeCustomer != null ||
      _controllers.lastName.text.trim().isNotEmpty ||
      _controllers.company.text.trim().isNotEmpty;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _coord = KlantDataCoordinator(
      customerRepository: widget.customerRepository,
      draftRepository: widget.draftRepository,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final res = await _coord.loadDraftData();
      _draftVisitId = res.draftId;
      if (res.customer != null && mounted) {
        setState(() => _activeCustomer = res.customer);
        _controllers.populateCustomer(res.customer!);
      }
      if (res.location != null && mounted) _applyLocation(res.location!);
      if (mounted) setState(() => _isLoading = false);
    } catch (e, stack) {
      debugPrint('[KlantTab] _loadInitialData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyLocation(ServiceLocation loc, [String? street, String? nr]) {
    setState(() {
      _activeLocation = loc;
      _role = loc.role;
      _isSameAsCustomer =
          !(loc.street != (street ?? _controllers.street.text) ||
              loc.houseNumber != (nr ?? _controllers.houseNumber.text));
      _controllers.populateLocation(loc);
    });
  }

  void _onFormChanged() {
    _debouncer.run(_saveToDatabase);
  }

  Future<void> _saveToDatabase() async {
    try {
      final draftId = _draftVisitId ?? (await _coord.loadDraftData()).draftId;
      _draftVisitId = draftId;
      final res = await _coord.saveFromControllers(
        draftId: draftId,
        controllers: _controllers,
        activeCustomer: _activeCustomer,
        activeLocation: _activeLocation,
        role: _role,
        isSameAsCustomer: _isSameAsCustomer,
      );
      if (res != null && mounted) {
        setState(() {
          _activeCustomer = res.customer;
          _activeLocation = res.location;
        });
      }
    } catch (e, stack) {
      debugPrint('[KlantTab] _saveToDatabase error: $e\n$stack');
    }
  }

  Future<void> _onSearchPressed() async {
    final picked = await CustomerSearchModal.show(
      context,
      repository: _coord.customerRepo,
      onCustomerDeleted: (deletedId) {
        if (_activeCustomer?.id == deletedId) _clearCustomerForm();
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _activeCustomer = picked;
        _controllers.populateCustomer(picked);
        _isEditing = false;
      });
      try {
        final loc = await _coord.linkPickedCustomer(
          draftId: _draftVisitId,
          customer: picked,
        );
        if (loc != null && mounted) {
          _applyLocation(loc, picked.street, picked.houseNumber);
        }
      } catch (e, stack) {
        debugPrint('[KlantTab] linkPickedCustomer error: $e\n$stack');
      }
    }
  }

  Future<void> _onNewPressed() async {
    if (await KlantActionDialogs.confirmNewCustomer(context) && mounted) {
      _takeSnapshot();
      _clearCustomerForm();
      setState(() => _isEditing = true);
    }
  }

  Future<void> _onEditPressed() async {
    if (await KlantActionDialogs.confirmEditCustomer(context) && mounted) {
      _takeSnapshot();
      setState(() => _isEditing = true);
    }
  }

  Future<void> _onSavePressed() async {
    await _saveToDatabase();
    if (mounted) {
      setState(() => _isEditing = false);
      KlantActionDialogs.showSavedFeedback(context);
    }
  }

  Future<void> _onCancelPressed() async {
    if (await KlantActionDialogs.confirmCancelEdit(context) && mounted) {
      setState(() {
        _restoreSnapshot();
        _isEditing = false;
      });
    }
  }

  Future<void> _onDeletePressed() async {
    if (await KlantActionDialogs.confirmDeleteCustomer(context) && mounted) {
      _clearCustomerForm();
      setState(() => _isEditing = false);
    }
  }

  void _takeSnapshot() => _snapshot = KlantFormSnapshot(
        customer: _activeCustomer,
        location: _activeLocation,
        role: _role,
        isSameAsCustomer: _isSameAsCustomer,
      );

  void _restoreSnapshot() {
    _activeCustomer = _snapshot?.customer;
    _activeLocation = _snapshot?.location;
    _role = _snapshot?.role ?? 'owner';
    _isSameAsCustomer = _snapshot?.isSameAsCustomer ?? true;
    _snapshot?.restoreInto(_controllers);
  }

  Future<void> _clearCustomerForm() async {
    setState(() {
      _activeCustomer = null;
      _activeLocation = null;
      _controllers.clearAll();
      _role = 'owner';
      _isSameAsCustomer = true;
    });
    if (_draftVisitId != null) {
      try {
        await _coord.unlinkCustomer(_draftVisitId!);
      } catch (e, stack) {
        debugPrint('[KlantTab] unlinkCustomer error: $e\n$stack');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.amberGold));
    }
    return KlantTabBody(
      isEditing: _isEditing,
      hasCustomer: _hasCustomer,
      isSameAsCustomer: _isSameAsCustomer,
      controllers: _controllers,
      onFormChanged: _onFormChanged,
      onSameAddressChanged: (s) {
        setState(() => _isSameAsCustomer = s);
        _onFormChanged();
      },
      onSearch: _onSearchPressed,
      onNew: _onNewPressed,
      onEdit: _onEditPressed,
      onSave: _onSavePressed,
      onCancel: _onCancelPressed,
      onDelete: _onDeletePressed,
    );
  }
}
