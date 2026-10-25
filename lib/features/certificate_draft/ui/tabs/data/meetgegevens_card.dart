import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../widgets/bento_main_section.dart';
import 'rookgassen_card.dart';

/// Standalone 'Meetgegevens' card with smooth expand/collapse transition.
///
/// Features:
/// - Reuses [BentoMainSection] for the standardized gold-tinted header and animated dropdown.
/// - Hosts the [RookgassenCard] underneath without a nested dropdown sub-box.
class MeetgegevensCard extends StatelessWidget {
  final VoidCallback? onScanQrPressed;

  const MeetgegevensCard({
    super.key,
    this.onScanQrPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerMeetgegevens,
      child: RookgassenCard(
        onScanQrPressed: onScanQrPressed,
      ),
    );
  }
}
