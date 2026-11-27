import 'package:flutter/material.dart';
import '../draft_save_scope.dart';
import 'package:hvac_app/app/localization/basisregisters_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'klant/klant_action_dialogs.dart';
import 'klant/klant_data_coordinator.dart';
import 'klant/klant_edit_session.dart';
import 'klant/klant_form_controllers.dart';
import 'klant/klant_tab_actions.dart';
import 'klant/klant_tab_body.dart';
import 'klant/klant_tab_state_data.dart';

class KlantTab extends StatefulWidget {
  final CustomerRepository? customerRepository;
  final DraftRepository? draftRepository;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;
  final String certificateType;
  const KlantTab(
      {super.key,
      this.customerRepository,
      this.draftRepository,
      this.onFormKeyReady,
      this.certificateType = 'verbranding'});
  @override
  State<KlantTab> createState() => _KlantTabState();
}

class _KlantTabState extends State<KlantTab>
    with AutomaticKeepAliveClientMixin {
  late final _coord = _createCoord();
  KlantDataCoordinator _createCoord() => KlantDataCoordinator(
        customerRepository: widget.customerRepository,
        draftRepository: widget.draftRepository,
      );
  final _controllers = KlantFormControllers();
  final _formKey = GlobalKey<FormState>();
  final _d = KlantTabStateData();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  bool _actionPending = false;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _debouncer.saveBlocked = () => _actionPending || _d.isEditing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFormKeyReady?.call(_formKey);
    });
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
      final data =
          await _coord.loadDraftData(certificateType: widget.certificateType);
      if (!mounted) return;
      setState(() {
        _d.draftVisitId = data.draftId;
        _d.populateFromData(data.customer, data.location, _controllers);
        final pending = data.pendingSession;
        if (pending != null) _d.resumeSession(pending);
      });
    } catch (error, stack) {
      debugPrint('[KlantTab] load error: $error\n$stack');
      if (mounted) setState(() => _d.isLoading = false);
    }
  }

  KlantFormDataSnapshot _captureForm() => KlantFormDataSnapshot.fromControllers(
        controllers: _controllers,
        role: _d.role,
        isSameAsCustomer: _d.isSameAsCustomer,
      );

  void _onFormChanged() {
    final draftId = _d.draftVisitId;
    if (!_d.isEditing || _actionPending || draftId == null) return;
    final snapshot = _captureForm();
    _debouncer.run(() => _autosave(draftId, snapshot));
  }

  Future<void> _autosave(int draftId, KlantFormDataSnapshot snapshot) async {
    try {
      final rows =
          await _coord.enqueueSave(draftId: draftId, snapshot: snapshot);
      if (rows == null || !mounted) return;
      setState(() {
        _d.activeCustomer = rows.customer;
        _d.activeLocation = rows.location;
      });
    } catch (error, stack) {
      debugPrint('[KlantTab] autosave error: $error\n$stack');
      if (mounted) {
        KlantActionDialogs.showErrorFeedback(
          context,
          BasisregistersDictionary.toastSaveFailed,
        );
      }
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_actionPending || _d.draftVisitId == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _actionPending = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _actionPending = false);
    }
  }

  Future<void> _search() => KlantTabActions.handleSearch(
        context: context,
        coordinator: _coord,
        draftVisitId: _d.draftVisitId,
        activeCustomer: _d.activeCustomer,
        onClear: () {
          if (mounted) setState(() => _d.clear(_controllers));
        },
        onSelected: (customer, location) => setState(
          () => _d.populateFromData(customer, location, _controllers),
        ),
      );
  Future<void> _newCustomer() async {
    if (!await KlantTabActions.confirmNew(context) || !mounted) return;
    _coord.startNewSession(
      draftId: _d.draftVisitId!,
      currentCustomer: _d.activeCustomer,
      currentLocation: _d.activeLocation,
      sameAsCustomer: _d.isSameAsCustomer,
    );
    setState(() {
      _d.takeSnapshot();
      _d.clear(_controllers);
      _d.isEditing = true;
    });
  }

  Future<void> _editCustomer() async {
    final customer = _d.activeCustomer;
    if (customer == null) return;
    if (!await KlantTabActions.confirmEdit(context) || !mounted) return;
    _coord.startEditSession(
      draftId: _d.draftVisitId!,
      currentCustomer: customer,
      currentLocation: _d.activeLocation,
      sameAsCustomer: _d.isSameAsCustomer,
    );
    setState(() {
      _d.takeSnapshot();
      _d.isEditing = true;
    });
  }

  Future<void> _save() => KlantTabActions.handleSave(
        context: context,
        formKey: _formKey,
        saveCallback: () async {
          _debouncer.cancel();
          final rows = await _coord.confirmSave(
            draftId: _d.draftVisitId!,
            snapshot: _captureForm(),
          );
          if (rows == null) return false;
          if (mounted) {
            _d.activeCustomer = rows.customer;
            _d.activeLocation = rows.location;
          }
          return true;
        },
        onSaved: () => setState(() => _d.isEditing = false),
      );
  Future<void> _cancel() => KlantTabActions.handleCancel(
        context: context,
        onCancel: () async {
          _debouncer.cancel();
          final success = await _coord.cancelSession(_d.draftVisitId!);
          if (success && mounted) {
            setState(() {
              _d.isEditing = false;
              _d.restoreSnapshot(_controllers);
            });
          }
          return success;
        },
      );
  Future<void> _delete() => KlantTabActions.handleDelete(
        context: context,
        onDelete: () async {
          try {
            await _coord.unlinkCustomer(_d.draftVisitId!);
            if (mounted) setState(() => _d.clear(_controllers));
          } catch (error, stack) {
            debugPrint('[KlantTab] unlink error: $error\n$stack');
            if (mounted) {
              KlantActionDialogs.showErrorFeedback(
                context,
                BasisregistersDictionary.toastSaveFailed,
              );
            }
          }
        },
      );
  @override
  Widget build(BuildContext context) {
    super.build(context);
    DraftSaveScope.of(context)?.register(_debouncer);
    if (_d.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }
    return AbsorbPointer(
      absorbing: _actionPending,
      child: Form(
        key: _formKey,
        child: KlantTabBody(
          isEditing: _d.isEditing,
          hasCustomer: _d.hasCustomer(_controllers),
          isSameAsCustomer: _d.isSameAsCustomer,
          controllers: _controllers,
          onFormChanged: _onFormChanged,
          onLookupSelected: (target, match) {
            if (!_d.isEditing || _actionPending) return;
            setState(() => _d.applyLookup(target, match, _controllers));
            _onFormChanged();
          },
          onSameAddressChanged: (value) => setState(() {
            _d.isSameAsCustomer = value;
            _onFormChanged();
          }),
          onSearch: () => _runAction(_search),
          onNew: () => _runAction(_newCustomer),
          onEdit: () => _runAction(_editCustomer),
          onSave: () => _runAction(_save),
          onCancel: () => _runAction(_cancel),
          onDelete: () => _runAction(_delete),
        ),
      ),
    );
  }
}
