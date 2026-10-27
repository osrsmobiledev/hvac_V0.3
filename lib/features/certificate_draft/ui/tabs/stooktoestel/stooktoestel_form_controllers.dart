import 'package:flutter/material.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';

/// Encapsulates the TextEditingControllers used throughout the Stooktoestel form.
class StooktoestelFormControllers {
  // Centraal
  final TextEditingController typeB = TextEditingController();
  final TextEditingController typeC = TextEditingController();

  // Toestel
  final TextEditingController toestelBrand = TextEditingController();
  final TextEditingController toestelModel = TextEditingController();
  final TextEditingController toestelYear = TextEditingController();
  final TextEditingController toestelSerial = TextEditingController();
  final TextEditingController toestelPower = TextEditingController();

  // Brander
  final TextEditingController branderBrand = TextEditingController();
  final TextEditingController branderModel = TextEditingController();
  final TextEditingController branderYear = TextEditingController();
  final TextEditingController branderSerial = TextEditingController();
  final TextEditingController branderFlowRate = TextEditingController();

  /// Strips the statutory leading letter prefix for display in the prefixed input box.
  static String stripPrefix(String val, String prefix) {
    final trimmed = val.trim();
    if (trimmed.toUpperCase().startsWith(prefix.toUpperCase())) {
      return trimmed.substring(prefix.length).trim();
    }
    return trimmed;
  }

  /// Formats the entered subtype digits back to full statutory code (e.g. '11' -> 'B11').
  String formatFullType(String prefix) {
    final raw = (prefix == 'B' ? typeB : typeC).text.trim().toUpperCase();
    if (raw.isEmpty) return '';
    if (raw.startsWith(prefix.toUpperCase())) return raw;
    return '$prefix$raw';
  }

  /// Populates all text controllers from a [BoilerDraft] model.
  void populateFrom(BoilerDraft draft) {
    typeB.text = stripPrefix(draft.typeBText, 'B');
    typeC.text = stripPrefix(draft.typeCText, 'C');
    toestelBrand.text = draft.boilerBrand;
    toestelModel.text = draft.boilerModel;
    toestelYear.text = draft.boilerConstructionYear?.toString() ?? '';
    toestelSerial.text = draft.boilerSerialNumber;
    toestelPower.text = draft.boilerNominalPowerKw?.toString() ?? '';
    branderBrand.text = draft.burnerBrand;
    branderModel.text = draft.burnerModel;
    branderYear.text = draft.burnerConstructionYear?.toString() ?? '';
    branderSerial.text = draft.burnerSerialNumber;
    branderFlowRate.text = draft.burnerFlowRate;
  }

  /// Builds a [BoilerDraft] entity combining active controller values with state.
  BoilerDraft buildDraft({
    required BoilerDraft current,
    required bool isCentral,
    required String centraalType,
    required String heatingType,
    required String boilerOperation,
    required String fuelCategory,
    required String fuelSubtype,
    required String fuelOtherText,
    required String burnerTechnology,
    required bool boilerSerialUnknown,
    required bool boilerYearUnknown,
    required String burnerType,
  }) {
    return current.copyWith(
      isCentral: isCentral,
      centraalType: centraalType,
      typeBText: formatFullType('B'),
      typeCText: formatFullType('C'),
      heatingType: heatingType,
      boilerOperation: boilerOperation,
      fuelCategory: fuelCategory,
      fuelSubtype: fuelSubtype,
      fuelOtherText: fuelOtherText.trim(),
      burnerTechnology: burnerTechnology,
      boilerBrand: toestelBrand.text.trim(),
      boilerModel: toestelModel.text.trim(),
      boilerConstructionYear: int.tryParse(toestelYear.text.trim()),
      boilerConstructionYearUnknown: boilerYearUnknown,
      boilerSerialNumber: toestelSerial.text.trim(),
      boilerSerialNumberUnknown: boilerSerialUnknown,
      boilerNominalPowerKw: double.tryParse(
        toestelPower.text.trim().replaceAll(',', '.'),
      ),
      burnerType: burnerType,
      burnerBrand: branderBrand.text.trim(),
      burnerModel: branderModel.text.trim(),
      burnerConstructionYear: int.tryParse(branderYear.text.trim()),
      burnerSerialNumber: branderSerial.text.trim(),
      burnerFlowRate: branderFlowRate.text.trim(),
    );
  }

  /// Disposes all text controllers.
  void dispose() {
    typeB.dispose();
    typeC.dispose();
    toestelBrand.dispose();
    toestelModel.dispose();
    toestelYear.dispose();
    toestelSerial.dispose();
    toestelPower.dispose();
    branderBrand.dispose();
    branderModel.dispose();
    branderYear.dispose();
    branderSerial.dispose();
    branderFlowRate.dispose();
  }
}
