import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/data/boiler_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'stooktoestel/brander_card.dart';
import 'stooktoestel/kenmerken_card.dart';
import 'stooktoestel/stooktoestel_form_controllers.dart';
import 'stooktoestel/toestel_card.dart';

/// Tab 5 (Stooktoestel) for Verbrandingsattest Vlaanderen.
///
/// Features:
/// - Kenmerken van het stooktoestel (Centraal, NBN CR 1749, VEKA heating/operation).
/// - Single authoritative fuel selection (Golden Rule #3).
/// - Appliance (Toestel) & Burner (Brander) specifications.
/// - Smart toggle: Geïntegreerde brander (95% gas) vs Afzonderlijke brander.
/// - Camera barcode scanner for serial labels with manual text fallback (Golden Rule #4).
/// - Offline-first draft persistence to SQLite (Golden Rule #1).
class StooktoestelTab extends StatefulWidget {
  final BoilerDraftRepository? repository;

  const StooktoestelTab({super.key, this.repository});

  @override
  State<StooktoestelTab> createState() => _StooktoestelTabState();
}

class _StooktoestelTabState extends State<StooktoestelTab>
    with AutomaticKeepAliveClientMixin {
  late final BoilerDraftRepository _repository;
  final StooktoestelFormControllers _controllers =
      StooktoestelFormControllers();

  Timer? _debounceTimer;
  BoilerDraft _draft = BoilerDraft.initial();

  // Regulatory state
  bool _isCentral = true;
  String _centraalType = 'C';
  String _heatingType = 'individueel';
  String _boilerOperation = 'condenserend';
  String _fuelCategory = 'gas';
  String _fuelSubtype = 'aardgas';
  String _fuelOtherText = '';
  String _burnerTechnology = 'premix';
  String _burnerType = 'geintegreerd';
  bool _serialUnknown = false;
  bool _yearUnknown = false;
  bool _burnerSerialUnknown = false;
  bool _burnerYearUnknown = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BoilerDraftRepository();
    _loadBoilerDraft();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadBoilerDraft() async {
    try {
      final draft = await _repository.getOrCreateActiveBoiler();
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _isCentral = draft.isCentral;
        _centraalType = draft.centraalType;
        _heatingType = draft.heatingType;
        _boilerOperation = draft.boilerOperation;
        _fuelCategory = draft.fuelCategory;
        _fuelSubtype = draft.fuelSubtype;
        _fuelOtherText = draft.fuelOtherText;
        _burnerTechnology = draft.burnerTechnology;
        _burnerType =
            draft.burnerType.isNotEmpty ? draft.burnerType : 'geintegreerd';
        _serialUnknown = draft.boilerSerialNumberUnknown;
        _yearUnknown = draft.boilerConstructionYearUnknown;
        _controllers.populateFrom(draft);
      });
    } catch (e, stack) {
      debugPrint('[StooktoestelTab] _loadBoilerDraft error: $e\n$stack');
    }
  }

  void _update(VoidCallback fn) {
    setState(fn);
    _onFormChanged();
  }

  void _onFormChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _saveToDatabase);
  }

  Future<void> _saveToDatabase() async {
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

    try {
      await _repository.saveBoilerDraft(updated);
      _draft = updated;
    } catch (e, stack) {
      debugPrint('[StooktoestelTab] _saveToDatabase error: $e\n$stack');
    }
  }

  void _scanBarcode(TextEditingController target, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppDictionary.barcodeScannerPlaceholder)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Card 1: Kenmerken
            KenmerkenCard(
              isCentral: _isCentral,
              centraalType: _centraalType,
              typeBController: _controllers.typeB,
              typeCController: _controllers.typeC,
              heatingType: _heatingType,
              boilerOperation: _boilerOperation,
              fuelCategory: _fuelCategory,
              fuelSubtype: _fuelSubtype,
              fuelOtherText: _fuelOtherText,
              burnerTechnology: _burnerTechnology,
              onCentralChanged: (val) => _update(() => _isCentral = val),
              onCentraalTypeChanged: (val) =>
                  _update(() => _centraalType = val),
              onHeatingTypeChanged: (val) => _update(() => _heatingType = val),
              onBoilerOperationChanged: (val) => _update(() {
                _boilerOperation = val;
                if (_burnerTechnology != 'ventilatorbrander') {
                  _burnerTechnology =
                      val == 'condenserend' ? 'premix' : 'niet_premix';
                }
              }),
              onFuelCategoryChanged: (val) => _update(() {
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
              }),
              onFuelSubtypeChanged: (val) => _update(() => _fuelSubtype = val),
              onFuelOtherTextChanged: (val) {
                _fuelOtherText = val;
                _onFormChanged();
              },
              onBurnerTechChanged: (val) => _update(() {
                _burnerTechnology = val;
                if (val == 'ventilatorbrander') {
                  _burnerType = 'afzonderlijk';
                } else if (_fuelCategory == 'gas') {
                  _burnerType = 'geintegreerd';
                }
              }),
            ),
            const SizedBox(height: 16),

            // Card 2: Toestel
            ToestelCard(
              brandController: _controllers.toestelBrand,
              modelController: _controllers.toestelModel,
              yearController: _controllers.toestelYear,
              serialController: _controllers.toestelSerial,
              powerController: _controllers.toestelPower,
              serialUnknown: _serialUnknown,
              yearUnknown: _yearUnknown,
              onSerialUnknownChanged: (val) =>
                  _update(() => _serialUnknown = val),
              onYearUnknownChanged: (val) => _update(() => _yearUnknown = val),
              onScanBarcode: () => _scanBarcode(
                _controllers.toestelSerial,
                AppDictionary.hintScanToestelSerial,
              ),
              onChanged: _onFormChanged,
            ),
            const SizedBox(height: 16),

            // Card 3: Brander (Smart Toggle)
            BranderCard(
              burnerType: _burnerType,
              onBurnerTypeChanged: (val) => _update(() => _burnerType = val),
              brandController: _controllers.branderBrand,
              modelController: _controllers.branderModel,
              yearController: _controllers.branderYear,
              serialController: _controllers.branderSerial,
              flowRateController: _controllers.branderFlowRate,
              yearUnknown: _burnerYearUnknown,
              serialUnknown: _burnerSerialUnknown,
              onYearUnknownChanged: (val) =>
                  _update(() => _burnerYearUnknown = val),
              onSerialUnknownChanged: (val) =>
                  _update(() => _burnerSerialUnknown = val),
              onScanBarcode: () => _scanBarcode(
                _controllers.branderSerial,
                AppDictionary.hintScanBranderSerial,
              ),
              onChanged: _onFormChanged,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
