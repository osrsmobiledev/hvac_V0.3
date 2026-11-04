import '../../../domain/boiler_draft.dart';

/// In-memory cache preserving fuel subtypes when switching categories.
///
/// Ensures technician selections (e.g. Aardgas or Houtpellets) are not
/// wiped out when temporarily toggling between primary fuel types, while
/// guaranteeing that new fuel selections start unselected without fake defaults.
class FuelCategoryMemory {
  String gasSubtype = '';
  String gasOtherText = '';
  String solidSubtype = '';
  String solidOtherText = '';

  /// Pre-warms the cache from a loaded boiler draft.
  void populateFrom(BoilerDraft d) {
    if (d.fuelCategory == 'gas') {
      gasSubtype = d.fuelSubtype;
      gasOtherText = d.fuelOtherText;
    } else if (d.fuelCategory == 'vast') {
      solidSubtype = d.fuelSubtype;
      solidOtherText = d.fuelOtherText;
    }
  }

  /// Updates remembered subtype for the active category.
  void onSubtype(String category, String val) {
    if (category == 'gas') gasSubtype = val;
    if (category == 'vast') solidSubtype = val;
  }

  /// Updates remembered custom other-text for the active category.
  void onOtherText(String category, String text) {
    if (category == 'gas') gasOtherText = text;
    if (category == 'vast') solidOtherText = text;
  }

  /// Resolves the remembered (subtype, otherText) tuple for a newly selected category.
  (String subtype, String otherText) resolveForCategory(String category) {
    if (category == 'gas') return (gasSubtype, gasOtherText);
    if (category == 'vast') return (solidSubtype, solidOtherText);
    return ('', '');
  }
}
