import 'package:flutter/material.dart';
import '../../widgets/quick_slider_picker.dart';

/// Tactical horizontal quick-selection ribbon for top boiler & burner brands in Flanders.
///
/// Features:
/// - Provides 1-tap brand population without requiring touchscreen typing.
/// - Distinct individual brands (never merged, e.g. Bosch and Junkers separate).
/// - Case-insensitive real-time synchronization with active text controller.
/// - Reuses the shared [QuickSliderPicker] tactical ribbon component.
class BrandQuickPicker extends StatelessWidget {
  final String selectedBrand;
  final ValueChanged<String> onBrandSelected;
  final List<String> brands;

  static const List<String> defaultBoilerBrands = [
    'Vaillant',
    'Viessmann',
    'Remeha',
    'Bulex',
    'Bosch',
    'Junkers',
    'Daikin',
    'Weishaupt',
    'ACV',
    'Buderus',
    'ATAG',
  ];

  static const List<String> defaultBurnerBrands = [
    'Weishaupt',
    'Riello',
    'Elco',
    'Bentone',
    'Buderus',
    'Viessmann',
    'MAN / MHG',
    'Giersch',
    'ACV',
  ];

  const BrandQuickPicker({
    super.key,
    required this.selectedBrand,
    required this.onBrandSelected,
    this.brands = defaultBoilerBrands,
  });

  @override
  Widget build(BuildContext context) {
    return QuickSliderPicker(
      selectedValue: selectedBrand,
      onSelected: onBrandSelected,
      options: brands,
    );
  }
}
