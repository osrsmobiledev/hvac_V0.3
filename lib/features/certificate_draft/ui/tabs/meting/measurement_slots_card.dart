import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../../domain/boiler_draft.dart';
import '../../widgets/bento_main_section.dart';
import 'combustion_fields_layout.dart';
import 'measurement_slot_selector.dart';

/// Bento Card 2: Rookgasmetingen (Multi-slot combustion test measurements).
///
/// Features:
/// - 3-slot segmented selector (Proef I, Proef II - Laaglast, Proef II - Hooglast).
/// - 1-tap import from Tab 1 (Data) and direct Eurolyzer QR camera scanner.
/// - Adaptive responsive layout (1-column on narrow S23, 2-column on Pixel 10 Pro / tablet).
/// - Permanent global statutory assessment section at the bottom (VEKA compliance).
class MeasurementSlotsCard extends StatelessWidget {
  final BoilerDraft boiler;
  final String activeSlot;
  final ValueChanged<String> onSlotChanged;
  final VoidCallback onCopyFromDataTab;
  final VoidCallback onScanEurolyzer;
  final VoidCallback onClearSlot;
  final bool canClear;

  // Measurement input controllers for current slot
  final TextEditingController o2Controller;
  final TextEditingController co2Controller;
  final TextEditingController coMgKwhController;
  final bool? coOk;
  final ValueChanged<bool?> onCoOkChanged;

  final TextEditingController flueTempTgController;
  final TextEditingController ambientTempTaController;
  final String calculatedNetTemp;

  final TextEditingController efficiencyHiController;
  final bool? efficiencyHiOk;
  final ValueChanged<bool?> onEfficiencyHiOkChanged;

  final TextEditingController efficiencyHsController;
  final VoidCallback onChanged;

  const MeasurementSlotsCard({
    super.key,
    this.boiler = const BoilerDraft(),
    required this.activeSlot,
    required this.onSlotChanged,
    required this.onCopyFromDataTab,
    required this.onScanEurolyzer,
    required this.onClearSlot,
    this.canClear = true,
    this.proef1HasData = false,
    this.proef2HasData = false,
    this.proef2LaagHasData = false,
    this.proef2HoogHasData = false,
    required this.o2Controller,
    required this.co2Controller,
    required this.coMgKwhController,
    required this.coOk,
    required this.onCoOkChanged,
    required this.flueTempTgController,
    required this.ambientTempTaController,
    required this.calculatedNetTemp,
    required this.efficiencyHiController,
    required this.efficiencyHiOk,
    required this.onEfficiencyHiOkChanged,
    required this.efficiencyHsController,
    required this.onChanged,
  });

  final bool proef1HasData;
  final bool proef2HasData;
  final bool proef2LaagHasData;
  final bool proef2HoogHasData;

  void _onFieldChanged() {
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: MetingDictionary.headerCombustionMeasurements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Slot Selector and Quick Actions Ribbon
          MeasurementSlotSelector(
            activeSlot: activeSlot,
            onSlotChanged: onSlotChanged,
            onCopyFromDataTab: onCopyFromDataTab,
            onScanEurolyzer: onScanEurolyzer,
            onClearSlot: onClearSlot,
            canClear: canClear,
            proef1HasData: proef1HasData,
            proef2HasData: proef2HasData,
            proef2LaagHasData: proef2LaagHasData,
            proef2HoogHasData: proef2HoogHasData,
          ),
          const SizedBox(height: 16),

          // 2. Responsive Combustion Input Fields (1-col on S23, 2-col on Pixel 10 Pro)
          CombustionFieldsLayout(
            boiler: boiler,
            coOk: coOk,
            onCoOkChanged: onCoOkChanged,
            efficiencyHiOk: efficiencyHiOk,
            onEfficiencyHiOkChanged: onEfficiencyHiOkChanged,
            o2Controller: o2Controller,
            co2Controller: co2Controller,
            coMgKwhController: coMgKwhController,
            flueTempTgController: flueTempTgController,
            ambientTempTaController: ambientTempTaController,
            calculatedNetTemp: calculatedNetTemp,
            efficiencyHiController: efficiencyHiController,
            efficiencyHsController: efficiencyHsController,
            onChanged: _onFieldChanged,
          ),
        ],
      ),
    );
  }
}
