import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'klant/klant_data_coordinator.dart';
import 'klant/klant_form_controllers.dart';
import 'klant/klant_tab_actions.dart';
import 'klant/klant_tab_body.dart';
import 'klant/klant_tab_state_data.dart';

/// Tab 4 — Klant & Installatieadres
class KlantTab extends StatefulWidget {
  final CustomerRepository? customerRepository;
  final DraftRepository? draftRepository;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const KlantTab({
    super.key,
    this.customerRepository,
    this.draftRepository,
    this.onFormKeyReady,
  });

  @override
  State<KlantTab> createState() => _KlantTabState();
}

class _KlantTabState extends State<KlantTab>
    with AutomaticKeepAliveClientMixin {
  late final KlantDataCoordinator _coord = KlantDataCoordinator(
    customerRepository: widget.customerRepository,
    draftRepository: widget.draftRepository,
  );
  final _controllers = KlantFormControllers();
  final _formKey = GlobalKey<FormState>();
  final _d = KlantTabStateData();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
    final c = AppWarmupService.instance.cachedResult;
    if (c?.activeDraft != null &&
        widget.customerRepository == null &&
        widget.draftRepository == null) {
      _d.draftVisitId = c!.activeDraft!.id;
      _populateFromData(c.activeCustomer, c.activeServiceLocation);
    } else {
      _loadInitialData();
    }
  }

  void _populateFromData(Customer? customer, ServiceLocation? location) {
    if (customer != null) {
      _controllers.populateCustomer(_d.activeCustomer = customer);
    }
    if (location != null) {
      _d.applyLocation(location, _controllers);
    }
    _d.isLoading = false;
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
      _d.draftVisitId = res.draftId;
      if (mounted) {
        setState(() => _populateFromData(res.customer, res.location));
      }
    } catch (e, stack) {
      debugPrint('[KlantTab] _loadInitialData error: $e\n$stack');
      if (mounted) setState(() => _d.isLoading = false);
    }
  }

  void _onFormChanged() => _debouncer.run(_saveToDatabase);

  Future<void> _saveToDatabase() async {
    try {
      final draftId = _d.draftVisitId ?? (await _coord.loadDraftData()).draftId;
      _d.draftVisitId = draftId;
      final res = await _coord.saveFromControllers(
        draftId: draftId,
        controllers: _controllers,
        activeCustomer: _d.activeCustomer,
        activeLocation: _d.activeLocation,
        role: _d.role,
        isSameAsCustomer: _d.isSameAsCustomer,
      );
      if (res != null && mounted) {
        setState(() {
          _d.activeCustomer = res.customer;
          _d.activeLocation = res.location;
        });
      }
    } catch (e, stack) {
      debugPrint('[KlantTab] _saveToDatabase error: $e\n$stack');
    }
  }

  Future<void> _onSearchPressed() async {
    await KlantTabActions.handleSearch(
      context: context,
      coordinator: _coord,
      controllers: _controllers,
      draftVisitId: _d.draftVisitId,
      activeCustomer: _d.activeCustomer,
      onClear: _clearCustomerForm,
      onSelected: (picked, loc) {
        setState(() {
          _d.activeCustomer = picked;
          _d.isEditing = false;
        });
        if (loc != null) {
          setState(() => _d.applyLocation(
                loc,
                _controllers,
                picked.street,
                picked.houseNumber,
              ));
        }
      },
    );
  }

  Future<void> _onNewPressed() async {
    if (!await KlantTabActions.confirmNew(context) || !mounted) return;
    _d.takeSnapshot();
    _clearCustomerForm();
    setState(() => _d.isEditing = true);
  }

  Future<void> _onEditPressed() async {
    if (!await KlantTabActions.confirmEdit(context) || !mounted) return;
    _d.takeSnapshot();
    setState(() => _d.isEditing = true);
  }

  Future<void> _onSavePressed() => KlantTabActions.handleSave(
        context: context,
        formKey: _formKey,
        saveCallback: _saveToDatabase,
        onSaved: () => setState(() => _d.isEditing = false),
      );

  Future<void> _onCancelPressed() => KlantTabActions.handleCancel(
        context: context,
        onCancel: () => setState(() {
          _d.restoreSnapshot(_controllers);
          _d.isEditing = false;
        }),
      );

  Future<void> _onDeletePressed() => KlantTabActions.handleDelete(
        context: context,
        onDelete: () {
          _clearCustomerForm();
          setState(() => _d.isEditing = false);
        },
      );

  void _clearCustomerForm() {
    setState(() => _d.clear(_controllers));
    if (_d.draftVisitId != null) {
      _coord.unlinkCustomer(_d.draftVisitId!).catchError(
            (e, s) => debugPrint('[KlantTab] unlink error: $e\n$s'),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_d.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.amberGold));
    }
    return Form(
      key: _formKey,
      child: KlantTabBody(
        isEditing: _d.isEditing,
        hasCustomer: _d.hasCustomer(_controllers),
        isSameAsCustomer: _d.isSameAsCustomer,
        controllers: _controllers,
        onFormChanged: _onFormChanged,
        onSameAddressChanged: (s) => setState(() {
          _d.isSameAsCustomer = s;
          _onFormChanged();
        }),
        onSearch: _onSearchPressed,
        onNew: _onNewPressed,
        onEdit: _onEditPressed,
        onSave: _onSavePressed,
        onCancel: _onCancelPressed,
        onDelete: _onDeletePressed,
      ),
    );
  }
}
