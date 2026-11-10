import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/data/boiler_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import '../boiler_draft_notifier.dart';
import 'stooktoestel/fuel_category_memory.dart';
import 'stooktoestel/stooktoestel_form_controllers.dart';
import 'stooktoestel/stooktoestel_tab_body.dart';

/// Tab 5 (Stooktoestel) for Verbrandingsattest Vlaanderen.
class StooktoestelTab extends StatefulWidget {
  final BoilerDraftRepository? repository;
  final BoilerDraftNotifier? boilerNotifier;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const StooktoestelTab({
    super.key,
    this.repository,
    this.boilerNotifier,
    this.onFormKeyReady,
  });

  @override
  State<StooktoestelTab> createState() => _StooktoestelTabState();
}

class _StooktoestelTabState extends State<StooktoestelTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late final BoilerDraftRepository _repository;
  final StooktoestelFormControllers _controllers =
      StooktoestelFormControllers();
  final FuelCategoryMemory _fuelMemory = FuelCategoryMemory();
  final _debouncer = Debouncer();
  BoilerDraft _draft = BoilerDraft.initial();

  // Regulatory state
  bool _isCentral = false, _serialUnknown = false, _yearUnknown = false;
  bool _burnerSerialUnknown = false, _burnerYearUnknown = false;
  String _centraalType = '', _heatingType = '', _boilerOperation = '';
  String _fuelCategory = '', _fuelSubtype = '', _fuelOtherText = '';
  String _burnerTechnology = '', _burnerType = 'geintegreerd';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onFormKeyReady?.call(_formKey));
    _repository = widget.repository ?? BoilerDraftRepository();
    widget.boilerNotifier?.addListener(_onBoilerNotifierChanged);
    final initialDraft =
        (widget.boilerNotifier != null && !widget.boilerNotifier!.isLoading)
            ? widget.boilerNotifier!.draft
            : AppWarmupService.instance.cachedResult?.activeBoiler;
    if (initialDraft != null && widget.repository == null) {
      _applyDraftToUi(initialDraft);
    } else {
      _loadBoilerDraft();
    }
  }

  @override
  void didUpdateWidget(covariant StooktoestelTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boilerNotifier != widget.boilerNotifier) {
      oldWidget.boilerNotifier?.removeListener(_onBoilerNotifierChanged);
      widget.boilerNotifier?.addListener(_onBoilerNotifierChanged);
    }
  }

  @override
  void dispose() {
    widget.boilerNotifier?.removeListener(_onBoilerNotifierChanged);
    _debouncer.dispose();
    _controllers.dispose();
    super.dispose();
  }

  void _onBoilerNotifierChanged() {
    final notifier = widget.boilerNotifier;
    if (notifier == null || !mounted || notifier.isLoading) return;
    if (_draft != notifier.draft) _applyDraftToUi(notifier.draft);
  }

  void _applyDraftToUi(BoilerDraft d) {
    setState(() {
      _draft = d;
      _isCentral = d.isCentral;
      _centraalType = d.centraalType;
      _heatingType = d.heatingType;
      _boilerOperation = d.boilerOperation;
      _fuelCategory = d.fuelCategory;
      _fuelSubtype = d.fuelSubtype;
      _fuelOtherText = d.fuelOtherText;
      _fuelMemory.populateFrom(d);
      _burnerTechnology = d.burnerTechnology;
      _burnerType = d.burnerType.isNotEmpty ? d.burnerType : 'geintegreerd';
      _serialUnknown = d.boilerSerialNumberUnknown;
      _yearUnknown = d.boilerConstructionYearUnknown;
      _controllers.populateFrom(d);
    });
  }

  Future<void> _loadBoilerDraft() async {
    try {
      final notifier = widget.boilerNotifier;
      if (notifier != null) {
        if (!notifier.isLoading) _applyDraftToUi(notifier.draft);
        return;
      }
      final draft = await _repository.getOrCreateActiveBoiler();
      if (mounted) _applyDraftToUi(draft);
    } catch (e, stack) {
      debugPrint('[StooktoestelTab] _loadBoilerDraft error: $e\n$stack');
    }
  }

  void _syncDraft({bool immediate = false}) {
    final updated = _controllers.buildDraft(
      current: _draft,
      isCentral: _isCentral,
      centraalType: _centraalType,
      heatingType: _heatingType,
      boilerOperation: _boilerOperation,
      fuelCategory: _fuelCategory,
      fuelSubtype: _fuelSubtype,
      fuelOtherText: _fuelOtherText,
      burnerTechnology: _burnerTechnology,
      boilerSerialUnknown: _serialUnknown,
      boilerYearUnknown: _yearUnknown,
      burnerType: _burnerType,
    );
    _draft = updated;
    if (widget.boilerNotifier != null) {
      widget.boilerNotifier!.updateDraft(updated, immediateSave: immediate);
      return;
    }
    if (immediate) {
      _debouncer.cancel();
      _saveDraftDirect(updated);
    } else {
      _debouncer.run(() => _saveDraftDirect(updated));
    }
  }

  Future<void> _saveDraftDirect(BoilerDraft draft) async {
    try {
      await _repository.saveBoilerDraft(draft);
    } catch (e, stack) {
      debugPrint('[StooktoestelTab] _saveDraftDirect error: $e\n$stack');
    }
  }

  void _update(VoidCallback fn) {
    setState(fn);
    _syncDraft(immediate: false);
  }

  void _onFuelCat(String val) => _update(() {
        _fuelCategory = val;
        final (sub, other) = _fuelMemory.resolveForCategory(val);
        _fuelSubtype = sub;
        _fuelOtherText = other;
        _burnerType = (val == 'vloeibaar' ||
                (val == 'gas' && _burnerTechnology == 'ventilatorbrander'))
            ? 'afzonderlijk'
            : 'geintegreerd';
      });

  void _onFuelSubtype(String val) => _update(() {
        _fuelSubtype = val;
        _fuelMemory.onSubtype(_fuelCategory, val);
      });

  void _onFuelOtherText(String v) {
    _fuelOtherText = v;
    _fuelMemory.onOtherText(_fuelCategory, v);
    _syncDraft(immediate: false);
  }

  void _onBurnerTech(String val) => _update(() {
        _burnerTechnology = val;
        if (val == 'ventilatorbrander') {
          _burnerType = 'afzonderlijk';
        } else if (_fuelCategory == 'gas') {
          _burnerType = 'geintegreerd';
        }
      });

  void _scanBarcode() => TacticalFeedback.showInfo(
      context, AppDictionary.barcodeScannerPlaceholder);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: StooktoestelTabBody(
        controllers: _controllers,
        isCentral: _isCentral,
        centraalType: _centraalType,
        heatingType: _heatingType,
        boilerOperation: _boilerOperation,
        fuelCategory: _fuelCategory,
        fuelSubtype: _fuelSubtype,
        fuelOtherText: _fuelOtherText,
        burnerTechnology: _burnerTechnology,
        burnerType: _burnerType,
        serialUnknown: _serialUnknown,
        yearUnknown: _yearUnknown,
        burnerSerialUnknown: _burnerSerialUnknown,
        burnerYearUnknown: _burnerYearUnknown,
        onCentralChanged: (v) => _update(
            () => _centraalType = (_isCentral = v) ? _centraalType : ''),
        onCentraalTypeChanged: (val) => _update(() {
          _centraalType = (_centraalType == val && _isCentral) ? '' : val;
          _isCentral = _centraalType.isNotEmpty;
        }),
        onHeatingTypeChanged: (val) => _update(() => _heatingType = val),
        onBoilerOperationChanged: (val) =>
            _update(() => _boilerOperation = val),
        onFuelCategoryChanged: _onFuelCat,
        onFuelSubtypeChanged: _onFuelSubtype,
        onFuelOtherTextChanged: _onFuelOtherText,
        onBurnerTechChanged: _onBurnerTech,
        onBurnerTypeChanged: (val) => _update(() => _burnerType = val),
        onTypeBCodeChanged: (_) => _syncDraft(immediate: true),
        onTypeCCodeChanged: (_) => _syncDraft(immediate: true),
        onSerialUnknownChanged: (val) => _update(() => _serialUnknown = val),
        onYearUnknownChanged: (val) => _update(() => _yearUnknown = val),
        onBurnerSerialUnknownChanged: (v) =>
            _update(() => _burnerSerialUnknown = v),
        onBurnerYearUnknownChanged: (v) =>
            _update(() => _burnerYearUnknown = v),
        onScanToestelBarcode: _scanBarcode,
        onScanBranderBarcode: _scanBarcode,
        onFormChanged: () => _syncDraft(immediate: false),
      ),
    );
  }
}
