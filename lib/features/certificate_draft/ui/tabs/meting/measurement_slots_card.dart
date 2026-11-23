import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../../domain/boiler_draft.dart';
import '../../widgets/bento_main_section.dart';
import 'combustion_fields_layout.dart';
import 'measurement_slot_selector.dart';
import 'slot_form_controllers.dart';

/// Bento Card 2: Rookgasmetingen (Multi-slot combustion test measurements).
///
/// Features:
/// - 3-slot segmented selector (Proef I, Proef II - Laaglast, Proef II - Hooglast).
/// - Multi-slot IndexedStack maintaining both Proef I & Proef II Laaglast mounted
///   simultaneously so pre-flight validation verifies BOTH tests are completed.
/// - 1-tap import from Tab 1 (Data) and direct Eurolyzer QR camera scanner.
/// - Adaptive responsive layout (1-column on narrow S23, 2-column on Pixel 10 Pro / tablet).
class MeasurementSlotsCard extends StatelessWidget {
  final BoilerDraft boiler;
  final String activeSlot;
  final ValueChanged<String> onSlotChanged;
  final Map<String, SlotFormControllers> slots;
  final VoidCallback onCopyFromDataTab;
  final VoidCallback onScanEurolyzer;
  final VoidCallback onClearSlot;
  final bool canClear;
  final bool proef1HasData;
  final bool proef2HasData;
  final bool proef2LaagHasData;
  final bool proef2HoogHasData;
  final VoidCallback onChanged;

  const MeasurementSlotsCard({
    super.key,
    this.boiler = const BoilerDraft(),
    required this.activeSlot,
    required this.onSlotChanged,
    required this.slots,
    required this.onCopyFromDataTab,
    required this.onScanEurolyzer,
    required this.onClearSlot,
    this.canClear = true,
    this.proef1HasData = false,
    this.proef2HasData = false,
    this.proef2LaagHasData = false,
    this.proef2HoogHasData = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    int activeIndex = 0;
    if (activeSlot == 'proef2_laaglast') activeIndex = 1;
    if (activeSlot == 'proef2_hooglast') activeIndex = 2;

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

          // 2. Multi-slot IndexedStack maintaining both Proef 1 & 2 validation states
          IndexedStack(
            index: activeIndex,
            children: [
              _MeasurementSlotView(
                slotKey: 'proef1',
                boiler: boiler,
                slotControllers: slots['proef1'] ?? SlotFormControllers(),
                onChanged: onChanged,
              ),
              _MeasurementSlotView(
                slotKey: 'proef2_laaglast',
                boiler: boiler,
                slotControllers:
                    slots['proef2_laaglast'] ?? SlotFormControllers(),
                onChanged: onChanged,
              ),
              _MeasurementSlotView(
                slotKey: 'proef2_hooglast',
                boiler: boiler,
                slotControllers:
                    slots['proef2_hooglast'] ?? SlotFormControllers(),
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasurementSlotView extends StatelessWidget {
  final String slotKey;
  final BoilerDraft boiler;
  final SlotFormControllers slotControllers;
  final VoidCallback onChanged;

  const _MeasurementSlotView({
    required this.slotKey,
    required this.boiler,
    required this.slotControllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CombustionFieldsLayout(
      key: ValueKey(slotKey),
      boiler: boiler,
      activeSlot: slotKey,
      coOk: slotControllers.coOk,
      onCoOkChanged: (v) {
        slotControllers.setManualCoOk(v, boiler);
        onChanged();
      },
      efficiencyHiOk: slotControllers.efficiencyHiOk,
      onEfficiencyHiOkChanged: (v) {
        slotControllers.setManualHiOk(v, boiler);
        onChanged();
      },
      o2Controller: slotControllers.o2,
      co2Controller: slotControllers.co2,
      coMgKwhController: slotControllers.coMgKwh,
      flueTempTgController: slotControllers.flueTempTg,
      ambientTempTaController: slotControllers.ambientTempTa,
      calculatedNetTemp: slotControllers.calculatedNetTemp,
      efficiencyHiController: slotControllers.efficiencyHi,
      efficiencyHsController: slotControllers.efficiencyHs,
      onChanged: onChanged,
    );
  }
}
