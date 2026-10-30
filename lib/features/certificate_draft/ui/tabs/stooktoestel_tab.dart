import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/data/boiler_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import '../boiler_draft_notifier.dart';
import 'stooktoestel/stooktoestel_form_controllers.dart';
import 'stooktoestel/stooktoestel_tab_body.dart';

/// Tab 5 (Stooktoestel) for Verbrandingsattest Vlaanderen.
class StooktoestelTab extends StatefulWidget {
  final BoilerDraftRepository? repository;
  final BoilerDraftNotifier? boilerNotifier;

  const StooktoestelTab({
    super.key,
    this.repository,
    this.boilerNotifier,
  });

  @override
  State<StooktoestelTab> createState() => _StooktoestelTabState();
}

class _StooktoestelTabState extends State<StooktoestelTab>
    with AutomaticKeepAliveClientMixin {
  late final BoilerDraftRepository _repository;
  final StooktoestelFormControllers _controllers =
      StooktoestelFormControllers();

  final _debouncer = Debouncer();
  BoilerDraft _draft = BoilerDraft.initial();

  // Regulatory state
  bool _isCentral = true, _serialUnknown = false, _yearUnknown = false;
  bool _burnerSerialUnknown = false, _burnerYearUnknown = false;
  String _centraalType = 'C', _heatingType = 'individueel';
  String _boilerOperation = 'condenserend', _fuelCategory = 'gas';
  String _fuelSubtype = 'aardgas', _fuelOtherText = '';
  String _burnerTechnology = 'premix', _burnerType = 'geintegreerd';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BoilerDraftRepository();
    widget.boilerNotifier?.addListener(_onBoilerNotifierChanged);
    _loadBoilerDraft();
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
    if (_draft != notifier.draft) {
      _applyDraftToUi(notifier.draft);
    }
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
        if (!notifier.isLoading) {
          _applyDraftToUi(notifier.draft);
        }
        return;
      }
      final draft = await _repository.getOrCreateActiveBoiler();
      if (!mounted) return;
      _applyDraftToUi(draft);
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

  void _onBoilerOp(String val) => _update(() {
        _boilerOperation = val;
        if (_burnerTechnology != 'ventilatorbrander') {
          _burnerTechnology = val == 'condenserend' ? 'premix' : 'niet_premix';
        }
      });

  void _onFuelCat(String val) => _update(() {
        _fuelCategory = val;
        if (val == 'gas') {
          _fuelSubtype = 'aardgas';
          _burnerType = _burnerTechnology == 'ventilatorbrander'
              ? 'afzonderlijk'
              : 'geintegreerd';
        } else if (val == 'vloeibaar') {
          _burnerType = 'afzonderlijk';
        } else if (val == 'vast') {
          _fuelSubtype = 'houtpellets';
        }
      });

  void _onBurnerTech(String val) => _update(() {
        _burnerTechnology = val;
        if (val == 'ventilatorbrander') {
          _burnerType = 'afzonderlijk';
        } else if (_fuelCategory == 'gas') {
          _burnerType = 'geintegreerd';
        }
      });

  void _onFormChanged() => _syncDraft(immediate: false);

  void _scanBarcode(TextEditingController target, String title) {
    TacticalFeedback.showInfo(
      context,
      AppDictionary.barcodeScannerPlaceholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StooktoestelTabBody(
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
      onCentralChanged: (val) => _update(() => _isCentral = val),
      onCentraalTypeChanged: (val) => _update(() => _centraalType = val),
      onHeatingTypeChanged: (val) => _update(() => _heatingType = val),
      onBoilerOperationChanged: _onBoilerOp,
      onFuelCategoryChanged: _onFuelCat,
      onFuelSubtypeChanged: (val) => _update(() => _fuelSubtype = val),
      onFuelOtherTextChanged: (val) {
        _fuelOtherText = val;
        _onFormChanged();
      },
      onBurnerTechChanged: _onBurnerTech,
      onBurnerTypeChanged: (val) => _update(() => _burnerType = val),
      onTypeBCodeChanged: (_) => _syncDraft(immediate: true),
      onTypeCCodeChanged: (_) => _syncDraft(immediate: true),
      onSerialUnknownChanged: (val) => _update(() => _serialUnknown = val),
      onYearUnknownChanged: (val) => _update(() => _yearUnknown = val),
      onBurnerSerialUnknownChanged: (val) =>
          _update(() => _burnerSerialUnknown = val),
      onBurnerYearUnknownChanged: (val) =>
          _update(() => _burnerYearUnknown = val),
      onScanToestelBarcode: () => _scanBarcode(
        _controllers.toestelSerial,
        AppDictionary.hintScanToestelSerial,
      ),
      onScanBranderBarcode: () => _scanBarcode(
        _controllers.branderSerial,
        AppDictionary.hintScanBranderSerial,
      ),
      onFormChanged: _onFormChanged,
    );
  }
}
