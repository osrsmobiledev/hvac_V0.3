import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'address_lookup_results.dart';
import 'address_search_inputs.dart';

typedef AddressSearch = Future<BasisregistersResult> Function({
  required String straat,
  required String huisNummer,
  String? gemeente,
  String? postcode,
  String? bus,
});

/// Returns the explicitly accepted address to the caller via Navigator.
class AddressLookupDialog extends StatefulWidget {
  final String dialogTitle;
  final String initialStreet;
  final String initialHouseNumber;
  final String initialPostcode;
  final String initialMunicipality;
  final String initialBus;
  final bool autoSearch;
  final AddressSearch search;
  final Future<AddressMatch> Function(AddressMatch)? verifyInstallation;

  const AddressLookupDialog({
    super.key,
    this.dialogTitle = BasisregistersDictionary.lookupDialogTitle,
    required this.initialStreet,
    required this.initialHouseNumber,
    required this.initialPostcode,
    this.initialMunicipality = '',
    required this.initialBus,
    this.autoSearch = true,
    required this.search,
    this.verifyInstallation,
  });

  @override
  State<AddressLookupDialog> createState() => _AddressLookupDialogState();
}

class _AddressLookupDialogState extends State<AddressLookupDialog> {
  late final TextEditingController _street;
  late final TextEditingController _number;
  late final TextEditingController _postcode;
  late final TextEditingController _municipality;
  late final TextEditingController _bus;

  List<AddressMatch> _matches = [];
  AddressMatch? _selected;
  bool _loading = false;
  bool _verifying = false;
  bool _canRetryWithoutBus = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _street = TextEditingController(text: widget.initialStreet);
    _number = TextEditingController(text: widget.initialHouseNumber);
    _postcode = TextEditingController(text: widget.initialPostcode);
    _bus = TextEditingController(text: widget.initialBus);
    _municipality = TextEditingController(text: widget.initialMunicipality);
    if (widget.autoSearch &&
        [_street, _number, _postcode].every((c) => c.text.trim().isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search();
      });
    }
  }

  void _onQueryChanged() {
    _requestId++;
    setState(() {
      _matches = [];
      _selected = null;
      _loading = false;
      _verifying = false;
      _canRetryWithoutBus = false;
      _error = null;
    });
  }

  @override
  void dispose() {
    _street.dispose();
    _number.dispose();
    _postcode.dispose();
    _municipality.dispose();
    _bus.dispose();
    super.dispose();
  }

  Future<void> _search({bool ignoreBus = false}) async {
    if (_loading || _verifying) return;
    FocusScope.of(context).unfocus();
    final street = _street.text.trim();
    final number = _number.text.trim();
    final postcode = _postcode.text.trim();
    if (street.isEmpty || number.isEmpty || postcode.isEmpty) {
      setState(() =>
          _error = BasisregistersDictionary.lookupValidationRequiredFields);
      return;
    }

    final bus = ignoreBus ? '' : _bus.text.trim();
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
      _matches = [];
      _selected = null;
      _canRetryWithoutBus = false;
    });
    final result = await widget.search(
      straat: street,
      huisNummer: number,
      postcode: postcode,
      gemeente: _municipality.text.trim(),
      bus: bus,
    );
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _loading = false;
      _matches = result.matches;
      _selected = _matches.length == 1 ? _matches.single : null;
      _error = result.errorMessage;
      _canRetryWithoutBus = bus.isNotEmpty;
    });
  }

  Future<void> _confirm() async {
    final selected = _selected;
    if (selected == null || _verifying) return;
    final verify = widget.verifyInstallation;
    if (verify == null || selected.isEnriched) {
      Navigator.of(context).pop(selected);
      return;
    }

    final requestId = ++_requestId;
    setState(() => _verifying = true);
    final result = await verify(selected);
    // Closing the dialog or editing the query invalidates the result.
    if (!mounted ||
        requestId != _requestId ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return TacticalDialogWindow(
      title: widget.dialogTitle,
      maxWidth: 440,
      maxHeight: 590,
      onClose: () => Navigator.of(context).pop(),
      actions: TacticalDialogActions(
        cancelLabel: AppDictionary.btnCancel,
        confirmLabel: BasisregistersDictionary.lookupBtnConfirm,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: _selected == null || _verifying ? null : _confirm,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AddressSearchInputs(
                streetCtrl: _street,
                numberCtrl: _number,
                postcodeCtrl: _postcode,
                municipalityCtrl: _municipality,
                busCtrl: _bus,
                onSearch: _search,
                onChanged: _onQueryChanged,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loading || _verifying ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text(BasisregistersDictionary.lookupBtnSearch),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  foregroundColor: AppColors.amberGold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: AppColors.amberGoldBorder.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              if (_canRetryWithoutBus && !_verifying)
                TextButton(
                  onPressed: () => _search(ignoreBus: true),
                  child: const Text(
                      BasisregistersDictionary.lookupBtnSearchWithoutBus),
                ),
              if (_loading || _verifying) const LinearProgressIndicator(),
              if (_verifying)
                const Text(BasisregistersDictionary.lookupVerificationPending),
              if (_error case final error?)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error,
                      style: const TextStyle(color: AppColors.errorRed)),
                ),
              AddressLookupResults(
                matches: _matches,
                selected: _selected,
                onChanged: _verifying
                    ? null
                    : (match) => setState(() => _selected = match),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
