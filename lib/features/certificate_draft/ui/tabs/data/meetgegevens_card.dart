import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import '../../widgets/bento_main_section.dart';
import 'rookgassen_card.dart';

/// Standalone 'Meetgegevens' card with smooth expand/collapse transition.
///
/// Features:
/// - Reuses [BentoMainSection] for the standardized gold-tinted header and animated dropdown.
/// - Hosts the [RookgassenCard] underneath without a nested dropdown sub-box.
class MeetgegevensCard extends StatelessWidget {
  final MeasurementSlotDraft? measurement;
  final VoidCallback? onScanQrPressed;
  final VoidCallback? onClearPressed;

  const MeetgegevensCard({
    super.key,
    this.measurement,
    this.onScanQrPressed,
    this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerMeetgegevens,
      child: RookgassenCard(
        measurement: measurement,
        onScanQrPressed: onScanQrPressed,
        onClearPressed: onClearPressed,
      ),
    );
  }
}
